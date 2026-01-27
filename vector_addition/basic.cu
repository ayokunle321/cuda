// Basic Vector Addition

#include <vector>
#include <cstdlib>
#include <cassert>
#include <iostream>

__global__ void vector_add(int* __restrict a, int* __restrict b, int* __restrict c, int N){
    int tid = (blockIdx.x * blockDim.x) + threadIdx.x;
    if (tid < N)
        c[tid] = a[tid] + b[tid];
}

void populate_vector(std::vector<int>& vec){
    for(int i; i < vec.size(); i++)
        vec[i] = rand() % 100;
}

void validate_vector_add(std::vector<int>& a, std::vector<int>& b, std::vector<int>& c, int N){
    for(int i = 0; i < N; i++)
        assert(c[i] == a[i] + b[i] && "Incorrect Results");
}

int main(){
    int N = 4096;
    int size_bytes = N * sizeof(int);

    std::vector<int> a(N);
    std::vector<int> b(N);
    std::vector<int> c(N);

    populate_vector(a);
    populate_vector(b);

    int* d_a;
    int* d_b; 
    int* d_c;

    cudaMalloc(&d_a, size_bytes);
    cudaMalloc(&d_b, size_bytes);
    cudaMalloc(&d_c, size_bytes);

    cudaMemcpy(d_a, a.data(), size_bytes, cudaMemcpyHostToDevice);
    cudaMemcpy(d_b, b.data(), size_bytes, cudaMemcpyHostToDevice);

    int NUM_THREADS = 1024;
    int NUM_BLOCKS = (N + NUM_THREADS - 1) / NUM_THREADS;
    vector_add<<<NUM_BLOCKS, NUM_THREADS>>>(d_a, d_b, d_c, N);
    cudaMemcpy(c.data(), d_c, size_bytes, cudaMemcpyDeviceToHost);

    validate_vector_add(a, b, c, N);
    std::cout << "SUCCESS!" << std::endl;
}
