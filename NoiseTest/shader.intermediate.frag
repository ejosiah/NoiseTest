#version 450 core
#pragma debug(on)
#pragma optimize(off)
const int MAX_LIGHT_SOURCES = 10;
const float PI = 3.14159265359;

struct LightSource{
	vec4 position;
	vec4 ambient;
	vec4 diffuse;
	vec4 specular;
	vec4 spotDirection;
	float spotAngle;
	float spotExponent;
	float kc;
	float ki;
	float kq;
	bool transform;
	bool on;
};
struct LightModel {
	bool localViewer;
	bool twoSided;
	bool useObjectSpace;
	bool celShading;
	vec4 globalAmbience;
	bool colorMaterial;
};
struct Material{
	vec4 emission;
	vec4 ambient;
	vec4 diffuse;
	vec4 specular;
	float shininess;
	int diffuseMat;
	int specularMat;
	int ambientMat;
	int bumpMap;
};
uniform LightSource light[MAX_LIGHT_SOURCES];
uniform LightModel lightModel;
uniform Material material[2];

in VERTEX{
	smooth vec3 position;
	smooth vec3 normal;
	smooth vec3 tangent;
    smooth vec3 bitangent;
	smooth vec2 texCoord;
	smooth vec4 color;
	smooth vec3 eyes;
	smooth vec4 lightDirection[MAX_LIGHT_SOURCES];
} vertex_in;

layout(binding=3) uniform sampler2D normalMap;
vec4 getAmbience(Material m);
vec4 getDiffuse(Material m);
vec4 diffuseContrib(vec3 L, vec3 N, LightSource light, Material m);
float daf(float dist, LightSource light){
	return 1.0 / (light.kc + light.ki * dist + light.kq * dist * dist);
}
float saf(LightSource light, vec3 lightDirection, mat4 M){
	vec3 l = normalize(lightDirection);
	vec3 d =   normalize(mat3(M) * light.spotDirection.xyz);
	float h = light.spotExponent;
	
	if(light.spotAngle >= 180) 	return 1.0;
	
	float _LdotD = dot(-l, d);
	float cos_spotAngle = cos(radians(light.spotAngle));
	
	if(_LdotD < cos_spotAngle) return 0.0;
	
	return pow(_LdotD, h); 
}
vec4 apply(LightSource light, vec4 direction, Material m, mat4 M){
	if(!light.on) return vec4(0);
	vec3 n = gl_FrontFacing ? normalize(vertex_in.normal) : normalize(-vertex_in.normal);
	vec3 N = lightModel.useObjectSpace ? (2.0 * texture(normalMap, vertex_in.texCoord) - 1.0).xyz : n;
	vec3 L = normalize(direction.xyz);
	float f = m.shininess;
		
	float _daf = daf(length(L), light);
	float _saf = saf(light, L, M);
	
	vec4 ambient = light.ambient * m.ambient;
	
	vec4 diffuse =  diffuseContrib(L, N, light, m);
	
	vec3 E = normalize(vertex_in.eyes);
	vec3 S = normalize(L + E);	// half way vector between light direction and eyes
	vec4 specular = pow(max(dot(S, N), 0), f) * light.specular * m.specular;
	return  _daf * _saf * ((ambient + diffuse) + specular); 
}
vec4 phongLightModel(mat4 M){
	Material m = !lightModel.twoSided ?  material[0] : gl_FrontFacing ? material[0] : material[1];
	vec4 color = m.emission + lightModel.globalAmbience * getAmbience(m);
	for(int i = 0; i < light.length(); i++ ) 
		color += apply(light[i], vertex_in.lightDirection[i], m, M);
	return color;
}
vec4 getAmbience(Material m){
	return lightModel.colorMaterial ? vertex_in.color : m.ambient;
}
vec4 getDiffuse(Material m){
	return lightModel.colorMaterial ? vertex_in.color : m.diffuse;
}

vec4 diffuseContrib(vec3 L, vec3 N, LightSource light, Material m){
	return  max(dot(L, N), 0)  * light.diffuse * getDiffuse(m);
}

struct LineInfo{
	float width;
	vec4 color;
};
uniform LineInfo line;
uniform bool wireframe;
noperspective in vec3 edgeDistance;
float getLineMixColor(){
	float d = min( min(edgeDistance.x, edgeDistance.y), edgeDistance.z);
	return smoothstep(line.width - 1, line.width + 1, d);
}

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

