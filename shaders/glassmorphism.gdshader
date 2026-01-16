shader_type canvas_item;

// Glassmorphism effect for modern UI
uniform vec4 glass_color : source_color = vec4(0.15, 0.2, 0.3, 0.7);
uniform float blur_amount : hint_range(0.0, 10.0) = 3.0;
uniform float border_width : hint_range(0.0, 5.0) = 2.0;
uniform vec4 border_color : source_color = vec4(1.0, 1.0, 1.0, 0.3);
uniform float border_radius : hint_range(0.0, 50.0) = 12.0;
uniform bool enable_gradient = true;
uniform float gradient_intensity : hint_range(0.0, 1.0) = 0.2;
uniform bool enable_noise = true;
uniform float noise_intensity : hint_range(0.0, 0.3) = 0.05;

// Rounded rectangle SDF
float rounded_box_sdf(vec2 center, vec2 size, float radius) {
    return length(max(abs(center) - size + radius, 0.0)) - radius;
}

// Simple noise function
float noise(vec2 uv) {
    return fract(sin(dot(uv, vec2(12.9898, 78.233))) * 43758.5453);
}

void fragment() {
    vec2 uv = UV;
    vec2 size = vec2(0.5);
    vec2 center = uv - size;

    // Calculate distance to rounded rectangle
    float dist = rounded_box_sdf(center, size - border_width / 100.0, border_radius / 100.0);

    // Background blur effect (simplified)
    vec4 blurred = texture(TEXTURE, uv);

    // Apply glass color
    vec4 color = mix(blurred, glass_color, glass_color.a);

    // Add gradient overlay
    if (enable_gradient) {
        float gradient = uv.y * gradient_intensity;
        color.rgb += vec3(gradient);
    }

    // Add subtle noise texture
    if (enable_noise) {
        float n = noise(uv * 100.0);
        color.rgb += vec3(n * noise_intensity);
    }

    // Border
    if (dist > 0.0 && dist < border_width / 100.0) {
        color = mix(color, border_color, border_color.a);
    }

    // Soft edges
    float edge_softness = 0.005;
    float alpha = 1.0 - smoothstep(0.0, edge_softness, dist);

    color.a *= alpha;

    COLOR = color;
}
