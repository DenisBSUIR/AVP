#include "cuda_runtime.h"
#include "device_launch_parameters.h"

#include <stdio.h>
#include <iostream>
#include <time.h>
#include <chrono>

#include "Functions.h"
#include "Cores.cuh"
#include "Constants.h"

using namespace std;

int main() {
    char* src_matrix, * dst_matrix;

    //Выделение памяти на CPU
    src_matrix = new char [src_matrix_size];
    dst_matrix = new char [dst_matrix_size];

    /*src_matrix = new char* [src_matrix_y];
    for (int i = 0; i < src_matrix_y; i++) {
        src_matrix[i] = new char[src_matrix_x];
    }

    dst_matrix = new char* [dst_matrix_y];
    for (int i = 0; i < dst_matrix_y; i++) {
        dst_matrix[i] = new char[dst_matrix_x];
    }*/


    //Инициализация
    srand(time(nullptr));
    for (unsigned long long i = 0; i < src_matrix_size; i++) {
        src_matrix[i] = rand() % 10 + '0';
    }

    /*for (int i = 0; i < src_matrix_y; i++) {
        for (int j = 0; j < src_matrix_x; j++) {
            src_matrix[i][j] = rand() % 10 + '0';
        }
    }*/



    //Трансформация матрицы на CPU
    auto start_cpu = chrono::steady_clock::now();
    cpu_perform_transformation(src_matrix, dst_matrix);
    auto end_cpu = chrono::steady_clock::now();
    auto elapsed_cpu = chrono::duration_cast<chrono::milliseconds>(end_cpu - start_cpu);

    //Трансформация матрицы на GPU
    size_t size = src_matrix_x * src_matrix_y * sizeof(char);
    char* d_src, * d_dst, *gpu_result_matrix, *gpu_res_matrix_shared;

    gpu_result_matrix = new char[dst_matrix_size];
    gpu_res_matrix_shared = new char[dst_matrix_size];

    int dimBlock_x = 32, dimBlock_y = 32;
    dim3 dimBlock(dimBlock_x, dimBlock_y);
    dim3 dimGrid(blocks_x/dimBlock_x, blocks_y/dimBlock_y);

    checkCuda(cudaMalloc(&d_src, size));
    checkCuda(cudaMalloc(&d_dst, size));
    checkCuda(cudaMemcpy(d_src, src_matrix, size, cudaMemcpyHostToDevice));

    cudaEvent_t start_event, end_event;
    checkCuda(cudaEventCreate(&start_event));
    checkCuda(cudaEventCreate(&end_event));
    checkCuda(cudaEventRecord(start_event, 0));

    gpu_perform_transformation<<<dimGrid, dimBlock>>>(d_src, d_dst);

    checkCuda(cudaEventRecord(end_event, 0));
    checkCuda(cudaEventSynchronize(end_event));
    float elapsed_gpu;
    checkCuda(cudaEventElapsedTime(&elapsed_gpu, start_event, end_event));
    
    checkCuda(cudaMemcpy(gpu_result_matrix, d_dst, size, cudaMemcpyDeviceToHost));



    /*checkCuda(cudaEventRecord(start_event, 0));
    
    gpu_perform_transformation_shared<<<dimGrid, dimBlock>>>(d_src, d_dst);
    
    checkCuda(cudaEventRecord(end_event, 0));
    checkCuda(cudaEventSynchronize(end_event));
    float elapsed_gpu_shared;
    checkCuda(cudaEventElapsedTime(&elapsed_gpu_shared, start_event, end_event));
    
    checkCuda(cudaMemcpy(gpu_res_matrix_shared, d_dst, size, cudaMemcpyDeviceToHost));*/


    cudaEventDestroy(start_event);
    cudaEventDestroy(end_event);
    
    checkCuda(cudaFree(d_src));
    checkCuda(cudaFree(d_dst));

    if (!check_match(dst_matrix, gpu_result_matrix)) {
        cout << "Wrong algorithm" << endl;
    }

    /*if (!check_match(dst_matrix, gpu_res_matrix_shared)) {
        cout << "Wrong algorithm with shared" << endl;
    }*/

    cout << elapsed_cpu.count() << " - time with CPU" << endl;
    cout << elapsed_gpu << " - time with GPU" << endl;
   // cout << elapsed_gpu_shared << " - time wirh shared GPU" << endl;
    //show_matrix(src_matrix_y, src_matrix_x, src_matrix);
    //cout << endl;
    //show_matrix(dst_matrix_y, dst_matrix_x, dst_matrix);
    //cout << endl;

    /*for (int i = 0; i < src_matrix_y; i++) {
        delete[] src_matrix[i];
    }
    for (int i = 0; i < dst_matrix_y; i++) {
        delete[] dst_matrix[i];
    }*/
    delete[] src_matrix;
    delete[] dst_matrix;
    delete[] gpu_result_matrix;

    system("pause");
    return 0;
}
