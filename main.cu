//
// Created by elder on 8/16/2026.
//

#include <iostream>
#include "deviceFunctions.cuh"

int main() {

    int *array = static_cast<int *>(calloc(H*W, sizeof(int)));
    int *neighborArray = static_cast<int *>(calloc(H*W, sizeof(int)));
    if (array == nullptr) {
        std:: cerr << "array calloc failed\n";
        exit(EXIT_FAILURE);
    }
    if (neighborArray == nullptr) {
        std:: cerr << "neighborArray calloc failed\n";
        exit(EXIT_FAILURE);
    }

    std:: srand(std::time(nullptr));
    for (int i = 0; i < 60; i++) {
        int randRow = rand() % H;
        int randCol = rand() % W;

        int flatIndex = randRow * W + randCol;

        if (flatIndex >= H*W) continue;

        array[flatIndex] = 1;
    }

    for (int row = 0; row < H; row++) {
        for (int col = 0; col < W; col++) {
            int flatIndex = row * W + col;
            std:: cout << array[flatIndex] << " ";
        }
        std:: cout << std:: endl;
    }
    std:: cout << std:: endl;
    return 0;

    int *deviceArray = nullptr;
    int *deviceNeighborArray = nullptr;
    cudaError err = {};

    err = cudaMalloc(&deviceArray, H*W * sizeof(int));
    if (err != cudaSuccess) {
        std:: cerr << "FAILED TO ALLOCATE MEMORY FOR DEVICE ARRAY\n";
        exit(EXIT_FAILURE);
    }

    err = cudaMalloc(&deviceNeighborArray, H*W * sizeof(int));
    if (err != cudaSuccess) {
        std:: cerr << "FAILED TO ALLOCATE MEMORY FOR DEVICE NEIGHBOR ARRAY\n";
        exit(EXIT_FAILURE);
    }

    err = cudaMemcpy(deviceArray, array, H*W * sizeof(int), cudaMemcpyHostToDevice);
    if (err != cudaSuccess) {
        std:: cerr << "FAILED TO COPY ARRAY TO DEVICE ARRAY\n";
        exit(EXIT_FAILURE);
    }

    dim3 TPB(16, 16);
    dim3 blocks((W + TPB.x - 1) / TPB.x, (H + TPB.y - 1) / TPB.y);

    int count = 0;
    while (count++ < 100) {
        kernelCountNeighbors<<<blocks, TPB>>>(deviceArray, deviceNeighborArray);
        cudaDeviceSynchronize();
        kernelChangeCellState<<<blocks, TPB>>>(deviceArray, deviceNeighborArray);
        cudaDeviceSynchronize();

        err = cudaMemcpy(array, deviceArray, H*W*sizeof(int), cudaMemcpyDeviceToHost);
        if (err != cudaSuccess) {
            std:: cerr << "FAILED TO COPY DEVICE ARRAY TO ARRAY\n";
            exit(EXIT_FAILURE);
        }

        err = cudaMemcpy(neighborArray, deviceNeighborArray, H*W*sizeof(int), cudaMemcpyDeviceToHost);
        if (err != cudaSuccess) {
            std:: cerr << "FAILED TO COPY DEVICE NEIGHBOR ARRAY TO NEIGHBOR ARRAY\n";
            exit(EXIT_FAILURE);
        }

        std:: cout << "Step: " << count << std:: endl;
        for (int row = 0; row < H; row++) {
            for (int col = 0; col < W; col++) {
                int flatIndex = row * W + col;
                std:: cout << array[flatIndex] << " ";
            }
            std:: cout << std:: endl;
        }
        std:: cout << std:: endl;
    }

    cudaFree(deviceArray);
    cudaFree(deviceNeighborArray);

    return 0;
}