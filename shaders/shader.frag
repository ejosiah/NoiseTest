#version 450 core
#pragma debug(on)
#pragma optimize(off)

#pragma include("lighting.frag.glsl")
#pragma include("ads_diffuse.glsl")
#pragma include("wireframe.glsl")

#define PI 3.14159265

layout(binding = 0) uniform sampler3D noise;

uniform vec4 sky = vec4(0.3, 0.3, 0.9, 1.0);
uniform vec4 cloud = vec4(1.0);
uniform mat4 V;
uniform float bias = 0;

smooth in vec3 gTexPos;
out vec4 fragColor;

vec4 noiseColor(){
	vec4 oct = texture(noise, gTexPos);
	float sum =  (3 * oct.r + oct.g + oct.b + oct.a - 2)/2;
	sum  = (cos(sum * PI) + 1.0)/2.0;
	float t = clamp(bias + sum, 0, 1);
	return vec4(mix(sky, cloud, t).rgb, 1.0);
}

void main(){
	fragColor = phongLightModel(V) * noiseColor();
	fragColor = wireframe ? mix(line.color, fragColor, getLineMixColor()) : fragColor;
}
