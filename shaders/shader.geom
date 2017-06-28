#version 450 core
#pragma debug(on)
#pragma optimize(off)

#pragma include("constants.glsl")
#pragma include("vertex_in_array.glsl")
#pragma include("vertex_out.glsl")
#pragma include("wireframe_geom.glsl")

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
