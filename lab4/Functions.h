#pragma once

void cpu_perform_transformation(char* src_matrix, char* dst_matrix);

void show_matrix(int y, int x, char* matrix);

void show_block(int x, int y, char* src, char* dst);

bool check_match(char* src, char* result);