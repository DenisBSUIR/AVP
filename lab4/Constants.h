#pragma once


//размерность блоков для трансформации
const int src_block_x = 2, src_block_y = 2, dst_block_x = 1, dst_block_y = 4;
//Количество таких блоков в матрицах 
const long long blocks_x = 1024 * 16, blocks_y = 1024 * 2;
//Размерность матрицы в элементах
const long long src_matrix_x = src_block_x * blocks_x, src_matrix_y = src_block_y * blocks_y, dst_matrix_x = dst_block_x * blocks_x, dst_matrix_y = blocks_y * dst_block_y;
//Размер матриц
const unsigned long long src_matrix_size = src_matrix_x * src_matrix_y, dst_matrix_size = dst_matrix_x * dst_matrix_y;
