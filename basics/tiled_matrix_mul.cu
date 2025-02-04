
#include <cstdlib>
#include <cassert>

__global__ void tiled_sq_mat_mul(float* A, float* B, float* C, int N)
{
    // Details regarding this thread 
    int by = blockIdx.y;
    int bx = blockIdx.x;

    int ty = threadIdx.y;
    int tx = threadIdx.x;

    // Working on C[i, j]
    int i = blockDim.y*by + ty;
    int j = blockDim.x*bx + tx;

    // Allocating shared memory
    __shared__ float sh_a[TILE_WIDTH][TILE_WIDTH];
    __shared__ float sh_a[TILE_WIDTH][TILE_WIDTH];

    // Parallel mat mul
    float value = 0;
    
    // Splitting data into smaller tiles
    for (int phase = 0; phase < N/TILE_WIDTH; phase++){

        // Load tiles into shared memory 
        if ((i < N) && ((phase*TILE_WIDTH*tx)) < N){
            sh_A[ty][tx] = A[(i)*N + phase*TILE_WIDTH+tx]
        } else {
            sh_A[ty][tx] = 0.0f;
        }

        if ((j < N) && ((phase*TILE_WIDTH*ty)) < N){
            sh_B[ty][tx] = B[(phase*TILE_WIDTH + ty)*N+j];
        } else {
            sh_B[ty][tx] = 0.0f;
        }
            __syncthreads();

        // Dot product with data in shared memory
        for (int k = 0; k < TILE_WIDTH; k++){
            value += sh_A[ty][k] * sh_B[k][tx];
        }
        __syncthreads();
    }

    //  Assigning calcualted values

    if ((i<N) && (j<N)){
        C[i*N+j] = value;
    }
}