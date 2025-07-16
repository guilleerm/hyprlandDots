precision mediump float;
varying vec2 v_texcoord;
uniform sampler2D tex;

void main() {
    vec4 original_color = texture2D(tex, v_texcoord);
    float r = original_color.r * 1.0;  // Rojo (1.0 = sin cambios)
    float g = original_color.g * 0.85;  // Verde (0.9 = 90% de intensidad)
    float b = original_color.b * 0.6;  // Azul (0.6 = 60% de intensidad, reduce significativamente el azul)

    gl_FragColor = vec4(r, g, b, original_color.a);
}
