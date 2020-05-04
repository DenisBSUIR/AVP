#pragma once

#include "cuda_runtime.h"
#include "device_launch_parameters.h"
#include "helper_image.h"

#include "cpu_functions.h"
#include "gpu_cores.cuh"
#include "constants.h"

using namespace std;

void lab6() {
	char* filename = "JohnWick.ppm";

	unsigned char* img = nullptr;
	unsigned int width = 0, height = 0, channels = 0;

	__loadPPM(filename, &img, &width, &height, &channels);

	cout << filename << ": " << width << " " << height << " " << channels << endl;

	//Выравнивание
	int __width = width, __height = height;

	if (__width % THREADS_X != 0) {
		__width = (__width / THREADS_X + 1) * THREADS_X;
	}

	if (__height % THREADS_Y != 0) {
		__height = (__height / THREADS_Y + 1) * THREADS_Y;
	}

	int mod_width = __width + 2;
	int mod_height = __height + 2;

	unsigned char* mod_img = prepare_img(img, width, height, mod_width, mod_height);

	unsigned char* mod_cpu_result_img = new unsigned char[mod_width * mod_height * 3];

	//Фильтрация
	auto start_cpu = chrono::steady_clock::now();
	cpu_filter_lab6(mod_img, mod_cpu_result_img, mod_width, mod_height);
	auto end_cpu = chrono::steady_clock::now();
	auto cpu_elapsed = end_cpu - start_cpu;

	unsigned char* cpu_result_img = remove_padding_lab6(mod_cpu_result_img, width, height, mod_width);



	//GPU
	unsigned char* gpu_src_img = nullptr;
	checkCuda(cudaMalloc(&gpu_src_img, mod_width * mod_height * 3));
	checkCuda(cudaMemcpy(
		gpu_src_img,
		mod_img,
		mod_width * mod_height * 3,
		cudaMemcpyHostToDevice
	));

	unsigned char* gpu_dst_img = nullptr;
	checkCuda(cudaMalloc(&gpu_dst_img, mod_width * mod_height * 3));

	float time = 0;
	cudaEvent_t startEvent, stopEvent;
	checkCuda(cudaEventCreate(&startEvent));
	checkCuda(cudaEventCreate(&stopEvent));

	//Ядро
	dim3 dimGrid((mod_width - 2) / THREADS_X, (mod_height - 2) / THREADS_Y);
	dim3 dimBlock(THREADS_X, THREADS_Y);
	checkCuda(cudaEventRecord(startEvent, 0));
	gpu_filter_lab6 << <dimGrid, dimBlock >> > (gpu_src_img, gpu_dst_img, mod_width);

	checkCuda(cudaEventRecord(stopEvent, 0));
	checkCuda(cudaEventSynchronize(stopEvent));
	checkCuda(cudaEventElapsedTime(&time, startEvent, stopEvent));

	unsigned char* mod_gpu_result_img = new unsigned char[mod_width * mod_height * 3];
	checkCuda(cudaMemcpy(
		mod_gpu_result_img,
		gpu_dst_img,
		mod_width * mod_height * 3,
		cudaMemcpyDeviceToHost
	));

	unsigned char* gpu_result_img = remove_padding_lab6(mod_gpu_result_img, width, height, mod_width);

	/*show_matrix(mod_cpu_result_img, mod_width * 3, mod_height);
	cout << endl << endl;
	show_matrix(cpu_result_img, width * 3, height);*/

	if (!is_equals(cpu_result_img, gpu_result_img, width * 3, height)) {
		cout << "smth went wrong" << endl;
	}

	cout << chrono::duration<double, milli>(cpu_elapsed).count() << " - CPU time" << endl;
	cout << time << " - GPU time" << endl;

	string cpu_result_filename = "CPU_result.ppm";
	string gpu_result_filename = "GPU_result.ppm";
	__savePPM(cpu_result_filename.c_str(), cpu_result_img, width, height, channels);
	__savePPM(gpu_result_filename.c_str(), gpu_result_img, width, height, channels);
}