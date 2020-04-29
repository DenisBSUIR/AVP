#include <iostream>
#include "Functions.h"
#include "Constants.h"

using namespace std;

void cpu_perform_transformation(char* src_matrix, char* dst_matrix) 
{
	for (long long i = 0; i < blocks_y; i++) {
		for (long long j = 0; j < blocks_x; j++) {
			for (long long k = 0; k < src_block_y; k++) {
				for (long long l = 0; l < src_block_x; l++) {
					//dst_matrix[i * dst_block_y + (k * src_block_y + l)][j] = src_matrix[i * src_block_y + k][j * src_block_x + l];
					long long idx1, idx2;
					idx1 = (i * dst_block_y * dst_matrix_x + j * dst_block_x) + (k * src_block_y + l) * dst_matrix_x;
					idx2 = (i * src_block_y * src_matrix_x + j * src_block_x) + (l + k * src_matrix_x);
					dst_matrix[idx1] = src_matrix[idx2];
					/*dst_matrix[(i * dst_block_y * dst_matrix_x + j * dst_block_x) + (k * src_block_y + l) * dst_matrix_x] =
						src_matrix[(i * src_block_y * src_matrix_x + j * src_block_x) + (l + k * src_matrix_x)];*/
				}
			}
		}
	}
}

void show_matrix(int y, int x, char* matrix)
{
	/*for (int i = 0; i < y; i++) {
		for (int j = 0; j < x; j++) {
			cout << matrix[i][j] - '0' << " ";
		}
		cout << endl;
	}*/
	for (long long i = 0; i < y; i++) {
		for (long long j = 0; j < x; j++) {
			cout << matrix[i * x + j] - '0' << " ";
		}
		cout << endl;
	}
}

void show_block(int x, int y, char* src, char* dst) 
{
	cout << src[(long long)y * src_block_y * src_matrix_x + (long long)x * src_block_x] << " " << src[(long long)y * src_block_y * src_matrix_x + (long long)x * src_block_x + 1] << endl;
	cout << src[((long long)y * src_block_y + 1) * src_matrix_x + (long long)x * src_block_x] << " " << src[((long long)y * src_block_y + 1) * src_matrix_x + (long long)x * src_block_x + 1] << endl;
	cout << endl;
	cout << dst[((long long)y * dst_block_y + 0) * dst_matrix_x + x * dst_block_x] << " " << endl;
	cout << dst[((long long)y * dst_block_y + 1) * dst_matrix_x + x * dst_block_x] << " " << endl;
	cout << dst[((long long)y * dst_block_y + 2) * dst_matrix_x + x * dst_block_x] << " " << endl;
	cout << dst[((long long)y * dst_block_y + 3) * dst_matrix_x + x * dst_block_x] << " " << endl;
}

bool check_match(char* src, char* result)
{
	for (unsigned long long i = 0; i < src_matrix_size; i++) 
	{
		if (src[i] != result[i])
			return false;
	}
	return true;
}