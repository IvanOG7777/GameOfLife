//
// Created by elder on 8/16/2026.
//

#include "deviceFunctions.cuh"


__device__ bool kernelValidPosition(int row, int col) {
    if (row < 0 || row >= H || col < 0 || col >= W) return false;
    return true;
}

__global__ void kernelCountNeighbors(const int *array, int *neighborArray) {

    int col = blockIdx.x * blockDim.x + threadIdx.x;
    int row = blockIdx.y * blockDim.y + threadIdx.y;

    if (kernelValidPosition(row, col) == false) return;

    int count = 0;
    int directions[8][2] {
        //bottom left, left, top left
        {-1, -1}, {-1, 0}, {-1, 1},
        // bottom, top
        {0, -1}, {0, 1},
        // bottom right, right, top right
        {1, -1}, {1, 0}, {1, 1}
    };

    for (const auto &direction : directions) {
        int x = row + direction[0];
        int y = col + direction[1];

        int flatIndex = x * W + y;
        if  (flatIndex < 0 || flatIndex >= H*W) continue;


        if (kernelValidPosition(x, y) == true && array[flatIndex] == 1) count++;
    }

    int globalIndex = row * W + col;
    if (globalIndex >= H*W || globalIndex < 0) return;

    neighborArray[globalIndex] = count;
}

__global__ void kernelChangeCellState(int *array, const int *neighborArray) {
    int col = blockIdx.x * blockDim.x + threadIdx.x;
    int row = blockIdx.y * blockDim.y + threadIdx.y;

    if (kernelValidPosition(row, col) == false) return;
    int globalIndex = row * W + col;

    if (kernelValidPosition(row, col) == false) return;

    if (array[globalIndex] == 1 && neighborArray[globalIndex] < 2) array[globalIndex] = 0; // underpopulation
    if (array[globalIndex] == 1 && neighborArray[globalIndex] > 3) array[globalIndex] = 0; // overpopulation
    if (array[globalIndex] == 1 && (neighborArray[globalIndex] == 2 || (neighborArray[globalIndex] == 3))) return; // enough neighbors
    if (array[globalIndex] == 0 && neighborArray[globalIndex] == 3) array[globalIndex] = 1; // enough neighbors to revive cell
}