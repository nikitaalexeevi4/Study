using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;
using apts_lab1;

namespace apts_lab2
{
    public partial class Form1 : Form
    {
        List<List<apts_lab1.StateLSA>> graph;
        List<State> states = new List<State>();
        List<Line> lines = new List<Line>();
        Random rand = new Random();

        public Form1()
        {
            InitializeComponent();
        }

        protected override void OnPaint(PaintEventArgs e)
        {
            base.OnPaint(e);
            Graphics g = e.Graphics;
            for (int i = 0; i < states.Count; i++)
                states[i].draw(g);

            for (int i = 0; i < lines.Count; i++)
                lines[i].draw(g, rand);
        }

        void placeState()
        {
            int R = 300;
            int centerX = 400;
            int centerY = 400;
            double alp = 2 * Math.PI / states.Count;
            for(int i = 0; i < states.Count; i++)
            {
                states[i].x = centerX + (int)(R * Math.Cos(i * alp));
                states[i].y = centerY + (int)(R * Math.Sin(i * alp));
            }
        }

        void gsa()
        {
            //states
            for(int i = 0; i < graph.Count; i++)
            {
                states.Add(new State(0, 0, "Y" + i));
            }
            placeState();

            // lines
            for(int i = 0; i < graph.Count; i++)
            {
                if (graph[i] == null)
                    continue;
                State s1 = states[i];
                for(int j = 0; j < graph[i].Count; j++)
                {
                    State s2 = State.getState(states, graph[i][j]);
                    lines.Add(new Line(s1, s2, graph[i][j].cond_if));
                }
            }
        }

        private void button1_Click(object sender, EventArgs e)
        {
            states.Clear();
            lines.Clear();
            string input = textBox1.Text;
            Apts_lab1 lab1 = new Apts_lab1(input);
            lab1.getLSA();
            textBox2.Text = lab1.output.Replace("\n", "\r\n");
            graph = lab1.graph;
            gsa();
            Refresh();
        }
    }

    class State
    {
        Pen p;
        public int x, y;
        public int r = 70;
        string text;
        Font font = new Font("Arial", 10, FontStyle.Italic);
        public State(int _x = 0, int _y = 0, string _text = "Y")
        {
            x = _x;
            y = _y;
            text = _text;
            p = new Pen(Color.Black);
        }

        public void draw(Graphics g)
        {
            int rectX = x - r / 2;
            int rectY = y - r / 2;
            g.DrawString(text, font, Brushes.Black, x - r/4, y - r/4);
            g.DrawEllipse(p, rectX, rectY, r, r);
        }

        public Point randomPoint(Random rand)
        {
            int range = r / 4;
            int randX = rand.Next(x - range, x + range);
            int randY = rand.Next(y - range, y + range);
            return new Point(randX, randY);
        }

        public static State getState(List<State> states, apts_lab1.StateLSA state)
        {
            int stateNum = int.Parse(state.state);
            return states[stateNum];
        }
    }

    class Line
    {
        Pen p;
        State s1;
        State s2;
        string cond_if;
        Font font = new Font("Arial", 7, FontStyle.Regular);

        public Line(State _s1, State _s2, string _cond_if)
        {
            s1 = _s1;
            s2 = _s2;
            cond_if = _cond_if;
            p = new Pen(Color.Gray, 1.5f);
        }

        public void draw(Graphics g, Random rand)
        {
            int cursorSize = 3;
            Point s2Point = s2.randomPoint(rand);
            g.DrawLine(p, s1.x, s1.y, s2Point.X, s2Point.Y);
            g.DrawEllipse(new Pen(Color.Red, 3), s2Point.X - cursorSize/2, s2Point.Y - cursorSize/2, cursorSize, cursorSize);
            Point cond_ifPoint = new Point(s1.x + (s2Point.X - s1.x) / 2, s1.y + (s2Point.Y - s1.y) / 2);
            g.DrawString(cond_if, font, Brushes.Blue, cond_ifPoint);
        }
    }
}
