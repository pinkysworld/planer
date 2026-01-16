shader_type canvas_item;

// Weather overlay shader (rain, snow, fog)
uniform int weather_type = 0; // 0=none, 1=rain, 2=snow, 3=fog
uniform float intensity : hint_range(0.0, 1.0) = 0.5;
uniform float time : hint_range(0.0, 1000.0) = 0.0;
uniform vec2 wind_direction = vec2(0.1, 1.0);

// Noise function for weather effects
float random(vec2 st) {
    return fract(sin(dot(st.xy, vec2(12.9898,78.233))) * 43758.5453123);
}

// Rain effect
vec4 rain_effect(vec2 uv, float t) {
    vec2 rain_uv = uv * vec2(20.0, 30.0);
    rain_uv.y += t * 2.0;
    rain_uv.x += sin(t + uv.y * 10.0) * 0.1;

    float rain = random(floor(rain_uv));
    rain = smoothstep(0.95, 1.0, rain);

    return vec4(0.7, 0.8, 1.0, rain * intensity * 0.3);
}

// Snow effect
vec4 snow_effect(vec2 uv, float t) {
    vec2 snow_uv = uv * vec2(15.0, 20.0);
    snow_uv.y += t * 0.5;
    snow_uv.x += sin(t * 0.5 + uv.y * 5.0) * 0.3;

    float snow = random(floor(snow_uv));
    snow = smoothstep(0.9, 1.0, snow);

    // Add some variation in size
    float size_var = random(floor(snow_uv) + vec2(0.5));
    snow *= mix(0.5, 1.0, size_var);

    return vec4(1.0, 1.0, 1.0, snow * intensity * 0.5);
}

// Fog effect
vec4 fog_effect(vec2 uv, float t) {
    vec2 fog_uv = uv * 3.0;
    fog_uv.x += t * 0.05;

    float fog = random(floor(fog_uv));
    fog += random(floor(fog_uv + vec2(1.0, 0.0))) * 0.5;
    fog = fog / 1.5;

    // Add some movement
    fog += sin(uv.y * 10.0 + t * 0.5) * 0.1;

    return vec4(0.8, 0.8, 0.9, fog * intensity * 0.4);
}

void fragment() {
    vec4 color = texture(TEXTURE, UV);
    vec4 weather = vec4(0.0);

    if (weather_type == 1) {
        weather = rain_effect(UV, time);
    } else if (weather_type == 2) {
        weather = snow_effect(UV, time);
    } else if (weather_type == 3) {
        weather = fog_effect(UV, time);
    }

    // Blend weather with scene
    color.rgb = mix(color.rgb, weather.rgb, weather.a);

    COLOR = color;
}
