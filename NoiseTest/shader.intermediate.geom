#version 450 core
#pragma debug(on)
#pragma optimize(off)
const int MAX_LIGHT_SOURCES = 10;
const float PI = 3.14159265359;

in VERTEX{
	smooth vec3 position;
	smooth vec3 normal;
	smooth vec3 tangent;
    smooth vec3 bitangent;
	smooth vec2 texCoord;
	smooth vec4 color;
	smooth vec3 eyes;
	smooth vec4 lightDirection[MAX_LIGHT_SOURCES];
} vertex_in[];

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

noperspective out vec3 edgeDistance;
uniform mat4 viewport;
void calculateWireframe(out float ha, out float hb, out float hc){
	vec3 p0 = (viewport * (gl_in[0].gl_Position / gl_in[0].gl_Position.w)).xyz;
	vec3 p1 = (viewport * (gl_in[1].gl_Position / gl_in[1].gl_Position.w)).xyz;
	vec3 p2 = (viewport * (gl_in[2].gl_Position / gl_in[2].gl_Position.w)).xyz;
	// find the altitudes (ha, hb, hc)
	float a = distance(p1, p2);
	float b = distance(p2, p0);
	float c = distance(p1, p0);
	float alpha = acos((b*b + c*c - a*a) / (2.0*b*c));
	float beta = acos((a*a + c*c - b*b) / (2.0*a*c));
	ha = abs( c * sin(beta));
	hb = abs( c * sin(alpha));
	hc = abs(b * sin(alpha));
}

layout( triangles ) in;
layout( triangle_strip, max_vertices = 3) out;
smooth in vec3 vTexPos[];
smooth out vec3 gTexPos;
void transferVertexData(int i){
	vertex_out.position = vertex_in[i].position;
	vertex_out.normal = vertex_in[i].normal;
	vertex_out.texCoord = vertex_in[i].texCoord;
	vertex_out.eyes = vertex_in[i].eyes;
	vertex_out.color = vertex_in[i].color;
	gTexPos = vTexPos[i];
	gl_Position = gl_in[i].gl_Position;	
	for(int j = 0; j < MAX_LIGHT_SOURCES; j++){
		vertex_out.lightDirection[j] = vertex_in[i].lightDirection[j];
	}
}
void main(){
	float ha, hb, hc;
	calculateWireframe(ha, hb, hc);
	edgeDistance = vec3(ha, 0, 0);
	transferVertexData(0);
	EmitVertex();
	
	edgeDistance = vec3(0, hb, 0);
	transferVertexData(1);
	EmitVertex();
	
	edgeDistance = vec3(0, 0, hc);
	transferVertexData(2);
	EmitVertex();
}

