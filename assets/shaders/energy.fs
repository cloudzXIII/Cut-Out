#if defined(VERTEX) || __VERSION__ > 100 || defined(GL_FRAGMENT_PRECISION_HIGH)
	#define PRECISION highp
#else
	#define PRECISION mediump
#endif

extern PRECISION vec2 energy;
extern PRECISION float dissolve;
extern PRECISION float time;
extern PRECISION vec4 texture_details;
extern PRECISION vec2 image_details;
extern bool shadow;
extern PRECISION vec4 burn_colour_1;
extern PRECISION vec4 burn_colour_2;

vec4 dissolve_mask(vec4 tex, vec2 texture_coords, vec2 uv);

const float CELL_SCALE  = 4.6;
const float CELL_RADIUS = 0.64;
const float GAP         = 0.075;
const float CELL_DARK   = 0.55;
const float VEIN_ALPHA  = 0.92;
const float FLOW_SPEED  = 1.0;

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

vec3 energy_ramp(float h) {
    h = clamp(h, 0.0, 1.0);
    vec3 c0 = vec3(0.30, 0.24, 0.36);
    vec3 c1 = vec3(0.80, 0.12, 0.22);
    vec3 c2 = vec3(1.00, 0.38, 0.06);
    vec3 c3 = vec3(1.00, 0.55, 0.08);
    vec3 c4 = vec3(1.00, 0.70, 0.25);
    if (h < 0.25) return mix(c0, c1, h / 0.25);
    if (h < 0.50) return mix(c1, c2, (h - 0.25) / 0.25);
    if (h < 0.80) return mix(c2, c3, (h - 0.50) / 0.30);
    return mix(c3, c4, (h - 0.80) / 0.20);
}

vec4 effect(vec4 colour, Image texture, vec2 texture_coords, vec2 screen_coords)
{
    vec4 tex = Texel(texture, texture_coords);
    vec2 uv = (((texture_coords)*(image_details))-texture_details.xy*texture_details.ba)/texture_details.ba;
    if (tex.a == 0.0) return vec4(0.0);

    float aspect = texture_details.b / texture_details.a;
    float t = time * FLOW_SPEED;
    float tilt = energy.x;

    vec2 p = vec2((uv.x - 0.5) * aspect, uv.y - 0.5) * CELL_SCALE;
    p += vec2(t * 0.04 + tilt * 0.10, t * 0.03);
    p += (vec2(noise(p * 0.8 + vec2(t * 0.05, 0.0)),
               noise(p * 0.8 + vec2(19.0, -t * 0.04))) - 0.5) * 0.55;

    vec2 ip = floor(p);
    vec2 fp = fract(p);
    float d1 = 8.0;
    float d2 = 8.0;
    vec2 id1 = vec2(0.0);
    for (int j = -1; j <= 1; j++) {
        for (int i = -1; i <= 1; i++) {
            vec2 g = vec2(float(i), float(j));
            vec2 rnd = hash2(ip + g);
            vec2 o = 0.5 + 0.32 * sin(t * 0.45 + 6.2831 * rnd);
            vec2 r = g + o - fp;
            float d = dot(r, r);
            if (d < d1) { d2 = d1; d1 = d; id1 = ip + g; }
            else if (d < d2) { d2 = d; }
        }
    }
    float r1 = sqrt(d1);
    float e  = sqrt(d2) - r1;
    float cell_rnd = hash(id1);

    float gap = GAP * (0.75 + 0.6 * noise(p * 0.6 + 3.1));
    float rad = CELL_RADIUS * (0.88 + 0.24 * cell_rnd);
    float inside = smin(e - gap, (rad - r1) * 1.4, 0.16);

    float vein  = 1.0 - smoothstep(0.0, 0.07, inside);
    float rim   = 1.0 - smoothstep(0.0, 0.22, inside);
    float depth = clamp(-inside / gap, 0.0, 1.0);
    float glow  = exp(-max(inside, 0.0) * 7.0);

    float region = noise(p * 0.30 + vec2(4.0, 1.0));
    float travel = 0.5 + 0.5 * sin(t * 1.2 - (p.x + p.y * 0.7) * 1.2 + noise(p * 0.8) * 5.0);
    float heat   = clamp(0.20 + region * 0.60 + travel * 0.16 + 0.06 * sin(tilt * 2.0), 0.0, 1.0);

    vec3 vein_col = energy_ramp(clamp(heat * (0.42 + 0.58 * depth) + depth * 0.06, 0.0, 1.0));
    vein_col += vec3(1.0, 0.75, 0.40) * depth * pow(travel, 8.0) * 0.20;
    vein_col *= 1.0 + 0.05 * sin(t * 5.0 + cell_rnd * 20.0);

    float lum = dot(tex.rgb, vec3(0.299, 0.587, 0.114));
    float protect = mix(0.45, 1.0, smoothstep(0.04, 0.22, lum));

    vec3 rgb = mix(tex.rgb, vec3(0.03, 0.025, 0.03), CELL_DARK);
    rgb += energy_ramp(0.22) * rim * (1.0 - vein) * 0.28;
    rgb += vein_col * glow * 0.05;
    rgb = mix(rgb, vein_col, vein * VEIN_ALPHA * protect);

    tex.rgb = clamp(rgb, 0.0, 1.0);
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