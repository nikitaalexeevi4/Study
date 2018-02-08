//x+x^3/3+(2*x^5)/15+(17*x^7)/315+(62*x^9)/2835+(1382*x^11)/155925+(21844*x^13)/6081075+(929569*x^15)/638512875+(6404582*x^17)/10854718875+(443861162*x^19)/1856156927625+(18888466084*x^21)/194896477400625+(113927491862*x^23)/2900518163668125+(58870668456604*x^25)/3698160658676859375+(8374643517010684*x^27)/1298054391195577640625+(689005380505609448*x^29)/263505041412702261046875+(129848163681107301953*x^31)/122529844256906551386796875+(1736640792209901647222*x^33)/4043484860477916195764296875


// vpv_lab1.cpp: определяет точку входа для консольного приложения.
//

#include <stdio.h>
#include <iostream>
#include <cmath>
#include <time.h>

//-----------------------------------------------------------------
//МАКРОСЫ ФИКС ЗАПЯТОЙ
// формат: 4 бита - целое, 28 бит - после запятой; 2^28=268435456
// макс=15.999999996
typedef uint32_t PFIX;

#define fix4_28(a) ((PFIX)((a) * (1LL<<28)))
#define fix_to_float(a) ((a) / (double)(1LL<<28))
#define fix_mul(a, b) ((PFIX)(((int64_t)(a) * (b)) >> 28))
#define fix_div(a, b) ((PFIX)(((int64_t)(a) << 28) / (b)))
//-----------------------------------------------------------------

typedef float(*PFLOAT)(float);
typedef  PFIX  (*FUNC_FIX)(PFIX);

using namespace std;

double *bern = new double[100000];
float koef[100]; // коэф ряда с 1 члена
PFIX fix_koef[100]; // коэф для фикс точки
int LENGHT = 17; // длина ряда
float max_delta = 0.00000095367431640625;

/*
struct func{
    PFLOAT fl_func[10];
    FUNC_FIX fix_func[10];

};
*/


double fact(double arg) {
    double res = 1;
    for (int i = 2; i <= arg; i++) {
        res *= i;
    }
    return res;
}

double getC(double n, double k) { // число сочетаний
    double res = fact(n) / (fact(k) * fact(n - k));
    return res;
}

double bernully(int ind) {
    if (bern[ind] != -1)
        return bern[ind];
    double B = 0;// bernully
    double sum = 0;
    for (int k = 1; k <= ind; k++) {
        sum += getC(ind + 1, k + 1) * bernully(ind - k);
    }
    B = -1.0 / (double)(ind + 1) * sum;
    bern[ind] = B;
    return B;
}

void prepare(){
    for (int i = 0; i < 1000; i++)
        bern[i] = -1;
    bern[0] = 1;
    for(int i = 1; i <= 90; i++){
        koef[i] = abs(bernully(2 * i)) * (pow(2.0, 2.0 * i) * (pow(2.0, 2.0 * i) - 1)) / fact(2 * i);
        fix_koef[i] = fix4_28(koef[i]);
        bernully(i);
    }

}

// используется цикл, без схемы горнера
float fl_cycle_no_gorner(float x) {
    int n = LENGHT;
    float sum = 0;
    for (int i = 1; i < n; i++) {
        sum += abs(bernully(2 * i)) * (pow(2.0, 2.0 * i) * (pow(2.0, 2.0 * i) - 1)) / fact(2 * i) * pow(x, 2.0 * i - 1);
    }
    return sum;
}

// без цикла, без схемы горнера
float fl_no_cycle_no_gorner(float x){
    float sum = koef[1] * x + koef[2] * pow(x, 3) + koef[3] * pow(x, 5) + koef[4] * pow(x, 7) + koef[5] * pow(x, 9) +
             koef[6] * pow(x, 11) + koef[7] * pow(x, 13) + koef[8] * pow(x, 15) + koef[9] * pow(x, 17) + koef[10] * pow(x, 19) +
             koef[11] * pow(x, 21) + koef[12] * pow(x, 23) + koef[13] * pow(x, 25) + koef[14] * pow(x, 27) + koef[15] * pow(x, 29) +
             koef[16] * pow(x, 31) + koef[17] * pow(x, 33);
    return sum;
}

//цикловая схема горнера
float fl_cycle_gorner(float x){
    int n = LENGHT;
    float s = koef[n];
    float q = x * x;
    for(int i = n-1; i >= 1; i--){
        s = koef[i] + q * s;
    }
    s = s * x;
    return s;
}

//бесцикловая схема горнера
float fl_no_cycle_gorner(float x){
    float q = x * x;
    float res = x*(koef[1]+q * (koef[2]+q *(koef[3]+q *(koef[4]+q *(koef[5]+q *(koef[6]+q *(koef[7]+q *(koef[8]+q *(koef[9]+q *
            (koef[10]+q *(koef[11]+q *(koef[12]+q *(koef[13]+q *(koef[14]+q *(koef[15]+q *(koef[16]+q *(koef[17])))))))))))))))));
    return res;
}

//функция проверки удовлетворения погрешности
// 0 - не удовлетворяет
int  flverify(float  fl, PFLOAT  p) {
    if (fabs(tan(fl) - p(fl)) > max_delta)
        return 0;
    return 1;
}

// функция подбора длины ряда для заданной точности
int R(){
    for(int i = 1; i < 30; i++) {
        LENGHT = i;
        if (flverify(1, fl_cycle_no_gorner) == 1)
            return i;
    }
    return -1;
}

