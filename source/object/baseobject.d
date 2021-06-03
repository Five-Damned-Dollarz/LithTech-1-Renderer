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

struct StringList
{
	ObjectString* string_;
	//ushort[2] unknown;
	void* unknown;
	uint id;
	void* unknown_1;
	void* unknown_2;
}

struct ObjectString
{
align(2):
	DLink link;
	Buffer*[2] buf1;
	ushort name_length;
	char[64] name; // in place char array
	@property string ToString() const
	{
		return name.ptr[0..name_length].idup;
	}
	static assert(name_length.offsetof==0x14);
	static assert(name.offsetof==0x16);
}

struct Aggregate
{
	// This is so DirectEngine will skip over a C++ object's VTable.
	void *cpp_4BytesForVTable;

	Aggregate* m_pNextAggregate;

	// Hook functions for the aggregate..
	int function(BaseClass* pObject, Aggregate* pAggregate, int messageID, void *pData, float fData) m_EngineMessageFn;
	int function(BaseClass* pObject, Aggregate* pAggregate, BaseObject* hSender, int messageID, void* /+ HMESSAGEREAD* +/ hRead) m_ObjectMessageFn;
}

struct BaseClass
{
	// This is so DirectEngine will skip over a C++ object's VTable.
	void *cpp_4BytesForVTable;

	// The first aggregate in the linked list..
	Aggregate* m_pFirstAggregate;

	// This is always set.. you can use this to pass in an
	// HOBJECT to the functions that require on instead of calling
	// ObjectToHandle() every time..
	BaseObject* m_hObject;
}

enum PropertyType : short
{
	PT_STRING=0,
	PT_VECTOR=1,
	PT_COLOR=2,
	PT_REAL=3,
	PT_FLAGS=4,
	PT_BOOL=5,
	PT_LONGINT=6,
	PT_ROTATION=7,
}

enum PropertyFlags : short
{
	PF_HIDDEN=(1<<0), // Property doesn't show up in DEdit.
	PF_RADIUS=(1<<1), // Property is a number to use as radius for drawing circle.  There can be more than one.
	PF_DIMS=(1<<2), // Property is a vector to use as dimensions for drawing box. There can be only one.
	PF_FIELDOFVIEW=(1<<3), // Property is a field of view.
	PF_LOCALDIMS=(1<<4), // Used with PF_DIMS.  Causes DEdit to show dimensions rotated with the object.
	PF_GROUPOWNER=(1<<5), // This property owns the group it's in.
	PF_GROUP1=(1<<6), // This property is in group 1.
	PF_GROUP2=(1<<7), // This property is in group 2.
	PF_GROUP3=(1<<8), // This property is in group 3.
	PF_GROUP4=(1<<9), // This property is in group 4.
	PF_GROUP5=(1<<10), // This property is in group 5.
	PF_GROUP6=(1<<11), // This property is in group 6.
}

struct PropDef
{
	this(char* pName, PropertyType type, vec3 valVec, float valFloat, char* valString, PropertyFlags propFlags)
	{
		m_PropName=pName;
		m_PropType=type;
		m_DefaultValueVector=valVec;
		m_DefaultValueFloat=valFloat;
		m_DefaultValueString=valString;
		m_PropFlags=propFlags;
		m_pInternal=null;
	}

	char* m_PropName;

	// One of the PT_ defines above.
	PropertyType m_PropType;

	// Default vector/color value.
	vec3 m_DefaultValueVector;

	float m_DefaultValueFloat;
	char* m_DefaultValueString;

	PropertyFlags m_PropFlags;

	// Don't touch!
	void* m_pInternal;
}

enum ClassFlags : int
{
	CF_HIDDEN=(1<<0), // Instances of the class can't be created in DEdit.
	CF_NORUNTIME=(1<<1), // This class doesn't get used at runtime (the engine
		// won't instantiate these objects out of the world file).
	CF_STATIC=(1<<2), // This is a special class that the server creates an
		// instance of at the same time that it creates the
		// server shell.  The object is always around.  This
		// should be used as much as possible instead of adding
		// code to the server shell.
	CF_ALWAYSLOAD=(1<<3), // Objects of this class and sub-classes are always loaded from the level
		// file and can't be saved to a save game.
}

enum MessageSubId : float
{
	PRECREATE_NORMAL=0.0f, // Object is being created at runtime.
	PRECREATE_WORLDFILE=1.0f, // Object is being loaded from a world file.  Read props in.
	PRECREATE_STRINGPROP=2.0f, // Object is created from CreateObjectProps.  Use GetPropGeneric to read props.
	PRECREATE_SAVEGAME=3.0f, // Object comes from a savegame.

	INITIALUPDATE_NORMAL=0.0f, // Normal creation.
	INITIALUPDATE_WORLDFILE=1.0f, // Being created from a world file.
	INITIALUPDATE_STRINGPROP=2.0f, // Object is created from CreateObjectProps.  Use GetPropGeneric to read props.
	INITIALUPDATE_SAVEGAME=3.0f, // Created from a savegame.
}

