shader_type canvas_item;

uniform float static_intensity: hint_range(0.0, 1.0) = 1.0;

uniform float fisheye_strength: hint_range(0.0, 0.5) = 0.08;
uniform float vignette_intensity:hint_range(0.0, 2.0) = 0.4;
uniform vec4 vignette_colour: source_color = vec4(0.0, 0.0, 0.0, 1.0);

float random_from_seed(float seed) {
    return fract(sin(seed * 12.9898) * 43758.5453123);
}

void fragment() {
	vec2 center_delta = UV - 0.5;
    float dist_sq = dot(center_delta, center_delta);
    
    // Warps the local node footprint mapping space coordinates
    vec2 distorted_uv = UV + center_delta * dist_sq * fisheye_strength;
    
    // --- 2. RETRO HARD BEZEL CORNER CULLING (Direct Lift) ---
    if (distorted_uv.x < 0.0 || distorted_uv.x > 1.0 || distorted_uv.y < 0.0 || distorted_uv.y > 1.0) {
        // Keeps the outside bounds clamped to your exact physical black screen borders
        COLOR = vec4(0.0, 0.0, 0.0, static_intensity);
    } else {
        // --- 3. HARSH TV STATIC NOISE GENERATOR ---
        // Generates 100% thick digital noise frames using your seed equation format
        float grain_seed = dot(distorted_uv, vec2(12.9898, 78.233)) + TIME;
        float grain = random_from_seed(grain_seed);
        
        // Turn the random grain float into a high-visibility grayscale color vec3
        vec3 static_color = vec3(grain);
        
        // --- 4. VIGNETTE SHADOW ENVELOPE (Direct Lift) ---
        float vignette = distorted_uv.x * distorted_uv.y * (1.0 - distorted_uv.x) * (1.0 - distorted_uv.y);
        vignette = clamp(pow(16.0 * vignette, vignette_intensity), 0.0, 1.0);
        
        // Blend the harsh static with the vignette color values across the curved mask boundaries
        vec3 composite_rgb = mix(vignette_colour.rgb, static_color, vignette);
        
        // Assign the final textured pixels, managed entirely by your screen transition Tween alpha!
        COLOR = vec4(composite_rgb, static_intensity);
    }
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
