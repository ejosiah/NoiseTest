#pragma once

#include <ncl/gl/Scene.h>
#include <ncl/gl/textures.h>

using namespace std;
using namespace glm;
using namespace ncl::gl;

const string shader_loc = "D:\\Users\\Josiah\\documents\\visual studio 2015\\Projects\\GLUtil\\GLUtil\\shaders\\";
const string vertex_shader_loc = shader_loc + "noise3d.vert";
const string fragment_shader_loc = shader_loc + "noise3d.frag";

class NoiseScene : public Scene {
public:
	NoiseScene() :Scene("Box Scene", 500, 500) {
		angle = 0;
	/*	_shaders.push_back(vertex_shader_loc);
		_shaders.push_back(fragment_shader_loc);
		_shader.storePreprocessedShaders(true);*/
	}

	virtual void init() override {
		light[0].on = true;
		_shader.sendUniform4f("light.pos", 0, 0, 1, 1);
		_shader.sendUniform4f("light.diff", 1, 1, 1, 1);
		_shader.sendUniform4f("light.spec", 1, 1, 1, 1);

		texture = new NoiseTex2D();
		_shader.sendUniform1ui("noise", texture->id());


		teapot = new Teapot(16);
		sphere = new Sphere(0.5, 20, 250);

		cam.view = lookAt({ 0, 0, 1.25f }, vec3(0), { 0, 1, 0 });

	}

	virtual void resized() override {
		cam.projection = perspective(radians(60.0f), aspectRatio, 0.3f, 100.0f);
	}

	virtual void display() override {
		cam.model = rotate(mat4(1), radians(angle), { 0, 1, 0 });

		_shader.send(cam);
		//teapot->draw(_shader);
		sphere->draw(_shader);
	}

	virtual void update(float dt) override {
		angle += dt * 20;
		if (angle >= 360) angle -= 360;
	}

private:
	NoiseTex2D* texture;
	Teapot* teapot;
	Sphere* sphere;
	float angle;
};