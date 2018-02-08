/*
 * launch mpi: mpirun -ppn 1 -n 1 -hostfile mpi_hosts ./vpv_lab3
 *
 *
 * */

#include <iostream>
#include <cmath>
#include <mpi.h>
#include <time.h>
using namespace std;

double integral(int n, double a, double b)
{
    double sum = 0;
    double d_x = (double)fabs(a - b) / n;
    {

        double x = 0;
        bool first_time = true;
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
    return sum;
}

int main(int argc, char *argv[]){
    int n = 1000;
    double a = 0, b = 1.57;
    double res = 0;
    int process_id;
    int ierr;
    int process_num;
    MPI_Status status;
    int master = 0;
    MPI_Init (&argc, &argv);
    ierr = MPI_Comm_rank (MPI_COMM_WORLD, &process_id); //
    /*
Получение количества процессоров
*/
    ierr = MPI_Comm_size (MPI_COMM_WORLD, &process_num);


    double proc_arg[3];
    double delta = fabs(a - b) / (process_num);
    double proc_n = (double) n / (process_num);
    int tag = 1;
    clock_t start = clock();

    if(process_id == master){
        cout << "processors count " << process_num << endl;
        for (int process = 1; process < process_num; process++)
        {
            proc_arg[0] = a + delta * (process);
            proc_arg[1] = proc_arg[0] + delta;
            proc_arg[2] = proc_n;
            cout << "x1=" << proc_arg[0] << " x2=" << proc_arg[1] << endl;
            ierr = MPI_Send (proc_arg, 3, MPI_DOUBLE, process, tag, MPI_COMM_WORLD);

        }
        cout << "recive: x1=" << a << "; x2=" << a+delta << "; process_id: " << process_id << endl;

    } else{
        ierr = MPI_Recv(proc_arg, 3, MPI_DOUBLE, master, tag, MPI_COMM_WORLD, &status);
        cout << "recive: x1=" << proc_arg[0] << "; x2=" << proc_arg[1] << "; process_id: " << process_id << endl;
    }

    ierr = MPI_Barrier (MPI_COMM_WORLD);
    if(process_id != master){

        double res_l = integral(proc_arg[2], proc_arg[0], proc_arg[1]);
        int target = master;
        tag = 2;
        ierr = MPI_Send (&res_l, 1, MPI_DOUBLE, target, tag, MPI_COMM_WORLD);
    } else {
        res = integral(proc_n, a, a+delta); // master process
        for(int i = 0; i < process_num - 1; i++){
            double res_l = 0;
            tag = 2;
            ierr = MPI_Recv (&res_l, 1, MPI_DOUBLE, MPI_ANY_SOURCE, tag, MPI_COMM_WORLD, &status);
            res += res_l;
        }
        clock_t end = clock();
        float during = ((double)(end - start) / CLOCKS_PER_SEC);
        cout << "res " << res << "; time " << during << endl;
    }
    ierr = MPI_Finalize ();


    return 0;
}

