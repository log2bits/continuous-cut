shader_type canvas_item;

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
    vec4 col = COLOR;
    float alpha = (1.0 - abs(UV.x * 2.0 - 1.0)) * 0.5;
    float threshold = bayer4(FRAGCOORD.xy);
    col.a *= step(threshold, alpha);
    COLOR = col;
}