module LTCore;

struct LTAllocation
{
	int buf0; // unknown, mirrors stride?
	int stride;
	int block_size;
	int block_count;
	int total_size;
	
	void* buf1; // actual allocation ptr, 8 byte header: [0] = address to next, [1] = size of allocation
	void* buf2; // unknown, possibly pointer to the next position this allocation will emplace to?

	static assert(this.sizeof==28);
}