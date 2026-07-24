CC ?= g++

# ------------------------------------------------------------------------------
# CUDA Path Detection
# ------------------------------------------------------------------------------
# 1. Use CUDA_PATH if passed explicitly (e.g. make CUDA_PATH=/path/to/cuda or environment variable)
# 2. Otherwise detect CUDA path from nvcc in PATH
# 3. Otherwise fall back to standard Linux locations (/usr/local/cuda, /usr/local/cuda-*, etc.)
CUDA_PATH ?= $(shell command -v nvcc 2>/dev/null | sed 's/\/bin\/nvcc//')

ifeq ($(CUDA_PATH),)
    CUDA_PATH := $(firstword $(wildcard /usr/local/cuda /usr/local/cuda-* /usr/cuda /usr))
endif

ifeq ($(CUDA_PATH),)
    CUDA_PATH := /usr/local/cuda
endif

NVCC ?= $(CUDA_PATH)/bin/nvcc

# Fallback to system `nvcc` if $(NVCC) binary does not exist at expected path
ifeq ($(wildcard $(NVCC)),)
    ifneq ($(shell command -v nvcc 2>/dev/null),)
        NVCC := nvcc
    endif
endif

CCFLAGS := -O3 -I$(CUDA_PATH)/include
NVCCFLAGS := -O3 -I$(CUDA_PATH)/include -gencode=arch=compute_89,code=compute_89 -gencode=arch=compute_86,code=compute_86 -gencode=arch=compute_75,code=compute_75 -gencode=arch=compute_61,code=compute_61
LDFLAGS := -L$(CUDA_PATH)/lib64 -L$(CUDA_PATH)/lib -lcudart -pthread

CPU_SRC := RCKangaroo.cpp GpuKang.cpp Ec.cpp utils.cpp
GPU_SRC := RCGpuCore.cu

CPP_OBJECTS := $(CPU_SRC:.cpp=.o)
CU_OBJECTS := $(GPU_SRC:.cu=.o)

TARGET := rckangaroo

all: $(TARGET)

$(TARGET): $(CPP_OBJECTS) $(CU_OBJECTS)
	$(CC) $(CCFLAGS) -o $@ $^ $(LDFLAGS)

%.o: %.cpp
	$(CC) $(CCFLAGS) -c $< -o $@

%.o: %.cu
	$(NVCC) $(NVCCFLAGS) -c $< -o $@

clean:
	rm -f $(CPP_OBJECTS) $(CU_OBJECTS) $(TARGET)

.PHONY: all clean
