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

out VERTEX {
	smooth vec3 position;
	smooth vec3 normal;
	smooth vec3 tangent;
    smooth vec3 bitangent;
	smooth vec2 texCoord;
	smooth vec4 color;
	smooth vec3 eyes;
	smooth vec4 lightDirection[MAX_LIGHT_SOURCES];
} vertex_out;

uniform mat3 normalMatrix;
uniform bool useObjectSpace;
mat3 OLM;
vec4 getLightDirection(vec4 pos, mat4 M, in LightSource light){
	vec4 direction = vec4(0);
	if(light.position.w == 0){	// directional light
		if(light.transform){
			direction = M * light.position;
		}
		direction = light.position;
	}
	else{	// positional light
		vec4 lightPos = (light.position/light.position.w);
		if(light.transform){
			direction = (M*light.position) - pos;
		}else{
			direction = light.position - pos;
		}
	}
	return normalize(vec4( OLM * direction.xyz, 1.0));
}
void applyLight(mat4 MV, mat4 V, vec3 position, vec3 normal, vec3 tangent, vec3 bitangent){
	vec3 n = normalize(normalMatrix * normal);
	vec3 t = normalize(normalMatrix * tangent);
	vec3 b = normalize(normalMatrix * bitangent);
	vertex_out.normal = normalize(normalMatrix * normal);
	vec4 pos = MV * vec4(position, 1);
	vertex_out.position = pos.xyz;
	
	OLM = !lightModel.useObjectSpace ? mat3(1) : mat3(t.x, b.x, n.x, t.y, b.y, n.y, t.z, b.z, n.z);
	for(int i = 0; i < light.length(); i++){
		vertex_out.lightDirection[i] = getLightDirection(pos, V, light[i]);
	}
	vertex_out.eyes =  OLM * (lightModel.localViewer ? normalize(-pos.xyz) : vec3(0, 0, 1));
}

layout(location=0) in vec3 position;
layout(location=1) in vec3 normal;
layout(location=2) in vec3 tangent;
layout(location=3) in vec3 bitangent;
layout(location=4) in vec4 color;
layout(location=5) in vec2 uv;
uniform mat4 V;
uniform mat4 MV;
uniform mat4 MVP;
uniform float scale = 0.2;
smooth out vec3 vTexPos;
void main(){
	vTexPos = position * scale;
	applyLight(MV, V, position, normal, tangent, bitangent);
	gl_Position = MVP * vec4(position, 1);
}

