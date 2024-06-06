shader_type canvas_item;

uniform vec4 target_color : source_color = vec4(0.2, 0.6, 1.0, 0.1);
uniform float tolerance : hint_range(0.0, 1.0) = 0.05;

void fragment() {
    vec4 tex_color = texture(TEXTURE, UV);
    if (distance(tex_color.rgb, target_color.rgb) < tolerance) {
        discard;
    }
    COLOR = tex_color;
}