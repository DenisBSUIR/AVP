#include <iostream>
#include <vector>
#include <algorithm>

using namespace std;

unsigned char* transform_img(const unsigned char* img, const int width, const int height) {
	unsigned char* mod_img;

	mod_img = new unsigned char[width * height];

	for (int i = 0; i < width; i++) {
		mod_img[i] = 0;
		mod_img[(height - 1) * width + i] = 0;
	}

	for (int i = 1; i < height - 1; i++) {
		mod_img[i * width] = 0;
		mod_img[(i + 1) * width - 1] = 0;
	}

	int idx = 0;
	for (int i = 1; i < height - 1; i++) {
		for (int j = 1; j < width - 1; j++) {
			mod_img[i * width + j] = img[idx++];
		}
	}

	return mod_img;
}

unsigned char* prepare_img_for_gpu(const unsigned char* img, const int mod_width_gpu, const int mod_height_gpu, const int width, const int height) {
	unsigned char* mod_img = (unsigned char*)calloc(mod_width_gpu * mod_height_gpu, sizeof(char));

	for (int i = 0; i < height; i++) {
		for (int j = 0; j < width; j++) {
			mod_img[(i + 1) * mod_width_gpu + j + 1] = img[i * width + j];
		}
	}
	return mod_img;
}


void cpu_filter(const unsigned char* img, unsigned char* result_img, const int width, const int height) {
	vector<char> neighbors(9);
	for (int i = 1; i < height - 1; i++) {
		for (int j = 1; j < width - 1; j++) {
			neighbors[0] = img[(i - 1) * width + (j - 1)];
			neighbors[1] = img[(i - 1) * width + j];
			neighbors[2] = img[(i - 1) * width + (j + 1)];
			neighbors[3] = img[i * width + (j - 1)];
			neighbors[4] = img[i * width + j];
			neighbors[5] = img[i * width + (j + 1)];
			neighbors[6] = img[(i + 1) * width + (j - 1)];
			neighbors[7] = img[(i + 1) * width + j];
			neighbors[8] = img[(i + 1) * width + (j + 1)];

			auto min = min_element(neighbors.begin(), neighbors.end());
			result_img[i * width + j] = *min;

			//for (auto& element : neighbors) {
			//	cout << (int)element << endl;
			//}
		}
	}
}

unsigned char* remove_padding(const unsigned char* mod_img, const int width, const int height, const int mod_width){

	unsigned char *result_img;

	result_img = new unsigned char[width * height];

	for (int i = 0; i < height; i++) {
		for (int j = 0; j < width; j++) {
			result_img[i * width + j] = mod_img[(i + 1) * mod_width + j + 1];
		}
	}
	return result_img;
}

bool is_equals(const unsigned char* cpu_img, const unsigned char* gpu_img, const int width, const int height) {
	for (int i = 0; i < width * height; i++) {
		if (cpu_img[i] != gpu_img[i])
			return false;
	}
	return true;
}

void show_matrix(const unsigned char* img, const int width, const int height) {
	for (int i = 0; i < height; i++) {
		for (int j = 0; j < width; j++) {
			cout << (int)img[i * width + j] << " ";
		}
		cout << endl;
	}
}