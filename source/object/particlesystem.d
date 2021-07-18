module Objects.ParticleSystem;

import LTCore: LTAllocation;
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

	LTAllocation* particles_alloc;

	struct Unknown36Stride
	{
		void*[9] buf;
		static assert(this.sizeof==36);
	}
	Unknown36Stride* unknown_ref; // 36 byte stride, SharedTexture*?

	ubyte[3] software_colour;
	void*[6] buf;
	vec3 unknown_vec3;
	float unknown_scalar_1;
	void*[2] buf2;
	float unknown_scalar_2;
	float buf2a;
	uint particle_count; // pretty sure, not confirmed
	void* buf3; // mirrors count?
	vec3 min_bounds, max_bounds;

	float gravity_accel;
	float buf4;
	uint particle_flags;
	float particle_radius;
	
	static assert(null_particle.offsetof==296); // null particle?
	static assert(null_particle.offsetof+null_particle.m_pNext.offsetof==320); // particle list head, set to &296
	static assert(null_particle.offsetof+null_particle.prev.offsetof==340); // particle list tail? set to &296
	static assert(particles_alloc.offsetof==344); // + 24 = count? or possibly DEParticle*?
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