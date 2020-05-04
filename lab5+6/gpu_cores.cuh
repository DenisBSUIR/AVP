
__global__ void gpu_filter(unsigned char* src_img, unsigned char* dst_img, int width);

__global__ void gpu_filter_lab6(unsigned char* src_img, unsigned char* dst_img, int width);

cudaError_t checkCuda(cudaError_t result);