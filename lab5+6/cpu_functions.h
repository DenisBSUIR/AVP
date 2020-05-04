#pragma once

unsigned char* transform_img(const unsigned char* img, const int width, const int height);

void cpu_filter(const unsigned char* img, unsigned char* result_img, const int width, const int height);

void cpu_filter_lab6(const unsigned char* img, unsigned char* result_img, const int width, const int height);

void show_matrix(const unsigned char* img, const int width, const int height);

unsigned char* remove_padding(const unsigned char* mod_img, const int width, const int height, const int mod_width);

unsigned char* remove_padding_lab6(const unsigned char* mod_img, const int width, const int height, const int mod_width);

unsigned char* prepare_img_for_gpu(const unsigned char* img, const int mod_width_gpu, const int mod_height_gpu, const int width, const int height);

bool is_equals(const unsigned char* cpu_img, const unsigned char* gpu_img, const int width, const int height);

unsigned char* prepare_img(const unsigned char*img,const unsigned int width, const int height, const int mod_width,const int mod_height);