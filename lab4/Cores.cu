#include <iostream>
#include <cuda_runtime_api.h>
#include <cassert>
#include "device_launch_parameters.h"
#include <device_functions.h>
#include "cuda_runtime.h"
#include <cuda.h>

#include "cuda_runtime.h"
#include "device_launch_parameters.h"

#include <iostream>
#include <stdio.h>
#include <stdlib.h>
#include <ctime>
#include <Windows.h>
#include <cuda_runtime.h> 
#include <intrin.h>
#include <cuda.h>
#include <cuda_runtime_api.h>
#include <device_launch_parameters.h>
#include <device_functions.h>


#include "Constants.h"
#include <cuda_runtime.h>

using namespace std;

// Convenience function for checking CUDA runtime API results
// can be wrapped around any runtime API call. No-op in release builds.
//inline
cudaError checkCuda(cudaError_t result)
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

__global__ void gpu_perform_transformation(char* src, char* dst) {
	
	dst[(blockIdx.y * dst_block_y * 32 + threadIdx.y * dst_block_y + 0) * dst_matrix_x + ((blockIdx.x * dst_block_x * 32) + threadIdx.x * dst_block_x)] =
		src[(blockIdx.y * src_block_y * 32 + threadIdx.y * src_block_y) * src_matrix_x + (blockIdx.x * src_block_x * 32 + threadIdx.x * src_block_x)];
	dst[(blockIdx.y * dst_block_y * 32 + threadIdx.y * dst_block_y + 1) * dst_matrix_x + (blockIdx.x * dst_block_x * 32 + threadIdx.x * dst_block_x)] =
		src[(blockIdx.y * src_block_y * 32 + threadIdx.y * src_block_y) * src_matrix_x + (blockIdx.x * src_block_x * 32 + threadIdx.x * src_block_x) + 1];
	dst[(blockIdx.y * dst_block_y * 32 + threadIdx.y * dst_block_y + 2) * dst_matrix_x + (blockIdx.x * dst_block_x * 32 + threadIdx.x * dst_block_x)] =
		src[(blockIdx.y * src_block_y * 32 + threadIdx.y * src_block_y + 1) * src_matrix_x + (blockIdx.x * src_block_x * 32 + threadIdx.x * src_block_x)];
	dst[(blockIdx.y * dst_block_y * 32 + threadIdx.y * dst_block_y + 3) * dst_matrix_x + (blockIdx.x * dst_block_x * 32 + threadIdx.x * dst_block_x)] =
		src[(blockIdx.y * src_block_y * 32 + threadIdx.y * src_block_y + 1) * src_matrix_x + (blockIdx.x * src_block_x * 32 + threadIdx.x * src_block_x) + 1];
}

__global__ void gpu_perform_transformation_shared(char* src, char* dst) {
	__shared__ char smem[64 * 64];
	__shared__ char smem_dst[64 * 64];
	uint2 offset = {
		blockIdx.x * 64 + threadIdx.x,
		blockIdx.y * 64 + threadIdx.y
	};

	smem[threadIdx.y * 64 + threadIdx.x] = src[offset.y * 64 + offset.x];
	smem[threadIdx.y * 64 + threadIdx.x + 32] = src[offset.y * 64 + offset.x + 32];
	smem[(threadIdx.y + 32) * 64 + threadIdx.x] = src[(offset.y + 32) * 64 + offset.x];
	smem[(threadIdx.y + 32) * 64 + threadIdx.x + 32] = src[(offset.y + 32) * 64 + offset.x + 32];

	__syncthreads();

	int a = smem[threadIdx.y * 4 * 64 + threadIdx.x * 2];
	int b = smem[threadIdx.y * 4 * 64 + threadIdx.x * 2 + 1];
	int c = smem[(threadIdx.y * 4 + 1) * 64 + threadIdx.x * 2];
	int d = smem[(threadIdx.y * 4 + 1) * 64 + threadIdx.x * 2 + 1];

	smem_dst[threadIdx.y * 4 * 64 + threadIdx.x * 2] = a;
	smem_dst[(threadIdx.y * 4 + 1) * 64 + threadIdx.x * 2] = b;
	smem_dst[(threadIdx.y * 4 + 2) * 64 + threadIdx.x * 2] = c;
	smem_dst[(threadIdx.y * 4 + 3) * 64 + threadIdx.x * 2] = d;

	dst[offset.y * 64 + offset.x] =	smem_dst[threadIdx.y * 64 + threadIdx.x];
	dst[(offset.y * + 32) * 64 + offset.x] = smem_dst[(threadIdx.y + 32) * 64 + threadIdx.x];
	dst[(offset.y * + 64) * 64 + offset.x] = smem_dst[(threadIdx.y + 64) * 64 + threadIdx.x];
	dst[(offset.y * + 96) * 64 + offset.x] = smem_dst[(threadIdx.y + 96) * 64 + threadIdx.x];
}