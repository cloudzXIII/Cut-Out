#if defined(VERTEX) || __VERSION__ > 100 || defined(GL_FRAGMENT_PRECISION_HIGH)
	#define PRECISION highp
#else
	#define PRECISION mediump
#endif

extern PRECISION vec2 abstract;
extern PRECISION float dissolve;
extern PRECISION float time;
extern PRECISION vec4 texture_details;
extern PRECISION vec2 image_details;
extern bool shadow;
extern PRECISION vec4 burn_colour_1;
extern PRECISION vec4 burn_colour_2;

vec4 dissolve_mask(vec4 tex, vec2 texture_coords, vec2 uv);

const float BANDS       = 13.0;
const float FIELD_SCALE = 2.6;
const float PULSE       = 0.07;
const float ART_VISIBLE = 0.30;

const vec3 NAVY = vec3(0.11, 0.12, 0.22);
const vec3 PINK = vec3(1.00, 0.27, 0.52);

float hash(vec2 p) { return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453); }
vec2 hash2(vec2 p) { return vec2(hash(p), hash(p + vec2(37.7, 91.3))); }
float noise(vec2 p) {
    vec2 i = floor(p); vec2 f = fract(p);
    f = f * f * (3.0 - 2.0 * f);
    return mix(mix(hash(i), hash(i + vec2(1.0, 0.0)), f.x),
               mix(hash(i + vec2(0.0, 1.0)), hash(i + vec2(1.0, 1.0)), f.x), f.y);
}
float fbm(vec2 p) {
    float v = noise(p);
    v += noise(p * 2.03 + vec2(1.7, 9.2)) * 0.30;
    v += noise(p * 4.11 + vec2(8.3, 2.8)) * 0.09;
    return v / 1.39;
}

float abstract_field(vec2 p, float t) {
    vec2 q = vec2(noise(p * 0.9 + vec2(t * 0.05, 1.7)),
                  noise(p * 0.9 + vec2(8.3, 2.8 - t * 0.04)));
    return fbm(p + (q - 0.5) * 2.4 + vec2(t * 0.03, -t * 0.02));
}

float abstract_c(vec2 p, float t, float beat) {
    return abstract_field(p, t) * BANDS * (1.0 + PULSE * beat);
}

vec4 effect(vec4 colour, Image texture, vec2 texture_coords, vec2 screen_coords)
{
    vec4 tex = Texel(texture, texture_coords);
    vec2 uv = (((texture_coords)*(image_details))-texture_details.xy*texture_details.ba)/texture_details.ba;
    if (tex.a == 0.0) return vec4(0.0);

    vec2 floored_uv = floor(uv * texture_details.ba) / texture_details.ba;
    float aspect = texture_details.b / texture_details.a;
    float t = time;
    float tilt = abstract.x;
    float beat = sin(t * 1.3);

    vec2 q = vec2(floored_uv.x * aspect, floored_uv.y);
    vec2 p = q * FIELD_SCALE + vec2(tilt * 0.10, 0.0);

    float c    = abstract_c(p, t, beat);
    float cx   = abstract_c(p + vec2(0.03, 0.0), t, beat);
    float cy   = abstract_c(p + vec2(0.0, 0.03), t, beat);
    float grad = max(length(vec2(cx - c, cy - c)) / 0.03, 0.05);
    float cs   = abstract_c(p - vec2(0.09, 0.13), t, beat);

    float s_main = min(fract(c),  1.0 - fract(c))  / grad;
    float s_shad = min(fract(cs), 1.0 - fract(cs)) / grad;

    float wv = 0.65 + 0.95 * noise(p * 1.4 + vec2(3.0, t * 0.1));
    float wn = 0.040 * wv;
    float wp = 0.026;
    float aa = 0.016;

    vec3 col = mix(vec3(0.20, 0.93, 0.45), vec3(0.10, 0.72, 0.74),
                   smoothstep(0.10, 0.95, floored_uv.y * 0.9 + floored_uv.x * 0.15));

    float shad = 1.0 - smoothstep(wn + wp - aa, wn + wp + aa, s_shad);
    col = mix(col, col * vec3(0.42, 0.60, 0.58), shad * 0.9);
    col = mix(col, PINK, 1.0 - smoothstep(wn + wp - aa, wn + wp + aa, s_main));
    col = mix(col, NAVY, 1.0 - smoothstep(wn - aa, wn + aa, s_main));
    col = mix(col, PINK, (1.0 - smoothstep(0.010, 0.022, s_main)) * smoothstep(0.045, 0.065, wn));

    for (int i = 0; i < 5; i++) {
        float fi = float(i);
        vec2 h = hash2(vec2(fi * 1.7, 4.3));
        vec2 c0 = vec2(h.x * aspect, h.y) + vec2(sin(t * 0.35 + fi * 2.3), cos(t * 0.28 + fi * 1.9)) * 0.06;
        float r = (0.06 + 0.07 * hash(vec2(fi, 9.1))) * (1.0 + 0.08 * beat);
        float circle = 1.0 - smoothstep(r - 0.012, r, length(q - c0));
        col = mix(col, vec3(1.0, 0.30, 0.50), circle * 0.58);
    }

    for (int i = 0; i < 8; i++) {
        float fi = float(i);
        vec2 h = hash2(vec2(fi * 2.9, 1.3));
        vec2 c0 = vec2(h.x * aspect, h.y) + vec2(cos(t * 0.5 + fi * 1.3), sin(t * 0.42 + fi * 2.7)) * 0.04;
        float r = 0.012 + 0.016 * hash(vec2(fi, 5.5));
        col = mix(col, NAVY, 1.0 - smoothstep(r - 0.006, r, length(q - c0)));
    }

    float lum = dot(tex.rgb, vec3(0.299, 0.587, 0.114));
    col *= mix(1.0, 0.55 + 0.9 * lum, ART_VISIBLE);

    tex.rgb = clamp(col, 0.0, 1.0);
    return dissolve_mask(tex * colour, texture_coords, uv);
}

