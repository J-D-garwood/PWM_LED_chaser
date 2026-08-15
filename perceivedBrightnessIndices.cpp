// gen_array.cpp
// Builds an array holding 0, 1, 2, ... 1000000 and prints it.
//
// Build: g++ -O2 -o gen_array gen_array.cpp
// Run:   ./gen_array            (1,000,001 lines -- pipe it: ./gen_array > out.txt)

#include <cstdio>
#include <vector>
#include <cmath>

int main() {
    const int MAX = 1000;
    float MAX_i = std::pow(MAX, 0.4f);
    float step = MAX_i/64;
    float margin;
    std::printf("%f\n", margin);
    float working = std::pow(step, 2.5f);

    std::vector<int> arr(64);
    int idx = 1;

    arr[0] = 0;

    for (int i = 0; i <= MAX && idx < 64; ++i) {
        if (i >= working) {
            arr[idx++] = i;
            margin += step;
            working = std::pow(margin, 2.5f);
        }
    }

    for (int i = 0; i < 64; ++i) {
        std::printf("%d\n", arr[i]);
    }

    return 0;
}
