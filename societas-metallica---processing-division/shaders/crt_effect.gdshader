shader_type canvas_item;

uniform sampler2D screen_texture: hint_screen_texture, filter_nearest;

uniform float scan_line_thickness: hint_range(0.001, 1.0) = 0.01;
uniform float scanline_opacity: hint_range(0.0, 1.0) = 0.2;
uniform float scroll_speed: hint_range(-10.0, 10.0) = 2.0;
uniform float fisheye_curvature: hint_range(0.0, 1.0) = 0.08;
uniform float vignette_intensity: hint_range(0.0, 2.0) = 0.4;
uniform vec4 vignette_colour: source_color = vec4(0.0, 0.0, 0.0, 1.0);

uniform float screen_noise_intensity: hint_range(0.0, 0.2) = 0.05;
uniform float scanline_noise_intensity: hint_range(0.0, 2.0) = 0.3;

uniform float scanline_density: hint_range(10.0, 300.0) = 50.0;

uniform float glow_intensity: hint_range(0.0, 4.0) = 0.5;
uniform float glow_threshold: hint_range(0.0, 1.0) = 0.4;

float random_from_seed(float seed) {
	return fract(sin(seed * 12.9898) * 43758.5453123);
}

float noise1d(float x) {
	float i = floor(x);
	float f = fract(x);
	float u = f* f * (3.0 - 2.0 * f);
	return mix(random_from_seed(i), random_from_seed(i + 1.0), u);
}

vec3 extract_bright_text(vec3 rgb_colour) {
	float brightness = dot(rgb_colour, vec3(0.2126, 0.7152, 0.0722));
	
	return rgb_colour * smoothstep(glow_threshold, glow_threshold + 0.1, brightness);
}

void fragment() {
	vec2 center_delta = UV - 0.5;
	float dist_sq = dot(center_delta, center_delta);
	
	vec2 distorted_uv = UV + center_delta * dist_sq * fisheye_curvature;
	
	if (distorted_uv. x < 0.0 || distorted_uv.x > 1.0 || distorted_uv.y < 0.0 || distorted_uv.y > 1.0) {
		COLOR = vec4(0.0,0.0,0.0,1.0);
	} else {
	vec2 screen_mapped_uv = SCREEN_UV + (distorted_uv - UV);
	vec4 color = texture(screen_texture, screen_mapped_uv);
	
	if (color.rgb == vec3(1.0) && color.a == 1.0) {
		color = vec4(0.0,0.0,0.0,0.0);
	}
	float grain_seed = dot(distorted_uv, vec2(12.9898, 78.233)) + TIME;
	float grain = random_from_seed(grain_seed);
	float scanline_fuzz = (grain - 0.5) * scanline_noise_intensity;
	
	float noise_coord = (distorted_uv.y * scanline_density) - (TIME * scroll_speed) + scanline_fuzz;
	float line_pattern = noise1d(noise_coord);
	
	float time_step = floor(TIME * 6.0);
	float random_width_modifier = mix(0.4, 1.6, random_from_seed(time_step));
	
	float low_bound = 0.3 * scan_line_thickness * random_width_modifier;
	float high_bound = 0.7 * scan_line_thickness * random_width_modifier;
	float scanline = smoothstep(low_bound, high_bound, line_pattern);

	vec3 final_rgb = mix(color.rgb, color.rgb * scanline, scanline_opacity);
	
	final_rgb += (grain * 0.5) * screen_noise_intensity;
	
	vec2 blur_offset = vec2(0.0018, 0.0018);
	vec3 sample_r = texture(screen_texture, screen_mapped_uv + vec2(blur_offset.x, 0.0)).rgb;
	vec3 sample_l = texture(screen_texture, screen_mapped_uv - vec2(blur_offset.x, 0.0)).rgb;
	vec3 sample_d = texture(screen_texture, screen_mapped_uv + vec2(0.0, blur_offset.y)).rgb;
	vec3 sample_u = texture(screen_texture, screen_mapped_uv - vec2(0.0, blur_offset.y)).rgb;
	
	// Run them through the luminance extractor so the background returns pure black (0.0)
	vec3 glow_r = extract_bright_text(sample_r);
	vec3 glow_l = extract_bright_text(sample_l);
	vec3 glow_d = extract_bright_text(sample_d);
	vec3 glow_u = extract_bright_text(sample_u);
	
	// Average only the isolated bright text pixels together
	vec3 isolated_text_blur = (glow_r + glow_l + glow_d + glow_u) * 0.25;
	
	// Layer the safe text blur directly onto the final frame
	vec3 glowing_rgb = final_rgb + (isolated_text_blur * glow_intensity);
	
	float vignette = distorted_uv.x * distorted_uv.y * (1.0 - distorted_uv.x) * (1.0 - distorted_uv.y);
	vignette = clamp(pow(16.0 * vignette, vignette_intensity), 0.0, 1.0);
	
	vec3 composite_rgb = mix(vignette_colour.rgb, glowing_rgb, vignette);
	COLOR = vec4(composite_rgb, max(color.a, scanline_opacity * (1.0 - scanline)));
	}
	
	
}