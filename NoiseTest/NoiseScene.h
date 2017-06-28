#pragma once

#include <ncl/gl/Scene.h>
#include <ncl/gl/textures.h>
#include <ncl/gl/Camera2.h>

using namespace std;
using namespace glm;
using namespace ncl::gl;

const string parent = "..\\shaders\\";
const string vertex_shader_loc = parent + "shader.vert";
const string fragment_shader_loc = parent + "shader.frag";

struct {
	float pos[4] = { 1, 0.f, 0.f, 1 };
	float diff[4] = { 1, 1, 1, 1 };
	float spec[4] = { 1, 1, 1, 1 };
} slight;

class NoiseScene : public Scene {
public:
	NoiseScene() :Scene("Box Scene") {
		angle = 0;
		_useImplictShaderLoad = true;
		_shader.storePreprocessedShaders(true);
		
	}

	virtual void init() override {
		
		light[0].on = true;
		light[0].position = { 1.0, 1.25, 1.25f , 1 };
	//	texture = new NoiseTex3D();
	//	_shader.sendUniform1ui("noise", texture->id());
		_shader.sendUniform1f("line.width", 0.05);
		_shader.sendUniform4f("line.color", 0, 0, 0, 1);
		_shader.sendUniform1i("wireframe", false);
		_shader.sendUniformMatrix4fv("viewport", 1, GL_FALSE, value_ptr(getViewport()));
	
		mat4 mat = translate(mat4(1), { 1, -0.5, 0 });
		teapot = new Teapot(10, true, mat);

		Material& m = teapot->material();
		m.ambient = m.diffuse = m.specular = vec4(1);
		m.shininess = 20;
		sphere = new Sphere(0.5, 20, 250);

		cam.view = lookAt({ 1.0, 1.25, 0.5f }, vec3(0), { 0, 1, 0 });
		camera.setMode(Camera2::SPECTATOR);
		camera.lookAt({ 1.0, 1.25, 0.5f }, vec3(0), { 0, 1, 0 });

	}

	virtual void resized() override {
		camera.perspective(60, aspectRatio, 0.3, 100.0f);
		cam.projection = perspective(radians(60.0f), aspectRatio, 0.3f, 100.0f);
	}

	virtual void display() override {
		camera.lookAt({ 1.0, 1.25, 0.5f }, vec3(0), { 0, 1, 0 });
		mat4 mat = mat4(1); // rotate(mat4(1), radians(angle), { 0, 1, 0 });
	//	cam.model = mat;
		_shader.send(camera, mat);
	//	cam.model = rotate(mat4(1), radians(angle), { 0, 1, 0 });
		teapot->draw(_shader);
		//sphere->draw(shader);
	}

	virtual void update(float dt) override {
		angle += dt * 20;
		if (angle >= 360) angle -= 360;
	}

private:
	NoiseTex3D* texture;
	Teapot* teapot;
	Sphere* sphere;
	Camera2 camera;
	float angle;
};