enum MessageId : int
{
	// Here are all the message IDs and structures that LithTech uses.

	// This is called right before the server uses the ObjectCreateStruct
	// to create its internal structure for the object.
	// pData = ObjectCreateStruct*
	// fData = a PRECREATE_ define above.
	MID_PRECREATE=0,

	// This is called right after your object is created (kind of like the opposite
	// of MID_POSTPROPREAD).
	// fData is an INITIALUPDATE_ define above.
	MID_INITIALUPDATE=1,

	// This is called when NextUpdate goes to zero.
	MID_UPDATE=2,

	// This is called when you touch another object.
	// pData is an HOBJECT for the other object.
	// fData is the collision (stopping) force (based on masses and velocities).
	MID_TOUCHNOTIFY=3,

	// This is notification when a link to an object is about to be broken.
	// pData is an HOBJECT to the link's object.
	MID_LINKBROKEN=4,

	// This is notification when a model string key is crossed.
	// (You only get it if your FLAG_MODELKEYS flag is set).
	// pData is an ArgList*.
	MID_MODELSTRINGKEY=5,

	// Called when an object pushes you into a wall.  It won't
	// move any further unless you make yourself nonsolid (ie: a player would
	// take damage from each crush notification, then die).
	// pData is the HOBJECT of the object crushing you.
	MID_CRUSH=6,

	// Load and save yourself for a serialization.
	// pData is an HMESSAGEREAD or HMESSAGEWRITE.
	// fData is the dwParam passed to ServerDE::SaveObjects or ServerDE::RestoreObjects.
	MID_LOADOBJECT=7,
	MID_SAVEOBJECT=8,

	// Called for a container for objects inside it each frame.  This gives you a chance
	// to modify the physics applied to an object WITHOUT actually modifying its
	// velocity or acceleration (great way to dampen velocity..)
	// pData is a ContainerPhysics*.
	MID_AFFECTPHYSICS=9,

	// The parent of an attachment between you and it is being removed.
	MID_PARENTATTACHMENTREMOVED=10,

	// Called every frame on client objects.  This gives you a chance to force
	// updates on certain objects so they never get removed for the client.
	// pData is a ForceUpdate*.
	// (LT automatically adds the client object and the sky objects to this list to start with).
	MID_GETFORCEUPDATEOBJECTS=11,
}

struct ClassDef
{
	char *m_ClassName;

	ClassDef* m_ParentClass;

	// A combination of the CF_ flags above.
	ClassFlags m_ClassFlags;

	void function(void*) m_ConstructFn;
	void function(void*) m_DestructFn;
	int function(int, void *, float) m_EngineMessageFn;
	int function(BaseObject*, int, void*) m_ObjectMessageFn;

	short m_nProps;
	PropDef* m_Props;

	@property PropDef[] Properties()
	{
		return m_Props[0..m_nProps];
	}

	// How big an object of this class is (set automatically).
	size_t m_ClassObjectSize;

	// Don't touch!
	void*[2] m_pInternal;
}

struct ObjectClass
{
align(1):
	uint flags;
	ObjectClass* unknown_obj; // ???
	void* buf1;
	ObjectString** object_name;
	float next_update;
	float deactivate_time;
	float deactivate_time_;
	void* buf2;
	BaseClass* object_instance;
	ClassDef* class_definition;
	ObjectCreateStruct* create_struct;
	void* buf4;
	ObjectString** model_filename;
	ObjectString** texture_filename;
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
	Buffer*[4] self2;
	float[4] unknown_rot;
	void*[2] buf3;
	Buffer* self3;
	uint client_user_flags;
	void* buf4;
	ObjectClass* class_;

	// probably where "base" Object ends and derived data begins?

	//WorldData* bsp;

	//pragma(msg, this.sizeof);
	//static assert(this.sizeof>=108);
	static assert(flags.offsetof==40);
	static assert(user_flags.offsetof==44);
	static assert(colour.offsetof==48); // if colour[4] (alpha) is not 0xFF then add to transparent draw list instead of solid
	static assert(attachments.offsetof==52);
	static assert(position.offsetof==56);
	//static assert(???.offsetof==84); for type_id=ParticleSystem, unsure what these values are for
	static assert(type_id.offsetof==110);
	//static assert(???.offsetof==124); unsure what this is yet, but it's necessary for visibility?
	static assert(state.offsetof==220);
	static assert(unknown_rot.offsetof==256);
	static assert(client_user_flags.offsetof==284);
	static assert(class_.offsetof==292);

	//static assert(bsp.offsetof==298); // for type_id=WorldModel
	//static assert(camera_width.offsetof==304); // for type_id=Camera
	//static assert(fov_x.offsetof==312); // for type_id=Camera
	//static assert(???.offsetof==316); polygon pointer?
	//static assert(sprite_control.offsetof==320); // for type_id=Sprite, in-place? interface in AppHeaders/SpriteControl.h
	//static assert(container_code.offsetof==428); // for type_id=Container

	// possibly 300 byte stride for one of the object types?
	// 428-432 stride?
}