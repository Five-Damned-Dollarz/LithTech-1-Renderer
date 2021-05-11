module Model;

enum ModelFlags
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
	ClientNonSolid=0x8000
}

enum ParticleSystemFlags
{
	PS_BOUNCE=0x1,
	PS_SHADOWS=0x2,
	PS_NEVERDIE=0x4,
	PS_DUMB=0x8,
}

enum SurfaceFlags
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

enum ObjectType // NOTE: the high bit of the object type is reserved for the engine's networking.
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