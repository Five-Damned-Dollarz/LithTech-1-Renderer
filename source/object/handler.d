module Object.Handler;

__gshared ObjectHandler[10] g_ObjectHandlers;

struct ObjectHandler
{
	bool is_init;
	void function() init;
	void function() term;
	void function() preframe;
	void function() process;
}