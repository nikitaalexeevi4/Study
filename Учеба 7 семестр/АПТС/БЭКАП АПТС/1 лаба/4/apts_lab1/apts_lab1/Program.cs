using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace apts_lab1
{
    class StateLSA
    {
        public string state;
        public string cond_if;
    }

    class Program
    {
        public static string input;
        public static List<List<StateLSA>> graph = new List<List<StateLSA>>();

        public static int check_cycle = 0;

        public static int getNumber(ref int ind)
        {
            int number = 0;
            try
            {

                int space_ind = input.IndexOf(' ', ind);
                if (space_ind < 0)
                    space_ind = input.Length;
                string sub_str = input.Substring(ind, space_ind - ind);
                number = int.Parse(sub_str);
                ind = space_ind + 1;
            }
            catch (Exception)
            {
                Console.WriteLine("Ошибка: " + ind);
                throw new Exception();
            }
            return number;
        }

        public static int findRight(int number)
        {
            int ind = input.IndexOf("]" + number);
            if(ind < 0)
            {
                Console.WriteLine("Ошибка: невозможно найти ] " + number);
                throw new Exception();
            }
                
            return ind;
        }

        public static void addCond_if(List<StateLSA> list, string cond_if)
        {
            foreach(StateLSA item in list)
                item.cond_if = cond_if + item.cond_if;
        }

        public static List<StateLSA> getState(int ind)
        {
            if(check_cycle > 100)
            {
                Console.WriteLine("Ошибка цикла: " + ind);
                throw new Exception();
            }

            check_cycle++;
            List<StateLSA> states = new List<StateLSA>();
            while (ind < input.Length)
            {
                switch (input[ind])
                {
                    case 'Y':
                        ind++;
                        int state_number = getNumber(ref ind);
                        states.Add(new StateLSA { state = state_number.ToString(), cond_if = "" });
                        check_cycle--;
                        return states;

                    case 'X':
                        ind++;
                        int x_number = getNumber(ref ind);
                        string cond_if = "X" + x_number;

                        if (input[ind] == '[') // Стрелка вверх
                        {
                            ind++;
                            int arrow_number = getNumber(ref ind);
                            int new_ind = findRight(arrow_number);
                            List<StateLSA>true_states = getState(new_ind);
                            addCond_if(true_states, cond_if);
                            states.AddRange(true_states);


                            List<StateLSA> false_states = getState(ind);
                            addCond_if(false_states, "!" + cond_if);
                            states.AddRange(false_states);
                            check_cycle--;

                            return states;
                        }
                        break;

                    case 'W':
                        ind += 2;
                        cond_if = "W";

                        if (input[ind] == '[')
                        {
                            ind++;
                            int arrow_number = getNumber(ref ind);
                            int new_ind = findRight(arrow_number);
                            List<StateLSA> true_states = getState(new_ind);
                            addCond_if(true_states, cond_if);
                            states.AddRange(true_states);
                            check_cycle--;

                            return states;
                        }
                        break;

                    case ' ':
                        ind++;
                        break;

                    case ']':  // Стрелка вниз
                        ind = input.IndexOf(' ', ind);
                        break;

                    default:
                        Console.WriteLine("Ошибка: " + ind);
                        throw new Exception("Ошибка: " + ind);
                }
            }
            check_cycle--;

            return null;
        }

        public static int maxState()
        {
            int maxItem = 0;
            for(int i = 0; i < input.Length; i++)
            {
                if (input[i] == 'Y')
                {
                    i++;
                    int num = getNumber(ref i);
                    if (num > maxItem)
                        maxItem = num;
                }
            }
            return maxItem;
        }

        public static void printGraph()
        {
            for(int i = 0; i < graph.Count - 1; i++)
            {
                Console.WriteLine("Y{0}: ", i);
                for(int j = 0; j < graph[i].Count; j++)
                {
                    Console.WriteLine("\t Y{0} : {1}", graph[i][j].state, graph[i][j].cond_if);
                }
            }
        }

        public static void findXY()
        {
            List<int> initX = new List<int>();
            List<int> initY = new List<int>();

            for (int i = 0; i < input.Length; i++)
            {
                if (input[i] == 'Y')
                {
                    i++;
                    int y_num = getNumber(ref i);
                    if (initY.Contains(y_num))
                    {
                        Console.WriteLine("Ошибка: " + i);
                        throw new Exception();
                    }
                    initY.Add(y_num);
                    i--;
                }
                else if (input[i] == 'X')
                {
                    i++;
                    int x_num = getNumber(ref i);
                    if (initX.Contains(x_num))
                    {
                        Console.WriteLine("Ошибка: " + i);
                        throw new Exception();
                    }
                    initX.Add(x_num);
                    i--;
                }
            }
            return;
        }

        public static void getLSA()
        {
            int i = 0;
            try
            {
                findXY();
                int max_state = maxState();
                graph = new List<List<StateLSA>>(new List<StateLSA>[max_state + 1]);
                for (i = 0; i < input.Length; i++)
                {
                    if (input[i] == 'Y')
                    {
                        i++;
                        int state_number = getNumber(ref i);
                        i--;
                        var state = getState(i);
                        graph[state_number] = state;
                    }
                }
                printGraph();
            }
            catch (Exception e)
            {
                Console.WriteLine("Ошибка: " + i);
            }
        }

        static void Main(string[] args)
        {
            Console.WriteLine("Лабораторная работа №1. АПТС");
            Console.WriteLine("Выполнил: студент ИВТВМбд-41 Захарычев Н.А");
            Console.WriteLine("Введите входную строку (ЛСА):");
            input = Console.ReadLine();
            Console.WriteLine("Результат:");
            getLSA();

            Console.ReadKey();
        }
    }
}
