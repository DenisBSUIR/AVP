#include "cuda_runtime.h"
#include "device_launch_parameters.h"
#include "helper_image.h"

#include <iostream>
#include <vector>
#include <chrono>

#include "cpu_functions.h"
#include "gpu_cores.cuh"
#include "constants.h"

using namespace std;

int main()
{
	vector<char*> filenames(1);
	//filenames[0] = "images/test2.pgm";
	filenames[0] = "images/IMG1_gray.pgm";
	//filenames[1] = "images/IMG2_gray.pgm";
	//filenames[2] = "images/IMG3_gray.pgm";
	//filenames[3] = "images/JohnWick_gray.pgm";
		
	for (int i = 0; i < 1; i++) {
		unsigned char* img = nullptr;
		unsigned int width = 0, height = 0, channels = 0;

		__loadPPM(filenames[i], &img, &width, &height, &channels);

		//cout << filenames[i] << ": " << width << " " << height << " " << channels << endl;

		int mod_width = width + 2;
		int mod_height = height + 2;
		
		//Добавление элементов по краям матрицы
		unsigned char* mod_img = transform_img(img, mod_width, mod_height);

		unsigned char* mod_cpu_result_img = new unsigned char[mod_width * mod_height];

		//Фильтрация
		auto start_cpu = chrono::steady_clock::now();
		cpu_filter(mod_img, mod_cpu_result_img, mod_width, mod_height);
		auto end_cpu = chrono::steady_clock::now();
		auto cpu_elapsed = end_cpu - start_cpu;

		//Удаление элементов по краям
		unsigned char* cpu_result_img = remove_padding(mod_cpu_result_img, width, height, mod_width);


		//Подготовка изображения на GPU

		//Выравнивание
		int width_gpu = width, height_gpu = height;

		if (width_gpu % THREADS_X != 0) {
			width_gpu = (width_gpu / THREADS_X + 1) * THREADS_X;
		}

		if (height_gpu % THREADS_Y != 0) {
			height_gpu = (height_gpu / THREADS_Y + 1) * THREADS_Y;
		}

		//Перенос изображения
		int mod_width_gpu = width_gpu + 2;
		int mod_height_gpu = height_gpu + 2;

		unsigned char* img_for_gpu = prepare_img_for_gpu(img, mod_width_gpu, mod_height_gpu, width, height);

		////Подготовка к запуску ядра
		//unsigned char* gpu_src_img = nullptr;
		//size_t input_pitch = 0;
		//checkCuda(cudaMallocPitch(reinterpret_cast<void**>(&gpu_src_img), &input_pitch, mod_width_gpu, mod_height_gpu));
		//checkCuda(cudaMemcpy2D(
		//	gpu_src_img,
		//	input_pitch,
		//	img_for_gpu,
		//	mod_width_gpu,
		//	mod_width_gpu,
		//	mod_height_gpu,
		//	cudaMemcpyHostToDevice
		//));
	
		//size_t output_pitch = 0;
		//unsigned char* gpu_dst_img = nullptr;
		//cudaMallocPitch(reinterpret_cast<void**>(&gpu_dst_img), &output_pitch, mod_width_gpu, mod_height_gpu);

		//float time = 0;
		//cudaEvent_t startEvent, stopEvent;
		//checkCuda(cudaEventCreate(&startEvent));
		//checkCuda(cudaEventCreate(&stopEvent));

		////Ядро
		//dim3 dimGrid(width_gpu / THREADS_X, height_gpu / THREADS_Y);
		//dim3 dimBlock(THREADS_X, THREADS_Y);
		//checkCuda(cudaEventRecord(startEvent, 0));
		//gpu_filter <<<dimGrid, dimBlock >>> (gpu_src_img, gpu_dst_img, mod_width_gpu);

		//checkCuda(cudaEventRecord(stopEvent, 0));
		//checkCuda(cudaEventSynchronize(stopEvent));
		//checkCuda(cudaEventElapsedTime(&time, startEvent, stopEvent));

		//unsigned char* mod_gpu_result_img = new unsigned char[mod_width_gpu * mod_height_gpu];
		//checkCuda(cudaMemcpy2D(
		//	mod_gpu_result_img,
		//	mod_width_gpu,
		//	gpu_dst_img,
		//	output_pitch,
		//	mod_width_gpu,
		//	mod_height_gpu,
		//	cudaMemcpyDeviceToHost
		//));

		//Подготовка к запуску ядра
		unsigned char* gpu_src_img = nullptr;
		size_t input_pitch = 0;
		checkCuda(cudaMalloc(&gpu_src_img, mod_width_gpu* mod_height_gpu));
		checkCuda(cudaMemcpy(
			gpu_src_img,
			img_for_gpu,			
			mod_width_gpu * mod_height_gpu,
			cudaMemcpyHostToDevice
		));

		size_t output_pitch = 0;
		unsigned char* gpu_dst_img = nullptr;
		checkCuda(cudaMalloc(&gpu_dst_img, mod_width_gpu * mod_height_gpu));

		float time = 0;
		cudaEvent_t startEvent, stopEvent;
		checkCuda(cudaEventCreate(&startEvent));
		checkCuda(cudaEventCreate(&stopEvent));

		//Ядро
		dim3 dimGrid(width_gpu / THREADS_X, height_gpu / THREADS_Y);
		dim3 dimBlock(THREADS_X, THREADS_Y);
		checkCuda(cudaEventRecord(startEvent, 0));
		gpu_filter << <dimGrid, dimBlock >> > (gpu_src_img, gpu_dst_img, mod_width_gpu);

		checkCuda(cudaEventRecord(stopEvent, 0));
		checkCuda(cudaEventSynchronize(stopEvent));
		checkCuda(cudaEventElapsedTime(&time, startEvent, stopEvent));

		unsigned char* mod_gpu_result_img = new unsigned char[mod_width_gpu * mod_height_gpu];
		checkCuda(cudaMemcpy(
			mod_gpu_result_img,
			gpu_dst_img,
			mod_width_gpu * mod_height_gpu,
			cudaMemcpyDeviceToHost
		));

		unsigned char* gpu_result_img = remove_padding(mod_gpu_result_img, width, height, mod_width_gpu);

		if (!is_equals(cpu_result_img, gpu_result_img, width, height)) {
			cout << "smth went wrong" << endl;
		}

		checkCuda(cudaFree(gpu_src_img));
		checkCuda(cudaFree(gpu_dst_img));
		checkCuda(cudaEventDestroy(startEvent));
		checkCuda(cudaEventDestroy(stopEvent));
				
		cout << chrono::duration<double, milli>(cpu_elapsed).count() << " - CPU time" << endl;
		cout << time << " - GPU time" << endl;

		string cpu_result_filename = "CPU_result.pgm";
		string gpu_result_filename = "GPU_result.pgm";
		__savePPM(cpu_result_filename.c_str(), cpu_result_img, width, height, channels);
		__savePPM(gpu_result_filename.c_str(), gpu_result_img, width, height, channels);
	}

	return 0;
}