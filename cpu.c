/* 
*  mpi.c: main program 
*  Aug. 2019
*/

#include <stdio.h>
#include <stdlib.h>
#include <mpi.h>
#include "cpu.h"

#define ping 101
//#define DEBUG

// Error handling macros
#define MPI_CHECK(call) \
    if((call) != MPI_SUCCESS) { \
        fprintf(stderr,"MPI error calling \""#call"\"\n");      \
        my_abort(-1); }

// Host code
// No CUDA here, only MPI
int main(int argc, char* argv[]) {
    //Data size for all the data
    int data_Size=1000000;
    
    //Data in cpu0
    int *cpu_to_gpu_init_data = NULL;
    int *data_in_cpu_from_gpu = NULL;
    int *send = NULL;
    
    //Data in cpu1
    int *data_in_cpu1;

    char ProcessName[MPI_MAX_PROCESSOR_NAME]; 

    //For recordiing time
    double start, finish, mpi_time;
    int  Length; 

    // Initialize MPI
    MPI_CHECK(MPI_Init(&argc, &argv));

    // Get MPI number and rank; 
    int commSize, commRank;
    MPI_CHECK(MPI_Comm_size(MPI_COMM_WORLD, &commSize));
    MPI_CHECK(MPI_Comm_rank(MPI_COMM_WORLD, &commRank));

    //Get process name
    MPI_Get_processor_name(ProcessName, &Length);

    //Initialization: Rank 0 sent data to GPU
    if(commRank == 0)  { 
        printf("Running using %d MPIs in total.\n",commSize);
        printf("I am rank %d\t ProcessName %s \t\n", commRank, ProcessName);
        send = (int *)malloc(sizeof(int)*data_Size);
          if(send==NULL) {
             fprintf(stderr,"Could not get %d bytes of send\n",send);
             exit(1);
          }
        //data_in_cpu_from_gpu=gpu0_to_cpu0(cpu_to_gpu_init_data, data_Size);
        cpu_to_gpu_init_data = (int *)malloc(sizeof(cpu_to_gpu_init_data)*data_Size);
        if(cpu_to_gpu_init_data==NULL) {
          fprintf(stderr,"Could not get %d bytes of memory for cpu_to_gpu_init_data\n",data_Size);
          exit(1);
        }
        data_in_cpu_from_gpu = (int *)malloc(sizeof(data_in_cpu_from_gpu)*data_Size);
        if(data_in_cpu_from_gpu==NULL) {
          fprintf(stderr,"Could not get %d bytes of memory for data_in_cpu_from_gpu\n",data_Size);
          exit(1);
        }
        gpu0_to_cpu0(cpu_to_gpu_init_data, data_in_cpu_from_gpu, data_Size);

        for ( int j = 0; j < data_Size; j++ )
        {
          send[j]=data_in_cpu_from_gpu[j];
        }

        //Debugging
        #ifdef DEBUG
        printf( "cpu_to_gpu_init_data[1] = %d \n", cpu_to_gpu_init_data[1]);
        printf( "data_in_cpu_from_gpu[1] = %d \n",  data_in_cpu_from_gpu[1]);
        printf( "send[1] = %d \n", send[1]);
        #endif

        //Send data from cpu in MPI 0 to cpu in MPI 1
        start = MPI_Wtime();
        MPI_Send(send, data_Size, MPI_INT, 1, ping,MPI_COMM_WORLD);
        finish = MPI_Wtime();

        mpi_time = finish - start;

        printf("######################## CPU in MPI 0 to CPU in MPI 1 time ##########################\n");
        printf(" %d int data,      time is:%f seconds\n",  data_Size, mpi_time);
        printf("#####################################################################################\n");

    }
    else if (commRank == 1) {
        printf("I am rank %d\t ProcessName %s \t\n", commRank, ProcessName);
        data_in_cpu1 = (int *)malloc(sizeof(int)*data_Size);
        if(data_in_cpu1==NULL) {
          fprintf(stderr,"Could not get %d bytes of memory data_in_cpu1\n",data_Size);
          exit(1);
        }
        MPI_Recv(data_in_cpu1, data_Size, MPI_INT, 0, ping, MPI_COMM_WORLD, MPI_STATUS_IGNORE);
        
        //DEBUG
        #ifdef DEBUG
        printf( "data_in_cpu1[1] = %d\n", data_in_cpu1[1]);
        #endif

         //send data in cpu 1 to gpu1
         cpu1_to_gpu1(data_in_cpu1,data_Size);
    }
   
    // Cleanup
    free(cpu_to_gpu_init_data);
    free(data_in_cpu_from_gpu);
    MPI_Finalize();
    if(commRank == 0) {
      printf("Test PASSED\n");
    }

    return 0;
}

// Shut down MPI cleanly if something goes wrong
void my_abort(int err) {
    printf("Test FAILED\n");
    MPI_Abort(MPI_COMM_WORLD, err);
}
