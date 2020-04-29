
cudaError_t checkCuda(cudaError_t result);

__global__ void gpu_perform_transformation(char* src, char* dst);

__global__ void gpu_perform_transformation_shared(char* src, char* dst);