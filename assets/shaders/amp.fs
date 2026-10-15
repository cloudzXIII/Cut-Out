#if defined(VERTEX) || __VERSION__ > 100 || defined(GL_FRAGMENT_PRECISION_HIGH)
	#define PRECISION highp
#else
	#define PRECISION mediump
#endif

extern PRECISION vec2 amp;
extern PRECISION float dissolve;
extern PRECISION float time;
extern PRECISION vec4 texture_details;
extern PRECISION vec2 image_details;
extern bool shadow;
extern PRECISION vec4 burn_colour_1;
extern PRECISION vec4 burn_colour_2;

vec4 dissolve_mask(vec4 tex, vec2 texture_coords, vec2 uv);

const float BANDS       = 9.0;
const float PULSE       = 0.05;
const float FLOW_SPEED  = 1.0;
const float BG_ALPHA    = 0.30;
const float LINE_ALPHA  = 0.90;
const float BLOB_ALPHA  = 0.38;

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
float smin(float a, float b, float k) {
    float h = max(k - abs(a - b), 0.0) / k;
    return min(a, b) - h * h * k * 0.25;
}

float amp_lamp(vec2 p, float t, float aspect) {
    float d = 10.0;
    for (int i = 0; i < 7; i++) {
        float fi = float(i);
        vec2 h = hash2(vec2(fi * 3.1, 2.7));
        float spd = 0.16 + 0.20 * h.x;
        vec2 c = vec2(aspect * (0.5 + 0.40 * sin(t * spd * 0.8 + fi * 2.4)),
                      0.5 + 0.60 * sin(t * spd + fi * 2.6));
        float r = 0.07 + 0.09 * h.y;
        d = smin(d, length(p - c) - r, 0.20);
    }
    return d;
}

vec4 effect(vec4 colour, Image texture, vec2 texture_coords, vec2 screen_coords)
{
    vec4 tex = Texel(texture, texture_coords);
    vec2 uv = (((texture_coords)*(image_details))-texture_details.xy*texture_details.ba)/texture_details.ba;
    if (tex.a == 0.0) return vec4(0.0);

    float aspect = texture_details.b / texture_details.a;
    float t = time * FLOW_SPEED;
    float tilt = amp.x;
    float beat = sin(t * 1.3);

    vec2 q = vec2(uv.x * aspect, uv.y);
    vec2 p = q + vec2(tilt * 0.015, 0.0);
    p += 0.035 * vec2(sin(p.y * 8.0 + t * 0.5), cos(p.x * 7.0 - t * 0.45));
    float nz = 0.07 * (noise(p * 4.0 + vec2(t * 0.08, 0.0)) - 0.5);

    float k  = BANDS * (1.0 + PULSE * beat);
    float c  = (amp_lamp(p, t, aspect) + nz) * k - t * 0.12;
    float cs = (amp_lamp(p - vec2(0.012, 0.020), t, aspect) + nz) * k - t * 0.12;

    float s_main = min(fract(c),  1.0 - fract(c))  / BANDS;
    float s_shad = min(fract(cs), 1.0 - fract(cs)) / BANDS;

    float wv = 0.65 + 0.95 * noise(p * 3.0 + vec2(3.0, t * 0.1));
    float wn = 0.013 * wv;
    float wp = 0.007;
    float aa = 0.003;

    vec3 fx = mix(vec3(0.20, 0.93, 0.45), vec3(0.10, 0.72, 0.74),
                  smoothstep(0.10, 0.95, uv.y * 0.9 + uv.x * 0.15));
    float a = BG_ALPHA;

    float shad = 1.0 - smoothstep(wn + wp - aa, wn + wp + aa, s_shad);
    fx = mix(fx, fx * vec3(0.42, 0.60, 0.58), shad * 0.9);
    a  = mix(a, 0.55, shad * 0.8);

    float ring = 1.0 - smoothstep(wn + wp - aa, wn + wp + aa, s_main);
    fx = mix(fx, PINK, ring);
    a  = mix(a, LINE_ALPHA, ring);

    float navy = 1.0 - smoothstep(wn - aa, wn + aa, s_main);
    fx = mix(fx, NAVY, navy);
    a  = mix(a, LINE_ALPHA, navy);

    float cl = (1.0 - smoothstep(0.0025, 0.0055, s_main)) * smoothstep(0.015, 0.022, wn);
    fx = mix(fx, PINK, cl);

    for (int i = 0; i < 4; i++) {
        float fi = float(i);
        vec2 h = hash2(vec2(fi * 1.7, 4.3));
        vec2 c0 = vec2(aspect * (0.15 + 0.7 * h.x) + 0.05 * sin(t * 0.30 + fi * 2.3),
                       0.5 + 0.42 * sin(t * (0.10 + 0.08 * h.y) + fi * 2.9));
        float r = (0.06 + 0.06 * hash(vec2(fi, 9.1))) * (1.0 + 0.08 * beat);
        float circle = 1.0 - smoothstep(r - 0.006, r + 0.002, length(q - c0));
        fx = mix(fx, vec3(1.0, 0.30, 0.50), circle * 0.65);
        a  = max(a, BLOB_ALPHA * circle);
    }

    for (int i = 0; i < 6; i++) {
        float fi = float(i);
        vec2 h = hash2(vec2(fi * 2.9, 1.3));
        vec2 c0 = vec2(h.x * aspect, h.y) + vec2(cos(t * 0.3 + fi * 1.3), sin(t * 0.26 + fi * 2.7)) * 0.04;
        float r = 0.006 + 0.008 * hash(vec2(fi, 5.5));
        float dotm = 1.0 - smoothstep(r - 0.002, r + 0.001, length(q - c0));
        fx = mix(fx, NAVY, dotm);
        a  = mix(a, LINE_ALPHA, dotm);
    }

    float lum = dot(tex.rgb, vec3(0.299, 0.587, 0.114));
    float protect = mix(0.45, 1.0, smoothstep(0.04, 0.22, lum));

    tex.rgb = clamp(mix(tex.rgb, fx, a * protect), 0.0, 1.0);
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