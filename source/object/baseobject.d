module Objects.BaseObject;

import RendererTypes: DLink, Buffer;
import Model;
import WorldBSP;

import gl3n.linalg;

struct ObjectList
{
	ObjectList* prev;
	ObjectList* next;
	BaseObject* data;

	Node* node;
	ObjectList*[2] buf; // [0] = Node*? [1/2] = other entries in the list?

	static assert(this.sizeof==24);
}

enum ObjState : uint
{
	Active=0x00, // Normal healthy object.
	Inactive=0x08, // Inactive (no updates, physics, or touch notifies).
	InactiveTouch=0x10, // Inactive, but gets touch notifies.
	//AutoDeactiveNow=???, // Autodeactivate now, can reactivate thru PingObjects call.
}

enum MAX_CS_FILENAME_LEN=100;
// This structure is used when creating objects.  When you want to
// create an object, you call ServerDE::CreateObject with one of these.
// The structure you pass in is passed to the object's PostPropRead function,
// where it can override whatever it wants to.
struct ObjectCreateStruct
{
align(1):
	// Main info.
	ushort m_ObjectType;
	int m_Flags;
	vec3 m_Pos;
	vec3 m_Scale;
	float[4] m_Rotation;
	short m_ContainerCode; // Container code if it's a container.  It's in here because
		// you can only set it at creation time.

	int m_UserData; // User data

	char[MAX_CS_FILENAME_LEN+1] m_Filename; // This is the model, sound, or sprite filename.
		// It also can be the WorldModel name.
		// This can be zero-length when it's not needed.

	char[MAX_CS_FILENAME_LEN+1] m_SkinName; // This can be zero-length.. if you set it for an
		// OT_MODEL, it's the skin filename.

	// Server only info.
	char[MAX_CS_FILENAME_LEN+1] m_Name; // This object's name.
	float m_NextUpdate; // This will be the object's starting NextUpdate.
	float m_fDeactivationTime; // Amount of time before object deactivates self
}

struct ObjectClass
{
align(1):
	uint flags;
	void* unknown_obj;
	void* buf1;
	Buffer* strings;
	float next_update;
	float deactivate_time;
	float deactivate_time_;
	void* buf2;
	void* buf3;
	Buffer* unknown_id;
	ObjectCreateStruct* create_struct;
	void* buf4;
	Buffer* file_name;
	Buffer* skin_name;
	BaseObject* next;
	BaseObject* next_inactive;
	void* buf5;
	uint unknown_flags; // updates if below is not 0, looks like flags
	void* unknown; // if 0 we don't do something in a lot of updating functions
}

struct Attachment
{
	vec3 position;
	float[4] rotation;
	ushort parent_id;
	ushort child_id;
	uint node_id; // -1 = no node
	Attachment* next;
}

struct BaseObject // This is the base Object; Model, WorldModel, Sprite, Light, ParticleSystem, LineSystem, and Container derive from it
{
	DLink link;
	DLink link_unknown; // maybe not even a link?
	Buffer* list; // unknown

	void*[2] unknown_1; // suspect object type-calc'd functors from engine

	BaseObject* root; // UnknownList? static assert(root.offsetof==36)

	ModelFlags flags;
	uint user_flags;

	ubyte[4] colour;

	Attachment* attachments;
	vec3 position;
	float[4] rotation;
	vec3 scale;

	float unknown_5;
	short[2] unknown_6;
	short ffff; // unknown, is set to FFFF on creation, possible bitmask for what's updated
	short[2] frame_code; // [108] is set to 0 on frame start

	ObjectType type_id;
	ubyte block_priority;

	float unknown_7;
	vec3 velocity;
	vec3 acceleration;
	float friction_coeff;
	float mass;
	float force_ignore_limit;
	int unknown_8;
	int unknown_9;

	vec3 bounds_min_relative;
	vec3 bounds_max_relative;
	vec3 dimensions;

	void*[5] buf1;

	Buffer* self1;

	ObjState state;

	void*[4] buf2;
	Buffer*[3] self2;
	void*[7] buf3;
	Buffer* self3;
	uint client_user_flags;
	void* buf4;
	ObjectClass* class_;

	// probably where "base" Object ends and derived data begins?

	//WorldData* bsp;

	//pragma(msg, this.sizeof);
	static assert(this.sizeof>=108);
	static assert(flags.offsetof==40);
	static assert(user_flags.offsetof==44);
	static assert(colour.offsetof==48); // if colour[4] (alpha) is not 0xFF then add to transparent draw list instead of solid
	static assert(attachments.offsetof==52);
	static assert(position.offsetof==56);
	//static assert(???.offsetof==84); for type_id=ParticleSystem, unsure what these values are for
	static assert(type_id.offsetof==110);
	//static assert(???.offsetof==124); unsure what this is yet, but it's necessary for visibility?
	static assert(state.offsetof==220);
	static assert(client_user_flags.offsetof==284);
	static assert(class_.offsetof==292);

	//static assert(light_radius.offsetof==296); for type_id=Light, possibly padded to 298?
	//static assert(bsp.offsetof==298); // for type_id=WorldModel
	//static assert(model_data.offsetof==300); // for type_id=Model
	//static assert(camera_width.offsetof==304); // for type_id=Camera
	//static assert(fov_x.offsetof==312); // for type_id=Camera
	//static assert(???.offsetof==316); polygon pointer?
	//static assert(model_nodes.offsetof==320); // for type_id=Model, pointer to model nodes?
	//static assert(model_frame.offsetof==336); // for type_id=Model
	//static assert(polygrid_width.offsetof==368); // for type_id=Polygrid
	//static assert(polygrid_colours.offsetof==376); // for type_id=Polygrid
	//static assert(???.offsetof==380); // for type_id=Model, model node related?
	//static assert(container_code.offsetof==428); // for type_id=Container

	// possibly 300 byte stride for one of the object types?
	// 428-432 stride?
}

struct ModelAnim
{
	void*[29] buf;
	static assert(this.sizeof==116);
}