/* Aug. 2019
*
*  gpu.cu: GPU part
*/

#include <stdio.h>
#include <sys/time.h>
#include <assert.h>
#include "cpu.h"

// Error handling macro
#define CUDA_CHECK(call) \
    if((call) != cudaSuccess) { \
        cudaError_t err = cudaGetLastError(); \
        fprintf(stderr,"CUDA error calling \""#call"\", code is %d\n",err); \
        my_abort(err); }
//#define DEBUG
#define _MIC_

// 1.Initialize an array with all 1 on cpu
// 2. Copy the data from cpu to gpu
// 3. Copy the data from cpu to gpu
//void * initData(int * data_in_cpu, int * data_from_gpu, int dataSize) {
//int * gpu0_to_cpu0(int * data_in_cpu, int * data_from_gpu, int dataSize) {
void gpu0_to_cpu0(int * data_in_cpu, int * data_from_gpu, int dataSize) {
    //Recording time
    struct timeval start, end;
    double GPU_to_CPU_time;
    double tstart , tend;

    //Data in GPU
    int * gpu_data_from_cpu = NULL; //data from cpu to gpu
    cudaMalloc((void**)&gpu_data_from_cpu, dataSize * sizeof(int));  

    // Allocate pinned host memory
    cudaHostAlloc(&data_in_cpu, sizeof(int) * dataSize, cudaHostAllocDefault);
    cudaHostAlloc(&data_from_gpu, sizeof(int) * dataSize, cudaHostAllocDefault);
    #ifdef _MIC_
    cudaHostAlloc(&phi_data, sizeof(int) * dataSize, cudaHostAllocDefault);
    #endif

    // Initialize host data
    for(int i = 0; i < dataSize; i++) {
        data_in_cpu[i] = 1;
        #ifdef _MIC_
        phi_data[i]=1;
        #endif
    }
   
    //Copy data from cpu to gpu
    cudaMemcpy(gpu_data_from_cpu, data_in_cpu, sizeof(int) * dataSize, cudaMemcpyHostToDevice);
    
    // Allocate PHI memory
    #ifdef _MIC_
    #pragma offload_transfer target(mic) \
	in( phi_data : length(dataSize) ALLOC 
    #endif

    //Transfer data from GPU to CPU memory, and record time
    gettimeofday(&start, NULL);
    cudaMemcpy(data_from_gpu, gpu_data_from_cpu, sizeof(int) * dataSize, cudaMemcpyDeviceToHost);
    gettimeofday(&end, NULL);

    //Transfer data from host to PHY
    #ifdef _MIC_
    #pragma offload_transfer target(mic) in( phi_data : length(dataSize)  REUSE )
    #endif

    tstart = start.tv_sec + start.tv_usec/1000000.;
    tend = end.tv_sec + end.tv_usec/1000000.;
    GPU_to_CPU_time = (tend - tstart);
    printf("############################ GPU to CPU transfer time  ##############################\n");
    printf(" %d int data,      time is:%f seconds\n",dataSize, GPU_to_CPU_time);
    printf("#####################################################################################\n");

    #ifdef DEBUG
    printf( "data_in_cpu[1] = %d\n", data_in_cpu[1]);
    printf( "data_from_gpu[1] = %d\n",data_from_gpu[1]);
    #endif
 
    //Free GPU memory
    CUDA_CHECK(cudaFree(gpu_data_from_cpu)); 

    //Free host memory
    CUDA_CHECK(cudaFreeHost(data_in_cpu));

    //Deallocate PHI memory
    #ifdef
    #pragma offload_transfer target(mic) \
        in( phi_data : length(dataSize) FREE  ), \
        in ( cpu_data : length(144728064) FREE )
    #endif
}

void cpu1_to_gpu1(int * cpu1_data, int dataSize){
   //Recoding time
   struct timeval start, end;
   double CPU_to_GPU_time;
   double tstart , tend;

   //data in cpu;
   int * data_in_cpu;

   //Data in GPU
   int * gpu_data_from_cpu = NULL; //data from cpu to gpu
   CUDA_CHECK(cudaMalloc((void**)&gpu_data_from_cpu, dataSize * sizeof(int)));

   // Allocate pinned host memory
   cudaHostAlloc(&data_in_cpu, sizeof(int) * dataSize, cudaHostAllocDefault);

   int i;
   for (i=1;i<dataSize;i++)
     {
     data_in_cpu[i]=cpu1_data[i];
     }
 
   //Copy data from cpu to gpu
   gettimeofday(&start, NULL);
   cudaMemcpy(gpu_data_from_cpu, data_in_cpu, sizeof(int) * dataSize, cudaMemcpyHostToDevice); 
   gettimeofday(&end, NULL);

   tstart = start.tv_sec + start.tv_usec/1000000.;
   tend = end.tv_sec + end.tv_usec/1000000.;
   CPU_to_GPU_time = (tend - tstart);

   printf("############################ CPU to GPU transfer time  ##############################\n");
   printf(" %d int data,      time is:%f seconds\n",dataSize, CPU_to_GPU_time);
   printf("#####################################################################################\n");

   //Free GPU memory
    CUDA_CHECK(cudaFree(gpu_data_from_cpu));

   //Free host memory
   CUDA_CHECK(cudaFreeHost(data_in_cpu));
   }

   //cudaDeviceReset();

