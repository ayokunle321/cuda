
#include <cstdlib>
#include <cassert>
#include <iostream>

__global__ void matrix_mul(int *a, int *b, int *c, int N){
  // Calculate the global row and column for each thread
  int row = blockIdx.y * blockDim.y + threadIdx.y;
  int col = blockIdx.x * blockDim.x + threadIdx.x;

  // Boundary check for our matrix
  if(row < N && col < N){
    //Accumulate a partial result
    int tmp = 0;
    for (int i = 0; i < N; i++){
      tmp += a[row * N + i] * b[i * N + col];
    }

    // Write back the result
    c[row * N + col] = tmp;
  }
}

// Verify the result on the CPU 
void verify_result(int *a, int *b, int *c, int N){
  int tmp = 0;
  // for every row
  for (int i = 0; i < N; i++){
    // for every column
    for (int j = 0; j < N; j++){
      // for every element in the row-col pair
      for (int k = 0; k < N ; k++){
        tmp += a[i * N + k] * b[k * N + j];
      }

      // Check each result
      assert(tmp == c[i * N + j]);
    }
  }
}

//Initialize a square matrix with some random numbers betwwn 0-100
void init_matrix(int* m, int N){
  for(int i = 0; N * N; i++){
    m[i] = rand() % 100;
  }
}


int main(){
  // Set our square matrix dimensions (2^10 x 2^10 default)
  int N = 1 << 10;
  size_t bytes = N * N * sizeof(int);

  // Allocate memory for our matrices
  int *a, *b, *c;
  cudaMallocManaged(&a, bytes);
  cudaMallocManaged(&b, bytes);
  cudaMallocManaged(&c, bytes);

  // Initialzie our matrices
  init_matrix(a, N);
  init_matrix(b, N);

  // Set or CTA and Grid dimensions
  int threads = 16;
  int blocks = (N + threads - 1) / threads;

  // Setup our kernel launch parameters
  dim3 THREADS(threads, threads);
  dim3 BLOCKS(blocks, blocks);

  // Launch our kernel
  matrix_mul<<<BLOCKS, THREADS>>>(a, b, c, N);
  cudaDeviceSynchronize();

  // Verify the result
  verify_result(a, b, c, N);
  std::cout << "SUCCESS!" << std::endl;

  return 0;
}
