module Memory;

import erupted;

import VulkanRender: g_VkInstance, g_Device, g_PhysicalDevice, g_PhysicalDeviceProps, g_PhysicalMemoryProps, test_out;

// Maximum size of a memory heap in Vulkan to consider it "small".
immutable VkDeviceSize VMA_SMALL_HEAP_MAX_SIZE = 512 * 1024 * 1024;
// Default size of a block allocated as single VkDeviceMemory from a "large" heap.
immutable VkDeviceSize VMA_DEFAULT_LARGE_HEAP_BLOCK_SIZE = 256 * 1024 * 1024;
// Default size of a block allocated as single VkDeviceMemory from a "small" heap.
immutable VkDeviceSize VMA_DEFAULT_SMALL_HEAP_BLOCK_SIZE =  64 * 1024 * 1024;

struct SubAllocation
{
	VkDeviceSize offset;
	VkDeviceSize size;

	bool _is_free=true;
	@property bool is_free() const { return _is_free; }
}

class Allocation
{
	VkDeviceMemory memory;
	VkDeviceSize size;
	uint type_index;

	SubAllocation[] suballocs;

	this(uint memory_type_index)
	{
		VkMemoryAllocateInfo alloc_info={
			allocationSize: VMA_DEFAULT_SMALL_HEAP_BLOCK_SIZE,
			memoryTypeIndex: memory_type_index
		};

		vkAllocateMemory(g_Device, &alloc_info, null, &memory);
		size=alloc_info.allocationSize;
		type_index=alloc_info.memoryTypeIndex;

		debug { test_out.writeln(this); test_out.flush(); }
	}

	~this()
	{
		vkFreeMemory(g_Device, memory, null);
		debug { test_out.writeln("Free."); test_out.flush(); }
	}

	@property VkDeviceSize AvailableMemory() const
	{
		VkDeviceSize free_mem=size;

		/+foreach(alloc; suballocs)
			if (alloc.is_free)
				free_mem+=alloc.size;+/

		foreach(alloc; suballocs)
			free_mem-=alloc.size;

		return free_mem;
	}

	VkResult Chunk(VkDeviceSize size, VkDeviceSize align_, out VkMappedMemoryRange alloc_out)
	{
		if (size>AvailableMemory())
			return VK_ERROR_OUT_OF_DEVICE_MEMORY;

		SubAllocation sub_alloc;
		sub_alloc._is_free=false;
		sub_alloc.size=size;
		if (suballocs.length)
			sub_alloc.offset=VmaAlignUp(suballocs[$-1].offset+suballocs[$-1].size, align_);

		suballocs~=sub_alloc; // std.array: insertInPlace; std.container.array: insertBefore, insertAfter

		alloc_out.memory=memory;
		alloc_out.offset=sub_alloc.offset;
		alloc_out.size=sub_alloc.size;

		debug { test_out.writeln(alloc_out); test_out.flush(); }

		return VK_SUCCESS;
	}
}

__gshared Allocator g_Allocator;

class Allocator
{
	VkDeviceSize m_PreferredLargeHeapBlockSize=VMA_DEFAULT_LARGE_HEAP_BLOCK_SIZE;
	VkDeviceSize m_PreferredSmallHeapBlockSize=VMA_DEFAULT_SMALL_HEAP_BLOCK_SIZE;

	Allocation[][VK_MAX_MEMORY_TYPES] allocs;

	VkMappedMemoryRange[VkBuffer] m_BufferToMemoryMap;
	VkMappedMemoryRange[VkImage] m_ImageToMemoryMap;
	//bool[VK_MAX_MEMORY_TYPES] m_HasEmptyAllocation;

	this()
	{
		foreach(ref vec; allocs)
		{
			vec=new Allocation[0];
		}
	}
	~this() {}

	static Allocator GetAllocator()
	{
		if (g_Allocator is null)
			g_Allocator=new Allocator();
		return g_Allocator;
	}

	VkResult Allocate(const VkMemoryRequirements mem_reqs, const VkMemoryPropertyFlags mem_props, ref VkMappedMemoryRange memory_range)
	{
		memory_range.size=mem_reqs.size;
		uint mem_type_index=FindMemoryType(g_PhysicalMemoryProps, mem_reqs.memoryTypeBits, mem_props);

		test_out.writeln("MemType: ", mem_type_index);
		foreach(block; allocs[mem_type_index])
		{
			VkResult res=block.Chunk(memory_range.size, mem_reqs.alignment, memory_range);

			test_out.writeln(__FUNCTION__, " - ", res);
			test_out.flush();

			if (res==VK_SUCCESS) // check if able to allocate
			{
				// allocate
				return VK_SUCCESS;
			}
		}

		// else create new block
		Allocation new_block=new Allocation(mem_type_index);
		allocs[mem_type_index]~=new_block;

		VkResult res=new_block.Chunk(memory_range.size, mem_reqs.alignment, memory_range);
		test_out.writeln(__FUNCTION__, " - ", res);
		test_out.flush();

		return VK_SUCCESS;
	}

