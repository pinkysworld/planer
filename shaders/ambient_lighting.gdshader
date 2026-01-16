shader_type canvas_item;

// Ambient lighting shader for day/night cycle
uniform vec4 ambient_color : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform float ambient_intensity : hint_range(0.0, 1.0) = 1.0;
uniform float time_of_day : hint_range(0.0, 1.0) = 0.5;
uniform bool enable_vignette = true;
uniform float vignette_intensity : hint_range(0.0, 1.0) = 0.3;

vec3 get_time_color(float tod) {
    // Dawn (5-7): Orange/Pink
    if (tod >= 0.2 && tod < 0.29) {
        float t = (tod - 0.2) / 0.09;
        return mix(vec3(0.3, 0.3, 0.5), vec3(1.0, 0.7, 0.5), t);
    }
    // Day (7-18): Bright
    else if (tod >= 0.29 && tod < 0.75) {
        return vec3(1.0, 1.0, 1.0);
    }
    // Dusk (18-20): Orange/Red
    else if (tod >= 0.75 && tod < 0.83) {
        float t = (tod - 0.75) / 0.08;
        return mix(vec3(1.0, 1.0, 1.0), vec3(1.0, 0.6, 0.4), t);
    }
    // Night (20-5): Blue
    else {
        return vec3(0.4, 0.4, 0.6);
    }
}

void fragment() {
    vec4 color = texture(TEXTURE, UV);

    // Apply time-based ambient lighting
    vec3 time_color = get_time_color(time_of_day);
    color.rgb *= time_color * ambient_color.rgb * ambient_intensity;

    // Add vignette effect
    if (enable_vignette) {
        vec2 center = UV - vec2(0.5);
        float dist = length(center);
        float vignette = 1.0 - smoothstep(0.3, 0.9, dist) * vignette_intensity;
        color.rgb *= vignette;
    }

    COLOR = color;
}
