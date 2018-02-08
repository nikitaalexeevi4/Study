#include <iostream>
#include <cmath>
#include <omp.h>
#include <time.h>
using namespace std;

double integral(int n, double a, double b, double& time, int thread_count)
{
    double sum = 0;
    double d_x = (double)fabs(a - b) / n;
    double start = omp_get_wtime();
    omp_set_num_threads(thread_count);
#pragma omp parallel
    {

        double x = 0;
        bool first_time = true;
#pragma omp for reduction(+:sum)
        for(int i = 0; i < n; i++)
        {
            if(first_time){
                x = a + i * d_x;
                first_time = false;
            }
            sum += d_x * tan(x);
            x += d_x;
        }
    }
    double end = omp_get_wtime();
    time = end - start;
    return sum;
}

int main(){
    int n = 10;
    double res;
    for(int threads = 1; threads <= 8; threads++){
        double min_time = INT32_MAX;
        for(int i = 0; i < n; i++){
            double time = 0;
            res = integral(1000000, 0, 1.57, time, threads);
            if (time < min_time){
                min_time = time;
            }
        }
        cout << "threads " << threads << " time(mcs) "<< min_time * 1000000 << endl;
    }
    return 0;
}

