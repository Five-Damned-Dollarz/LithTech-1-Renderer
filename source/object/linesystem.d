module Objects.LineSystem;

import Objects.BaseObject;

import gl3n.linalg;

LineSystemObject* ToLineSystem(BaseObject* obj)
{
	return cast(LineSystemObject*)obj;
}

// The line structure for line system.
struct DELinePt
{
	vec3 m_Pos;
	float r, g, b, a; // Values 0-1.
}

struct DELine
{
	DELinePt[2] m_Points;
	//DELine* next; // is this really here?
	//DELine* prev;

	//pragma(msg, this.sizeof);
	//static assert(this.sizeof==56);
	//static assert(next.offsetof==60);
	//static assert(prev.offsetof==64);
}

struct LineSystemObject
{
	alias base this;
	BaseObject base;
	
	void* unknown_1;
	void* buf0;

	DELine null_line; // not sure if this is a pointer or in-place

	void* buf1;

	DELine* lines_begin;
	DELine* lines_end;

	void*[6] buf2;
	vec3 pos;
	float width; // used as width, but is this an accurate name?
	
	static assert(this.sizeof==412);
	static assert(null_line.offsetof==304);
	static assert(lines_begin.offsetof==364); // + 368, start/end line list? init to &304
	static assert(pos.offsetof==396);
	static assert(width.offsetof==408);
}