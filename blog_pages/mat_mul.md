@def title = "Matrix Multiplication: Cache-aware optimizations"
@def date = Date(2025, 08, 31)
@def description = "Taking a simple matrix multiplication code and optimizing it in a cache-aware manner, while analyzing its performance using various metrics beyond wall clock time and FLOPS."

\toc

## Introduction
It all started on the summer of 2025, when I was casually browsing through twitter(now X), and came across this gem of a blog post by ~~~<a href="https://siboehm.com">Simon Boehm</a>~~~ 
on [Fast Multidimensional Matrix Multiplication on CPU from Scratch](https://siboehm.com/articles/22/Fast-MMM-on-CPU).

Fetching motivation from it, I decided to take a simple matrix multiplication code and optimize it in a cache-aware manner, while analyzing its performance.

## Simple Matrix Multiplication
Let's start with a simple implementation of matrix multiplication in C++.

```cpp
void basic_mat_mul(float* A, float* B, float* C)
{
    for(int i = 0;i < M; i++){
        for(int j = 0; j < K; j++){
            float val = 0.0;
            for (int inner =0; inner < N; inner++){
                val += A[i * N + inner] * B[j + inner * K];  
            }
            C[i * K + j] = val;
        }}}
```
~~~<img src="/assets/mat_mul_simple.png" style="width:60%; height:60%;">~~~

TODO: Add more details


## Cache-aware Optimizations
### Loop Reordering
```cpp
void loop_reordered(int M, int N, int K, float* A, float* B, float* C)
{
    for(int i=0; i < M; i++){
        for(int inner =0; inner < N; inner++){
            for(int j=0; j<K; j++){
                C[i*K+j] += A[i*N + inner] * B[j+inner*K]; 
            }}}}
```
### Half Tiling
```cpp
void half_tiled_mm(int M, int N, int K, float* A, float* B, float* C)
{
    for(int i = 0;i<M;i++){
        for(int inner=0; inner<N/2;inner++){
            for(int j=0;j<K;j++){
                C[i*K+j] += A[i*N + inner] * B[j+inner*K]; 
            }
        }
    }
    for(int i = 0;i<M;i++){
        for(int inner=N/2; inner<N;inner++){
            for(int j=0;j<K;j++){
                C[i*K+j] += A[i*N + inner] * B[j+inner*K]; 
            }
        }
    }
}
```
### Inner Loop Tiling
```cpp
void inner_tiled_mm(int M, int N, int K, float* A, float* B, float* C, int tile_size)
{
    for(int tile = 0; tile<N; tile+=tile_size) {
        for(int i = 0;i<M;i++){
            int end_tile = std::min(N, tile+tile_size);
            for(int inner=tile; inner<end_tile; inner++){
                for(int j=0;j<K;j++){
                    C[i*K+j] += A[i*N + inner] * B[j+inner*K]; 
                    }}}}}
```
### Full Tiling
```cpp
void fully_tiled_mm(int M, int N, int K, float* A, float* B, float* C, int tile_size)
{
    for(int row = 0; row<M; row+=tile_size) {
        for(int col = 0;col<K;col+=tile_size){
            for(int inner=0; inner<N; inner++){
                for(int block_row=row; block_row< std::min(row + tile_size, M); block_row++){
                    for(int block_col=col; block_col< std::min(col + tile_size, K); block_col++){
                        C[block_row*K+block_col] += A[block_row*N + inner] * B[block_col+inner*K]; 
                    }}}}}}

```