float time_calc(PFLOAT p){
    int count = 10000000;// число итераций цикла
    cout << "value " << p(0.999) << endl;
    clock_t start = clock();
    for(int i = 0; i < count; i++){
        p(0.999);
    }
    clock_t end = clock();
    float during = ((double)(end - start) / CLOCKS_PER_SEC) * (pow(10.0, 9.0) / count); // тактов за 10^6 запусков = 20 * 10^6 (тактов должно быть)
    return during;
}


//----------------------------------------- фиксированная точка

//циклическая схема горнера
PFIX fix_cycle_gorner(PFIX x){
    int n = LENGHT;
    PFIX s = fix_koef[n];
    PFIX q = fix_mul(x, x);
    for(int i = n-1; i >= 1; i--){
        s = fix_koef[i] + fix_mul(q,  s);
    }
    s = fix_mul(s, x);
    return s;
}

PFIX fix_no_cycle_gorner(PFIX x){
//бесцикловая схема горнера
    PFIX q = fix_mul(x, x);
    PFIX res = fix_mul(x, (
                fix_koef[1]+ fix_mul(q, (
                fix_koef[2]+ fix_mul(q, (
                fix_koef[3]+ fix_mul(q, (
                fix_koef[4]+ fix_mul(q, (
                fix_koef[5]+ fix_mul(q, (
                fix_koef[6]+ fix_mul(q, (
                fix_koef[7]+ fix_mul(q, (
                fix_koef[8]+ fix_mul(q, (
                fix_koef[9]+ fix_mul(q, (
                fix_koef[10]+fix_mul(q, (
                fix_koef[11]+fix_mul(q, (
                fix_koef[12]+fix_mul(q, (
                fix_koef[13]+fix_mul(q, (
                fix_koef[14]+fix_mul(q, (
                fix_koef[15]+fix_mul(q, (
                fix_koef[16]+fix_mul(q, (
                fix_koef[17]))))))))))))))))))))))))))))))))));
    return res;
}

//проверка погрешности
// 0-неудовлетворяет
int fixverify(float x, FUNC_FIX p) {

    float res1 = tan(x);
    PFIX tmp = p(fix4_28(x));
    float res2 = fix_to_float(tmp);
    cout << res1 << ";   " << res2 << endl;
    if(fabs(res1 - res2) > max_delta)
        return 0;
    return 1;
}


float time_calc(FUNC_FIX p){
    PFIX arg = fix4_28(0.999);
    cout << "value " << p(arg) << endl;
    int count = 100000000;            // -------------число итераций цикла
    clock_t start = clock();
    for(int i = 0; i < count; i++){
        p(arg);
    }
    clock_t end = clock();
    float during = ((double)(end - start) / CLOCKS_PER_SEC) * (pow(10.0, 9.0) / count); // тактов за 10^6 запусков = 20 * 10^6 (тактов должно быть)
    return during;
}

//-
// функция тестирования во всем диапазоне х
bool test(FUNC_FIX p) {
    for (float i = 0; i < 1; i += max_delta) {
        if(fixverify(i, p) == 0)
            return false;
    }
    return true;
}

bool test(PFLOAT p) {
    for (float i = 0; i < 1; i += max_delta) {
        if(flverify(i, p) == 0)
            return false;
    }
    return true;
}

//----------------------------------------------
//таблично-алгоритмический метод

const int k = 12;    //бит адреса 8
int table_count = 1 << k; // размер таблицы
float **table = new float*[table_count];

void prepare_table() {
    for(int i = 0; i < table_count; i++){
        table[i] = new float[3];
        float x = (float)i / table_count;
        table[i][0] = tan(x);
        table[i][1] = (float)1 / pow(cos(x), 2);
        table[i][2] = 2 * tan(x) / pow(cos(x), 2) / 2;
    }
    return;
}

float table_method(float x) {
    int a = x * table_count;// старшие k бит
    float h = (x * table_count - a) / table_count;
    float b0 = table[a][0];
    float b1 = table[a][1];
//    float b2 = table[a][2];
    float res = b0 + b1*h;
//    float res = b0 + b1*h + b2*h*h;

    return res;
}

int main()
{ // 0,00000095367431640625 погрешность не более

    prepare();

//    int lenght = R(); // длина ряда

//    bool t1 = test(fix_cycle_gorner);
//    t1 = test(fix_no_cycle_gorner);
//    float res1 = fix_to_float(fix_cycle_gorner(fix4_28(0.785)));
//    res1 = fl_no_cycle_gorner(0.785);
//    float res2 = fix_to_float(fix_no_cycle_gorner(fix4_28(0.785)));

    float e, b, c, a, d;
    e = time_calc(tan);
    b = time_calc(fl_cycle_no_gorner);
    c = time_calc(fl_no_cycle_no_gorner);
    a = time_calc(fl_cycle_gorner);
    d = time_calc(fl_no_cycle_gorner);
    cout << "fl_cycle_no_gorner " << b << endl << "fl_no_cycle_no_gorner " << c << endl << "fl_cycle_gorner " << a << endl << "fl_no_cycle_gorner " << d << endl << "standart " << e << endl;

    cout << "----------------------------------------" << endl << "фикс точка" << endl;
    float a1 = time_calc(fix_cycle_gorner);
    float d1 = time_calc(fix_no_cycle_gorner);
    cout << "fix_cycle_gorner " << a1 << endl << "fix_no_cycle_gorner " << d1 << endl;
    cout << "----------------------------------------" << endl << "таблично-алгоритмический метод" << endl;
    prepare_table();
    float t = time_calc(table_method);
    cout << "table_method " << t << endl;

    if(!test(table_method))
        cout << "error";

    return 0;
}

