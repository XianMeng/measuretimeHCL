CUDA_INSTALL_PATH = /usr/local/cuda
MPI_INSTALL_PATH = /opt/mpich-3.2.1/MPICH_INSTALL
 
NVCC = $(CUDA_INSTALL_PATH)/bin/nvcc
MPICC = $(MPI_INSTALL_PATH)/bin/mpic++
 
LDFLAGS = -L$(CUDA_INSTALL_PATH)/lib64
LIB = -lcudart 
 
CFILES = cpu.c
CUFILES = gpu.cu
OBJECTS = cpu.o gpu.o
EXECNAME = measeuretime
 
all:
	$(MPICC) -c $(CFILES)
	$(NVCC) -c $(CUFILES)
	$(MPICC) -o $(EXECNAME) $(LDFLAGS) $(LIB) $(OBJECTS)
 
clean: 
	rm -f *.o $(EXECNAME)
