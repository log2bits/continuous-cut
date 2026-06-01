shader_type canvas_item;

uniform vec2 mouse_screen_pos;
uniform float transparency : hint_range(0.0, 1.0) = 0.5;

uniform vec2 viewport_size;
uniform float falloff_scale : hint_range(0.1, 5.0) = 1.0;


float bayer4(vec2 pos) {
    int x = int(mod(pos.x, 4.0));
    int y = int(mod(pos.y, 4.0));
    int index = x + y * 4;
    float matrix[16] = float[](
        0.0,  8.0,  2.0, 10.0,
        12.0,  4.0, 14.0,  6.0,
        3.0, 11.0,  1.0,  9.0,
        15.0,  7.0, 13.0,  5.0
    );
    return matrix[index] / 16.0;
}

void fragment() {
    vec4 col = texture(TEXTURE, UV);
    float radius = length(mouse_screen_pos - vec2(viewport_size * 0.5));
    float dist = distance(FRAGCOORD.xy, mouse_screen_pos);
    float alpha = (1.0 - clamp(dist / (radius * falloff_scale), 0.0, 1.0)) * (1.0 - transparency);
    if (alpha <= 0.0) {
        discard;
    }
    float threshold = bayer4(FRAGCOORD.xy);
    col.a = col.a * step(threshold, alpha);
    COLOR = col;
}