vec4 dissolve_mask(vec4 tex, vec2 texture_coords, vec2 uv)
{
    if (dissolve < 0.001) {
        return vec4(shadow ? vec3(0.,0.,0.) : tex.xyz, shadow ? tex.a*0.3: tex.a);
    }
    float adjusted_dissolve = (dissolve*dissolve*(3.-2.*dissolve))*1.02 - 0.01;
    float t = time * 10.0 + 2003.;
    vec2 floored_uv = (floor((uv*texture_details.ba)))/max(texture_details.b, texture_details.a);
    vec2 uv_scaled_centered = (floored_uv - 0.5) * 2.3 * max(texture_details.b, texture_details.a);
    vec2 field_part1 = uv_scaled_centered + 50.*vec2(sin(-t/143.6340), cos(-t/99.4324));
    vec2 field_part2 = uv_scaled_centered + 50.*vec2(cos( t/53.1532),  cos( t/61.4532));
    vec2 field_part3 = uv_scaled_centered + 50.*vec2(sin(-t/87.53218), sin(-t/49.0000));
    float field = (1.+(cos(length(field_part1)/19.483)+sin(length(field_part2)/33.155)*cos(field_part2.y/15.73)+cos(length(field_part3)/27.193)*sin(field_part3.x/21.92)))/2.;
    vec2 borders = vec2(0.2, 0.8);
    float res = (.5+.5*cos((adjusted_dissolve)/82.612+(field+-.5)*3.14))
    -(floored_uv.x>borders.y?(floored_uv.x-borders.y)*(5.+5.*dissolve):0.)*(dissolve)
    -(floored_uv.y>borders.y?(floored_uv.y-borders.y)*(5.+5.*dissolve):0.)*(dissolve)
    -(floored_uv.x<borders.x?(borders.x-floored_uv.x)*(5.+5.*dissolve):0.)*(dissolve)
    -(floored_uv.y<borders.x?(borders.x-floored_uv.y)*(5.+5.*dissolve):0.)*(dissolve);
    if (tex.a>0.01&&burn_colour_1.a>0.01&&!shadow&&res<adjusted_dissolve+0.8*(0.5-abs(adjusted_dissolve-0.5))&&res>adjusted_dissolve) {
        if (!shadow&&res<adjusted_dissolve+0.5*(0.5-abs(adjusted_dissolve-0.5))&&res>adjusted_dissolve) {
            tex.rgba = burn_colour_1.rgba;
        } else if (burn_colour_2.a > 0.01) { tex.rgba = burn_colour_2.rgba; }
    }
    return vec4(shadow?vec3(0.,0.,0.):tex.xyz, res>adjusted_dissolve?(shadow?tex.a*0.3:tex.a):.0);
}

extern PRECISION vec2 mouse_screen_pos;
extern PRECISION float hovering;
extern PRECISION float screen_scale;

#ifdef VERTEX
vec4 position(mat4 transform_projection, vec4 vertex_position)
{
    if (hovering <= 0.) { return transform_projection * vertex_position; }
    float mid_dist = length(vertex_position.xy - 0.5*love_ScreenSize.xy)/length(love_ScreenSize.xy);
    vec2 mouse_offset = (vertex_position.xy - mouse_screen_pos.xy)/screen_scale;
    float scale = 0.2*(-0.03-0.3*max(0.,0.3-mid_dist))*hovering*(length(mouse_offset)*length(mouse_offset))/(2.-mid_dist);
    return transform_projection * vertex_position + vec4(0,0,0,scale);
}
#endif