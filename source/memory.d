module Memory;

import erupted;

import VulkanRender: g_VkInstance, g_Device, g_PhysicalDevice, g_PhysicalMemoryProps, test_out;

struct Allocation
{
	VkDeviceMemory memory;
	VkDeviceSize offset;
	VkDeviceSize size;

	size_t id;
	uint type;
}

__gshared Allocator g_Allocator;

struct AllocationCreateInfo
{
	VkMemoryPropertyFlags usage;
	uint type;
	VkDeviceSize size;
}

class Allocator
{
	static Allocator GetAllocator()
	{
		if (!g_Allocator)
			g_Allocator=new Allocator;
		return g_Allocator;
	}

	void Allocate(AllocationCreateInfo create_info, out Allocation alloc)
	{
		VkMemoryAllocateInfo alloc_info={
			allocationSize: create_info.size,
			memoryTypeIndex: FindProperties(g_PhysicalMemoryProps, create_info.type, create_info.usage)
		};

		VkResult ret=vkAllocateMemory(g_Device, &alloc_info, null, &alloc.memory);

		alloc.offset=0;
		alloc.size=create_info.size;
		//alloc.id=chunks.length;
		alloc.type=create_info.type;

		test_out.writeln(ret, " ", alloc);
	}

	void Free(ref Allocation alloc)
	{
		vkFreeMemory(g_Device, alloc.memory, null);
	}
}

// Taken from Vulkan spec
// Find a memory in `memoryTypeBitsRequirement` that includes all of `requiredProperties`
uint FindProperties(const ref VkPhysicalDeviceMemoryProperties pMemoryProperties,
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
	return -1;
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