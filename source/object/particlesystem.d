module Objects.ParticleSystem;

import Objects.BaseObject;

import gl3n.linalg;

// Particle system flags. Each one slows it down a little more
// except for PS_NEVERDIE which speeds it up..
enum ParticleSystemFlags
{
	Bounce=1, // Do they bounce?
	Shadows=2, // Enable shadows.
	NeverDie=4, // The particles never die (and it doesn't have to check).
	Dumb=8, // The engine leaves the system alone.. you must
		// update and move them.
}

// The particle structure for particle systems.
struct DEParticle
{
	vec3 m_Velocity;
	vec3 m_Color; // Particle colors are 0-255.
	DEParticle *m_pNext;
	
	vec3 position;
	float lifetime;
	DEParticle* prev;
}

ParticleSystemObject* ToParticleSystem(BaseObject* obj)
{
	return cast(ParticleSystemObject*)obj;
}

struct ParticleSystemObject
{
	alias base this;
	BaseObject base;

	DEParticle null_particle;
	private byte[4] buf0;
	void* unknown_ref;
	ubyte[3] software_colour;
	private byte[24] buf;
	vec3 unknown_vec3;
	float unknown_scalar_1;
	private byte[8] buf2;
	float unknown_scalar_2;
	private byte[4] buf2a;
	uint particle_count; // pretty sure, not confirmed
	private byte[4] buf3;
	vec3 min_bounds, max_bounds;

	float gravity_accel;
	private byte[4] buf4;
	uint particle_flags;
	float particle_radius;
	
	static assert(null_particle.offsetof==296); // null particle?
	//static assert(unknown.offsetof==320); // particle list head, set to &296
	//static assert(unknown.offsetof==340); // particle list tail? set to &296
	//static assert(unknown.offsetof==344); // + 24 = count?
	static assert(unknown_ref.offsetof==348); // ??? init to null
	static assert(software_colour.offsetof==352); // byte[3]? init to null
	static assert(unknown_vec3.offsetof==380); // vec3, position?
	static assert(unknown_scalar_1.offsetof==392); // width? init to 1.0f
	static assert(unknown_scalar_2.offsetof==404); // init to 1.0f
	static assert(particle_count.offsetof==412);
	static assert(min_bounds.offsetof==420);
	static assert(max_bounds.offsetof==432);
	static assert(gravity_accel.offsetof==444); // gravity acceleration?
	static assert(particle_flags.offsetof==452); // particle flags
	static assert(particle_radius.offsetof==456); // particle radius
}