__1. Fuction:__  
*  Copy data from cpu 0 to gpu 0 (initialization).  
*  Copy data from gpu 0 to cpu 0. The time is recorded as GPU_to_CPU_TIME.  
*  Communicate data from cpu 0 to cpu 1. The time is recorded as mpi_time.  
*  Copy data from cpu 1 to gpu 1. The time is recorded as CPU_to_GPU_TIME.  

__2. Compile:__    
make  

__3. Run:__     
* On seerver02:  
`mpirun -hostfile hostfile ./measeuretime`   
It is ok to run on server02    
The screen print is as follows:    
https://github.com/XianMeng/measuretime/blob/master/server2screenprint.png

* On seerver01:  
`mpirun -hostfile hostfile ./measeuretime`  
It is unable to run on server01   
The screen print is as follows:  
https://github.com/XianMeng/measuretime/blob/master/server1screenprint.png
