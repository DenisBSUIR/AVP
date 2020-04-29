
__global__ void gpu_filter(unsigned char* src_img, unsigned char* dst_img, int width);

cudaError_t checkCuda(cudaError_t result);