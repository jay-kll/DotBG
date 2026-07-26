shader_type spatial;
render_mode cull_disabled;

// The four sanity tiers of CANON.md §5 as one continuous parameter.
//
// 1.0 -- crisp stonework, warm candlelight, true arches
// 0.75 -- subtle wrongness: stone slightly rough, arches slightly off
// 0.50 -- obvious corruption: organic breathing stone, metal bleeding
// 0.0  -- total breakdown: fully organic diseased writhing stone
//
// Written as sanity rather than corruption so it reads the same way the HUD
// and SanityManager do: 100 is healthy, 0 is nightmare. One value drives
// geometry, colour and surface, which is the entire argument for full 3D in
// CANON.md §5.4 -- on sprites this is a repaint of every frame, four times.
//
// This is the working skeleton, not the final look. Art direction over it is a
// human's job; what it establishes is that a single uniform can move the
// geometry and the palette together, and that a test can see it happen.

uniform float sanity : hint_range(0.0, 1.0) = 1.0;
uniform vec3 stone_color : source_color = vec3(0.290, 0.290, 0.290); // #4a4a4a
uniform vec3 corruption_color : source_color = vec3(0.133, 0.545, 0.133); // #228b22
uniform vec3 void_color : source_color = vec3(0.400, 0.200, 0.600); // #663399
uniform float displacement = 0.14;
uniform float breath_speed = 0.7;

varying float corruption_amount;

// Cheap value noise. A texture lookup would look better and cost a sampler on
// every kit surface; the mobile budget in CANON.md §4 does not have one spare.
float hash(vec3 p) {
	return fract(sin(dot(p, vec3(12.9898, 78.233, 37.719))) * 43758.5453);
}

float noise(vec3 p) {
	vec3 i = floor(p);
	vec3 f = fract(p);
	f = f * f * (3.0 - 2.0 * f);
	float n = mix(
		mix(mix(hash(i), hash(i + vec3(1, 0, 0)), f.x),
			mix(hash(i + vec3(0, 1, 0)), hash(i + vec3(1, 1, 0)), f.x), f.y),
		mix(mix(hash(i + vec3(0, 0, 1)), hash(i + vec3(1, 0, 1)), f.x),
			mix(hash(i + vec3(0, 1, 1)), hash(i + vec3(1, 1, 1)), f.x), f.y),
		f.z);
	return n;
}

void vertex() {
	corruption_amount = 1.0 - sanity;

	// Squared, so the first quarter of sanity loss is the "subtle wrongness"
	// tier rather than an immediate lurch into writhing stone.
	float amount = corruption_amount * corruption_amount;

	// Breathing: the stone moves along its own normal, which keeps a straight
	// wall reading as a wall that is wrong rather than as noise.
	float t = TIME * breath_speed;
	float n = noise(VERTEX * 2.4 + vec3(0.0, t, 0.0)) - 0.5;
	float pulse = sin(t + VERTEX.y * 1.7) * 0.35 + 0.65;

	VERTEX += NORMAL * n * pulse * displacement * amount;
}

void fragment() {
	float amount = corruption_amount;

	// Stone gives way to corruption green, then to the void purple only at the
	// bottom tier, so 0.0 is a different place rather than merely more of 0.5.
	vec3 albedo = mix(stone_color, corruption_color, smoothstep(0.15, 0.75, amount));
	albedo = mix(albedo, void_color, smoothstep(0.7, 1.0, amount));

	// Corrupted stone stops behaving like stone: wetter, more organic.
	ALBEDO = albedo;
	ROUGHNESS = mix(0.85, 0.25, amount);
	METALLIC = 0.0;

	// At the last tier it emits, which is what sells "impossible light sources"
	// without needing a light in the scene.
	EMISSION = void_color * smoothstep(0.85, 1.0, amount) * 0.6;
}
