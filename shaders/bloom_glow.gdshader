shader_type canvas_item;

// Bloom/Glow effect for lights and highlights
uniform float bloom_intensity : hint_range(0.0, 2.0) = 0.5;
uniform float bloom_threshold : hint_range(0.0, 1.0) = 0.7;
uniform vec2 blur_size = vec2(1.0, 1.0);

void fragment() {
    vec4 color = texture(TEXTURE, UV);

    // Extract bright areas
    float brightness = dot(color.rgb, vec3(0.299, 0.587, 0.114));

    if (brightness > bloom_threshold) {
        // Simple blur for bloom effect
        vec4 bloom = vec4(0.0);
        int samples = 9;
        float weight = 1.0 / float(samples);

        for(int x = -1; x <= 1; x++) {
            for(int y = -1; y <= 1; y++) {
                vec2 offset = vec2(float(x), float(y)) * blur_size * TEXTURE_PIXEL_SIZE;
                bloom += texture(TEXTURE, UV + offset) * weight;
            }
        }

        color.rgb += bloom.rgb * bloom_intensity;
    }

    COLOR = color;
}
