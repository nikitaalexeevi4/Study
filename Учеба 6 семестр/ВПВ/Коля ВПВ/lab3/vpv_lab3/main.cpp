# include <stdlib.h>
# include <stdio.h>
# include <math.h>
# include <time.h>
# include "mpi.h"
int main (int argc, char *argv []);
double f (double x);
void timestamp (void);
/******************************************************************************/
int main1 (int argc, char *argv [])
{
    double end_time;
    double h;
    int i;
    int ierr;
    int m;
    int master = 0;
    int n;
    int process;
    int process_id;
    int process_num;
    double q_global;
    double q_local;
    int received;
    int source;
    double start_time;
    MPI_Status status;
    int tag;
    int target;
    double x;
    double xb [2];
    double x_max = 1.5;
    double x_min = 0.0;
    ierr = MPI_Init (&argc, &argv);
    /*
Определим номер текущего процессора.
*/
    ierr = MPI_Comm_rank (MPI_COMM_WORLD, &process_id);
    /*
Получение количества процессоров
*/
    ierr = MPI_Comm_size (MPI_COMM_WORLD, &process_num);
    /*
Проверка количества доступных процессоров
*/
    if (process_id == master)
    {
        timestamp ();
        printf ("\n");
        printf ("Главный процессор: \n");
        printf ("\n");
        printf (" Программа для вычиления определенных интегралов,\n");
        printf (" Назначение подинтервалов процессорам. \n");
        printf ("\n");
        printf (" количество процессоров %d\n", process_num);
        start_time = MPI_Wtime ();
        if (process_num <= 1)
        {
            printf ("\n");
            printf ("главный процессор: \n");
            printf (" Нужно как минимум 2 процессора! \n");
            ierr = MPI_Finalize ();
            printf ("\n");
            printf ("Главный процессор: \n");
            printf (" Ненормальное завершение работы. \n");
            exit (1);
        }
    }
    printf ("\n");
    /*
рассчет точек концов подинтервалов и их рассылка по процессорам - адресатам.
*/
    if (process_id == master)
    {
        for (process = 1; process <= process_num-1; process++)
        {
            xb [0] = ( (double) (process_num - process) * x_min + (double) (process - 1) * x_max) / (double) (process_num - 1);
            xb [1] = ( (double) (process_num - process - 1) * x_min + (double) (process) * x_max) / (double) (process_num - 1);
            target = process;
            tag = 1;
            printf ("Точки интервалов %f! \n", xb [0]);
            ierr = MPI_Send (xb, 2, MPI_DOUBLE, target, tag, MPI_COMM_WORLD);
        }
    }
    else
    {
        source = master;
        tag = 1;
        ierr = MPI_Recv (xb, 2, MPI_DOUBLE, source, tag, MPI_COMM_WORLD, &status);
    }
    /*
дождемся, когда все процессоры получать свои назначения.
*/
    ierr = MPI_Barrier (MPI_COMM_WORLD);
    if (process_id == master)
    {
        printf ("\n");
        printf ("Главный процессор: \n");
        printf (" Подинтервалы назначены. \n");
    }
    /*
каждому процессору нужно передать количество точек
для вычислений по широковещательной рассылке.
*/
    m = 10000 / process_num;
    source = master;
    ierr = MPI_Bcast (&m, 1, MPI_INT, source, MPI_COMM_WORLD);
    /*
каждый процессор выполняет вычисления над своим интервалом и передает результат
процессору 0.
*/
    if (process_id != master)
    {
        q_local = 0.0;
        printf ("Процессор %d активен! \n", process_id);
        for (i = 1; i <= m; i++)
        {
            x = ( (double) (2 * m - 2 * i + 1) * xb [0]
                    + (double) (2 * i - 1) * xb [1])
                    / (double) (2 * m);
            q_local = q_local + f (x);
        }
        q_local = q_local * (xb [1] - xb [0]) / (double) (m);
        target = master;
        tag = 2;
        ierr = MPI_Send (&q_local, 1, MPI_DOUBLE, target, tag, MPI_COMM_WORLD);
    }
    /*
процессор 0 ждет N-1 промежуточного результата.
*/
    else
    {
        received = 0;
        q_global = 0.0;
        while (received < process_num - 1)
        {
            source = MPI_ANY_SOURCE;
            tag = 2;
            ierr = MPI_Recv (&q_local, 1, MPI_DOUBLE, source, tag, MPI_COMM_WORLD,
                             &status);
            q_global = q_global + q_local;
            received = received + 1;
        }
    }
    /*
главный процессор выдает результат
*/
    if (process_id == master)
    {
        printf ("\n");
        printf ("Главный процессор: \n");
        printf (" Интеграл ф-ии F (x) = %f\n", q_global);
        printf (" Ошибка вычислений %f\n", q_global - 0.624);
        end_time = MPI_Wtime ();
        printf ("\n");
        printf (" Время, затраченное на вычисления = %f\n",
                end_time - start_time);
    }
    /*
Terminate MPI.
*/
    ierr = MPI_Finalize ();
    /*
Termiante.
*/
    if (process_id == master)
    {
        printf ("\n");
        printf ("Главный процессор: \n");
        printf (" Нормальное завершение вычислений. \n");
        printf ("\n");
        timestamp ();
    }
    return 0;
}
/************************************************************/
double f (double x)
{
    return tan(x);
}
/************************************************************/
void timestamp (void)
{
# define TIME_SIZE 40
    static char time_buffer [TIME_SIZE];
    const struct tm *tm;
    time_t now;
    now = time (NULL);
    tm = localtime (&now);
    strftime (time_buffer, TIME_SIZE, "%d %B %Y %I: %M: %S %p", tm);
    printf ("%s\n", time_buffer);
    return;
# undef TIME_SIZE
}
