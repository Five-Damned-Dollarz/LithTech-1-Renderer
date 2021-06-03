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
	void* unknown;
}

ParticleSystemObject* ToParticleSystem(BaseObject* obj)
{
	return cast(ParticleSystemObject*)obj;
}

struct ParticleSystemObject
{
	alias base this;
	BaseObject base;
	
	//
}