	void Free(ref Allocation alloc)
	{
		vkFreeMemory(g_Device, alloc.memory, null);
	}

	VkDeviceSize GetPreferredBlockSize(uint32_t memTypeIndex) const
	{
		VkDeviceSize heapSize = g_PhysicalMemoryProps.memoryHeaps[g_PhysicalMemoryProps.memoryTypes[memTypeIndex].heapIndex].size;
		return (heapSize <= VMA_SMALL_HEAP_MAX_SIZE) ? m_PreferredSmallHeapBlockSize : m_PreferredLargeHeapBlockSize;
	}

	uint32_t GetMemoryHeapCount() const { return g_PhysicalMemoryProps.memoryHeapCount; }
	uint32_t GetMemoryTypeCount() const { return g_PhysicalMemoryProps.memoryTypeCount; }
}

// Taken from Vulkan spec
// Find a memory in `memoryTypeBitsRequirement` that includes all of `requiredProperties`
uint FindMemoryType(ref const VkPhysicalDeviceMemoryProperties pMemoryProperties,
	uint memoryTypeBitsRequirement,
	VkMemoryPropertyFlags requiredProperties)
{
	const uint memoryCount = pMemoryProperties.memoryTypeCount;

	for (size_t memoryIndex = 0; memoryIndex < memoryCount; ++memoryIndex)
	{
		const uint memoryTypeBits = (1 << memoryIndex);
		const bool isRequiredMemoryType = cast(bool)(memoryTypeBitsRequirement & memoryTypeBits);
		const VkMemoryPropertyFlags properties=pMemoryProperties.memoryTypes[memoryIndex].propertyFlags;

		const bool hasRequiredProperties = (properties & requiredProperties) == requiredProperties;

		if (isRequiredMemoryType && hasRequiredProperties)
			return cast(uint)(memoryIndex);
	}

	// failed to find memory type
	return uint.max;
}

/+
// Try to find an optimal memory type, or if it does not exist try fallback memory type
// `device` is the VkDevice
// `image` is the VkImage that requires memory to be bound
// `memoryProperties` properties as returned by vkGetPhysicalDeviceMemoryProperties
// `requiredProperties` are the property flags that must be present
// `optimalProperties` are the property flags that are preferred by the application
VkMemoryRequirements memoryRequirements;
vkGetImageMemoryRequirements(device, image, &memoryRequirements);
uint memoryType = findProperties(&memoryProperties, memoryRequirements.memoryTypeBits, optimalProperties);
if (memoryType == -1) // not found; try fallback properties
	memoryType = findProperties(&memoryProperties, memoryRequirements.memoryTypeBits, requiredProperties);
+/

// Aligns given value up to nearest multiply of align value. For example: VmaAlignUp(11, 8) = 16.
// Use types like uint32_t, uint64_t as T.
static pragma(inline) T VmaAlignUp(T)(T val, T align_)
{
	return (val + align_ - 1) / align_ * align_;
}

// Division with mathematical rounding to nearest number.
pragma(inline) T VmaRoundDiv(T)(T x, T y)
{
	return (x + (y / cast(T)2)) / y;
}

VkResult vmaMapMemory(ref const VkMappedMemoryRange pMemory, void** ppData)
{
  return vkMapMemory(g_Device, pMemory.memory, pMemory.offset, pMemory.size, 0, ppData);
}

void vmaUnmapMemory(ref const VkMappedMemoryRange pMemory)
{
	vkUnmapMemory(g_Device, pMemory.memory);
}

void CreateAllocBuffer(
	Allocator alloc,
	const VkBufferCreateInfo create_info,
	VkMemoryPropertyFlags properties,
	out VkBuffer buffer,
	VkMappedMemoryRange* pMemory,
	uint* memory_type_index)
{
	vkCreateBuffer(g_Device, &create_info, null, &buffer);

	VkMemoryRequirements memory_reqs;
	vkGetBufferMemoryRequirements(g_Device, buffer, &memory_reqs);

	VkMappedMemoryRange buf_alloc;
	VkResult res=alloc.Allocate(memory_reqs, properties, buf_alloc);

	vkBindBufferMemory(g_Device, buffer, buf_alloc.memory, buf_alloc.offset);

	if (pMemory!=null) *pMemory=buf_alloc;

	alloc.m_BufferToMemoryMap[buffer]=buf_alloc;
}

void CreateAllocImage(
	Allocator alloc,
	const VkImageCreateInfo create_info,
	VkMemoryPropertyFlags properties,
	out VkImage image,
	VkMappedMemoryRange* pMemory,
	uint* memory_type_index)
{
	vkCreateImage(g_Device, &create_info, null, &image);

	VkMemoryRequirements memory_reqs;
	vkGetImageMemoryRequirements(g_Device, image, &memory_reqs);

	VkMappedMemoryRange buf_alloc;
	VkResult res=alloc.Allocate(memory_reqs, properties, buf_alloc);

	vkBindImageMemory(g_Device, image, buf_alloc.memory, buf_alloc.offset);

	if (pMemory!=null) *pMemory=buf_alloc;

	alloc.m_ImageToMemoryMap[image]=buf_alloc;
}