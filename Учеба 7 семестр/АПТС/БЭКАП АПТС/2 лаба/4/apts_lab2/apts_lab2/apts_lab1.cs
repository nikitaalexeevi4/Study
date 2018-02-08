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

    class Apts_lab1
    {
        public string stckLeftStr = "";
        public string stckRightStr = "";
        public string input;
        public List<List<StateLSA>> graph = new List<List<StateLSA>>();
        public string output;
        public int check_cycle = 0;
    
    
        public Stack<int> stackLeft = new Stack<int>();
        public Stack<int> stackRight = new Stack<int>();

        bool checkStack()
        {
            int count = Math.Max(stackLeft.Count, stackRight.Count);
            while (stackLeft.Count > 0)
            {
                int arrowUp = stackLeft.Pop();
                stckLeftStr += " " + arrowUp;
                int arrowDown = -1;
                if (stackRight.Count != 0)
                {
                    arrowDown = stackRight.Pop();
                    stckRightStr += " " + arrowDown;
                }
                if (arrowDown != arrowUp)
                {
                    output += string.Format("Ошибка: невозможно найти ']' {0}", arrowUp);
                    return false;
                }
            }
            return true;
        }

        public Apts_lab1(string _input)
        {
            input = _input;
        }

        int getNumber(ref int ind)
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
                output += "Ошибка: " + ind + "\n";
                throw new Exception();
            }
            return number;
        }

        int findRight(int number)
        {
            int ind = input.IndexOf("]" + number);
            if (ind < 0)
            {
                output += "Ошибка: невозможно найти ]" + number + "\n";
                throw new Exception();
            }
            stackRight.Push(number);
            return ind;
        }

        void addCond_if(List<StateLSA> list, string cond_if)
        {
            foreach (StateLSA item in list)
                item.cond_if = cond_if + item.cond_if;
        }

        public List<StateLSA> getState(int ind)
        {
            if (check_cycle > 100)
            {
                output += "Ошибка цикла: " + ind + "\n";
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

                        if (input[ind] == '[') //up
                        {

                            ind++;
                            int arrow_number = getNumber(ref ind);
                            stackLeft.Push(arrow_number);
                            int new_ind = findRight(arrow_number);
                            List<StateLSA> true_states = getState(new_ind);
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
                            stackLeft.Push(arrow_number);
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

                    case ']':  //
                        ind = input.IndexOf(' ', ind);
                        break;

                    default:
                        output += "Ошибка: " + ind + "\n";
                        throw new Exception();
                }
            }
            check_cycle--;

            return null;
        }

        int maxState()
        {
            int maxItem = 0;
            for (int i = 0; i < input.Length; i++)
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

        public void printGraph()
        {
            for (int i = 0; i < graph.Count - 1; i++)
            {
                output += string.Format("Y{0}: ", i) + "\n";
                for (int j = 0; j < graph[i].Count; j++)
                {
                    output += string.Format("\t Y{0} : {1}", graph[i][j].state, graph[i][j].cond_if) + "\n";
                }
            }
        }

        public void findXY()
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
                        output += "Ошибка: " + i + "\n";
                        throw new Exception();
                    }
                    initY.Add(y_num);
                    i--;
                }
            }
            return;
        }

        public void getLSA()
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
                output += "Ошибка: " + i + "\n";
            }
        }

       
    }
}
