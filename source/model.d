module Model;

enum ModelFlags : uint
{
	Visible=0x1,
	HasShadows=0x2,
	PolygridUnsigned=0x2,

	ColourTint=0x4, // If this is set, it draws a model in 2 passes.  In the second pass, it scales down the color with
		// ColorR, ColorG, and ColorB.  This is used to tint the skins in multiplayer.  Note: it uses powers
		// of 2 to determine scale so the color scale maps like this:
		// > 253 = 1.0
		// > 126 = 0.5
		// > 62  = 0.25
		// > 29  = 0.12
		// otherwise 0

	CastsShadows=0x8, // for lights
	RotateableSprite=0x8, // sprites only
	GouraudShade=0x8, // models only
	UpdateUnseen=0x8, // particle systems only
	SolidLight=0x10,
	Wireframe=0x10, // models only?
	WasDrawn=0x10, // for particle systems and polygrids
	GlowSprite=0x20, // screenspace sprite sizing
	OnlyLightWorld=0x20,
	EnvironmentMapped=0x20, // models and polygrids (polygrid loses main texture)
	SpriteZBias=0x40,
	DontLightBackfaces=0x40,
	IsReallyClose=0x40, // for PV weapons
	FogLight=0x80,
	AnimationTransition=0x80, // adds 200ms transition between animations
	SpriteNoZ=0x80, // disable sprite depth write
	FullPositionResolution=0x100, // doesn't compress position and rotation packets
	NoLight=0x200, // only use colour and global light scale
	HardwareOnly=0x400, // don't draw in software
	YRotation=0x800, // only rotates on one axis
	SkyObject=0x1000,
	Solid=0x2000,
	BoxPhysics=0x4000,
	ClientNonSolid=0x8000,

	ClientFlagMask=(Visible|HasShadows|PolygridUnsigned|
		ColourTint|CastsShadows|RotateableSprite|
		GouraudShade|UpdateUnseen|SolidLight|
		Wireframe|WasDrawn|GlowSprite|
		OnlyLightWorld|EnvironmentMapped|
		SpriteZBias|DontLightBackfaces|
		IsReallyClose|FogLight|AnimationTransition|
		SpriteNoZ|FullPositionResolution|NoLight|
		HardwareOnly|YRotation|SkyObject|
		Solid|BoxPhysics|ClientNonSolid),

	// Server only flags.
	TouchNotify=(1<<16), // Gets touch notification.
	Gravity=(1<<17), // Gravity is applied.
	StairStep=(1<<18), // Steps up stairs.
	ModelKeys=(1<<19), // The object won't get get MID_MODELSTRINGKEY messages unless
		// it sets this flag.
	KeepAlive=(1<<20), // Save and restore this object when switching worlds.
	GoThruWorld=(1<<21), // Object can pass through world
	RayHit=(1<<22), // Object is hit by raycasts.
	DontFollowStanding=(1<<23), // Dont follow the object this object is standing on.
	ForceClientUpdate=(1<<24), // Force client updates even if the object is OT_NORMAL or invisible.
		// Use this whenever possible.. it saves cycles.
	NoSliding=(1<<25), // Object won't slide agaist polygons

	PointCollide=(1<<26), // Uses much (10x) faster physics for collision detection, but the
		// object is a point (dims 0,0,0).  Standing info is not set when
		// this flag is set.

	RemoveIfOutside=(1<<27), // Remove this object automatically if it gets outside the world.

	ForceOptimizeObject=(1<<28), // Force the engine to optimize this object
		// as if the FLAG_OPTIMIZEOBJECT flags were
		// cleared.  This can be used if you have a visible
		// object that's an attachment but it doesn't need
		// touch notifies or raycast hits (like a gun-in-hand).

	// Internal flags.  Descriptions are there to help the DE developers remember what
	// they're there for, NOT for general use!
	Internal1=(1<<29), // (Did the renderer see the object).
	Internal2=(1<<30), // (Used by ClientDE::FindObjectsInSphere).
	LastFlag=(1<<31),
}

enum ParticleSystemFlags : uint
{
	Bounce=0x1,
	Shadows=0x2,
	NeverDie=0x4,
	Dumb=0x8,
}

enum SurfaceFlags : uint
{
	Solid=0x1,
	NonExistant=0x2,
	Invisible=0x4,
	Transparent=0x8,
	Sky=0x10,
	Bright=0x20,
	GouraudShade=0x40,
	LightMap=0x80,
	NoSubDiv=0x200,
	Hullmaker=0x400,
	AlwaysLightMap=0x800,
	DirectionalLight=0x1000,
}

enum ObjectType : ubyte // NOTE: the high bit of the object type is reserved for the engine's networking.
{
	Normal=0, // Invisible object. Note, clients aren't told about these when they're created on the server!
	Model,
	WorldModel,
	Sprite,
	Light,
	Camera,
	ParticleSystem,
	Polygrid,
	LineSystem,
	Container,
}