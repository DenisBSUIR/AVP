#include "cuda.h"
#include <cuda_runtime_api.h>
#include "device_launch_parameters.h"

#include <iostream>
#include <cassert>
#include <vector>
#include <algorithm>

#include "constants.h"

using namespace std;

cudaError_t checkCuda(cudaError_t result)
{
#if defined(DEBUG) || defined(_DEBUG) || defined(CUDA_DEBUG)
	if (result != cudaSuccess)
	{
		cerr << "CUDA Runtime Error: " << cudaGetErrorString(result) << endl;
		assert(result == cudaSuccess);
	}
#endif
	return result;
}

__global__ void gpu_filter(unsigned char* src_img, unsigned char* dst_img, int width) {
	
	uint2 offset = {
		blockIdx.x * THREADS_X + threadIdx.x,
		blockIdx.y * THREADS_Y + threadIdx.y
	};
	
	char neighbors[9];
	neighbors[0] = src_img[offset.y * width + offset.x];
	neighbors[1] = src_img[offset.y * width + offset.x + 1];
	neighbors[2] = src_img[offset.y * width + offset.x + 2];
	neighbors[3] = src_img[(offset.y + 1) * width + offset.x];
	neighbors[4] = src_img[(offset.y + 1) * width + offset.x + 1];
	neighbors[5] = src_img[(offset.y + 1) * width + offset.x + 2];
	neighbors[6] = src_img[(offset.y + 2) * width + offset.x];
	neighbors[7] = src_img[(offset.y + 2) * width + offset.x + 1];
	neighbors[8] = src_img[(offset.y + 2) * width + offset.x + 2];

	char min = neighbors[0];
	for (int i = 1; i < 9; i++) {
		if (neighbors[i] < min)
			min = neighbors[i];
	}

	dst_img[(offset.y + 1) * width + offset.x + 1] = min;
}