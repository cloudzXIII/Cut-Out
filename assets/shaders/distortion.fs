#if defined(VERTEX) || __VERSION__ > 100 || defined(GL_FRAGMENT_PRECISION_HIGH)
	#define PRECISION highp
#else
	#define PRECISION mediump
#endif

extern PRECISION vec2 distortion;
extern PRECISION float dissolve;
extern PRECISION float time;
extern PRECISION vec4 texture_details;
extern PRECISION vec2 image_details;
extern bool shadow;
extern PRECISION vec4 burn_colour_1;
extern PRECISION vec4 burn_colour_2;

vec4 dissolve_mask(vec4 tex, vec2 texture_coords, vec2 uv);

const float BANDS       = 7.5;
const float FLOW_SPEED  = 1.0;
const float RED_ALPHA   = 0.58;
const float DARK_ALPHA  = 0.72;

const vec3 RED  = vec3(0.90, 0.10, 0.26);
const vec3 DARK = vec3(0.07, 0.14, 0.18);

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

float distortion_lamp(vec2 p, float t, float aspect) {
    float d = 10.0;
    for (int i = 0; i < 8; i++) {
        float fi = float(i);
        vec2 h = hash2(vec2(fi * 2.3, 6.1));
        float spd = 0.14 + 0.20 * h.x;
        vec2 c = vec2(aspect * (0.5 + 0.45 * sin(t * spd * 0.7 + fi * 1.9)),
                      0.5 + 0.65 * sin(t * spd + fi * 2.1));
        float r = 0.08 + 0.10 * h.y;
        d = smin(d, length(p - c) - r, 0.26);
    }
    return d;
}

float stripe(float c) {
    float tri = abs(fract(c) - 0.5) * 2.0;
    return 1.0 - smoothstep(0.56, 0.62, tri);
}

vec4 effect(vec4 colour, Image texture, vec2 texture_coords, vec2 screen_coords)
{
    vec4 tex = Texel(texture, texture_coords);
    vec2 uv = (((texture_coords)*(image_details))-texture_details.xy*texture_details.ba)/texture_details.ba;
    if (tex.a == 0.0) return vec4(0.0);

    float aspect = texture_details.b / texture_details.a;
    float t = time * FLOW_SPEED;
    float tilt = distortion.x;

    vec2 q = vec2(uv.x * aspect, uv.y);
    vec2 p = q + vec2(tilt * 0.015, 0.0);
    p += 0.045 * vec2(sin(p.y * 7.0 + t * 0.55), cos(p.x * 6.0 - t * 0.5));
    float nz = 0.10 * (noise(p * 3.5 + vec2(t * 0.09, 4.0)) - 0.5);

    float c = (distortion_lamp(p, t, aspect) + nz) * BANDS - t * 0.10;

    float shift = 0.025 + 0.020 * sin(t * 0.8);
    float mr = stripe(c + shift);
    float mg = stripe(c);
    float mb = stripe(c - shift);
    vec3 fx = vec3(mix(DARK.r, RED.r, mr), mix(DARK.g, RED.g, mg), mix(DARK.b, RED.b, mb));

    vec2 gp = floor(uv * texture_details.ba);
    float frame = floor(t * 6.0);
    float dirt   = hash(gp + 13.1) * (0.55 + 0.9 * noise(gp * 0.22 + 4.0));
    float speck  = step(0.90, dirt);
    float dirt2  = hash(gp * 1.7 + vec2(frame * 3.3, 2.0)) * (0.55 + 0.9 * noise(gp * 0.3 + vec2(frame * 0.1, 9.0)));
    float speck2 = step(0.94, dirt2);
    fx = mix(fx, DARK * 1.5, (speck * 0.55 + speck2 * 0.30) * mg);
    fx = mix(fx, RED * 0.55, speck * 0.50 * (1.0 - mg));
    fx *= 0.88 + 0.22 * noise(gp * 0.45 + 20.0);

    float a = mix(DARK_ALPHA, RED_ALPHA, mg);

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