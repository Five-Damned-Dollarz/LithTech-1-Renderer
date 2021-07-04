module Object.Handler;

import Objects.BaseObject;
import Objects.Light;

void NullHandler() { }
void NullHandler(BaseObject*) { }

enum LightCountMax=40;
//uint g_LightCount=0;
//LightObject*[LightCountMax] g_Lights;

void LightProcess(BaseObject* obj)
{
	LightObject* light_obj=cast(LightObject*)obj;

	/+
	// add entry to lights uniform buffer?
	struct UniformLight // uniform buffer light struct
	{
		vec3 position;
		vec3 colour;
		float radius;
	}

	struct ShaderLights
	{
		uint light_count;
		UniformLight[40] g_UniformLights;
	}
	+/
}

immutable ObjectHandler[10] g_ObjectHandlers=[
	{ // BaseObject
		is_init: false,
		init: null,
		term: null,
		preframe: null,
		process: null
	},
	{ // Model
		is_init: false,
		init: &NullHandler,
		term: &NullHandler,
		preframe: &NullHandler,
		process: &NullHandler
	},
	{ // WorldModel
		is_init: false,
		init: null,
		term: null,
		preframe: &NullHandler,
		process: &NullHandler
	},
	{ // Sprite
		is_init: false,
		init: null,
		term: null,
		preframe: &NullHandler,
		process: &NullHandler
	},
	{ // Light
		is_init: false,
		init: null,
		term: null,
		preframe: null,
		process: &LightProcess
	},
	{ // Camera
		is_init: false,
		init: null,
		term: null,
		preframe: null,
		process: null
	},
	{ // ParticleSystem,
		is_init: false,
		init: null,
		term: null,
		preframe: &NullHandler,
		process: &NullHandler
	},
	{ // Polygrid
		is_init: false,
		init: &NullHandler,
		term: &NullHandler,
		preframe: &NullHandler,
		process: &NullHandler
	},
	{ // LineSystem
		is_init: false,
		init: null,
		term: null,
		preframe: &NullHandler,
		process: &NullHandler
	},
	{ // Container
		is_init: false,
		init: null,
		term: null,
		preframe: null,
		process: &NullHandler
	}
];

struct ObjectHandler
{
	bool is_init;
	void function() init;
	void function() term;
	void function(/+ this might have 2 arguments, but I'm not sure what they are yet +/) preframe;
	void function(BaseObject*) process;
}