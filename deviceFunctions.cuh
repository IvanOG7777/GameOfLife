//
// Created by elder on 8/16/2026.
//

#ifndef GAMEOFLIFE_DEVICEFUNCTIONS_CUH
#define GAMEOFLIFE_DEVICEFUNCTIONS_CUH

constexpr int W = 10;
constexpr int H = 10;

__device__ bool kernelValidPosition(int row, int col);

__global__ void kernelCountNeighbors(const int *array, int *neighborArray);

__global__ void kernelChangeCellState(int *array, const int *neighborArray);



#endif //GAMEOFLIFE_DEVICEFUNCTIONS_CUH