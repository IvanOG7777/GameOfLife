//
// Created by elder on 8/16/2026.
//

#include <iostream>
#include "deviceFunctions.cuh"

constexpr int MAX_TIME = 25;


bool validPosition(int row, int col) {
    if (row < 0 || row >= H || col < 0 || col >= W) return false;
    return true;
}

void countNeighbor(int *array, int *neighborCount) {
    int directions[8][2] {
        //bottom left, left, top left
        {-1, -1}, {-1, 0}, {-1, 1},
        // bottom, top
        {0, -1}, {0, 1},
        // bottom right, right, top right
        {1, -1}, {1, 0}, {1, 1}
    };


    for (int row = 0; row < H; row++) {
        for (int col = 0; col < W; col++) {
            int count = 0;
            int flatIndex = row * W + col;
            for (auto &direction : directions) {
                int x = row + direction[0];
                int y = col + direction[1];

                int innerFlatIndex = x * W + y;

                if (innerFlatIndex < 0) continue;

                if (validPosition(x, y) == true && array[innerFlatIndex] == 1) {
                    count++;
                }
            }

            neighborCount[flatIndex] = count;
        }
    }
}

void changeCellState(int *array, const int *neighborArray) {
    for (int row = 0; row < H; row++) {
        for (int col = 0; col < W; col++) {
            int flatIndex = row * W + col;

            if (array[flatIndex] == 1 && neighborArray[flatIndex] < 2) array[flatIndex] = 0; // underpopulation
            if (array[flatIndex] == 1 && neighborArray[flatIndex] > 3) array[flatIndex] = 0; // overpopulation
            if (array[flatIndex] == 1 && (neighborArray[flatIndex] == 2 || neighborArray[flatIndex] == 3)) continue; // enough neighbors
            if (array[flatIndex] == 0 && neighborArray[flatIndex] == 3) array[flatIndex] = 1; // dead cell comes back to life
        }
    }
}

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

    for (int i = 0; i < 50; i++) {
        int randRow = rand() % ((H - 1) - 0 + 1) + 0;
        int randCol = rand() % ((H - 1) + 1) + 0;

        int flatIndex = randRow * W + randCol;

        if (flatIndex >= H*W) {
            array[flatIndex - H*W] = 1;
        }

        array[flatIndex] = 1;
    }
    int currentTime = 0;
    while (currentTime++ < MAX_TIME) {
        for (int row = 0; row < H; row++) {
            for (int col = 0; col < W; col++) {
                int flatIndex = row * W + col;
                std:: cout << array[flatIndex] << " ";
            }
            std:: cout << std:: endl;
        }

        countNeighbor(array, neighborArray);

        changeCellState(array, neighborArray);
        std:: cout << std:: endl;
    }
}