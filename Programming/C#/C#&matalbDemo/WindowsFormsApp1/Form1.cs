using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Windows.Forms;
using MyMatlabFunctionDemo;
using MathWorks.MATLAB.NET.Arrays;
using System.Threading;
using System.Runtime.InteropServices;

namespace WindowsFormsApp1
{
    public partial class Form1 : Form
    {
        #region //Windows API
        [DllImport("user32.dll")]
        public static extern IntPtr FindWindow(string lpClassName, string lpWindowName);//
        [DllImport("user32.dll")]
        public static extern IntPtr SetParent(IntPtr hWndChild, IntPtr hWndNewParent);
        [DllImport("user32.dll", CharSet = CharSet.Auto)]
        public static extern int MoveWindow(IntPtr hWnd, int x, int y, int nWidth, int nHeight, bool BRePaint);

        const int GWL_STYLE = -16;
        const int WS_CAPTION = 0x00C00000;
        const int WS_THICKFRAME = 0x00040000;
        const int WS_SYSMENU = 0X00080000;
        [DllImport("user32")]
        private static extern int GetWindowLong(System.IntPtr hwnd, int nIndex);

        [DllImport("user32")]
        private static extern int SetWindowLong(System.IntPtr hwnd, int index, int newLong);

        /// <summary>最大化窗口，最小化窗口，正常大小窗口
        /// nCmdShow:0隐藏,3最大化,6最小化，5正常显示
        /// </summary>
        //[DllImport("user32.dll", EntryPoint = "ShowWindow")]
        //public static extern int ShowWindow(IntPtr hwnd, int nCmdShow);
        #endregion

        public Form1()
        {
            InitializeComponent();
        }

        public delegate void UpdateUI();//委托用于更新UI
        Thread startload;//线程用于matlab窗体处理
        MatlabFunction matlabFunction;//matlab编译的类
        IntPtr figure1;//图像句柄
        private void Form1_Load(object sender, EventArgs e)
        {
            //实例化线程，用来初次调用matlab，并把图像窗体放到winform
            startload = new Thread(new ThreadStart(startload_run));
            //运行线程方法
            startload.Start();
        }


        void startload_run()
        {
            int count50ms = 0;
            //实例化matlab对象
            matlabFunction = new MatlabFunction();
            //调用方法画高斯分布函数图
            matlabFunction.mysurf();//高斯分布函数

            //循环查找figure1窗体
            while (figure1 == IntPtr.Zero)
            {
                //查找matlab的Figure 1窗体
                figure1 = FindWindow("SunAwtFrame", "Figure 1");  
                //延时50ms
                Thread.Sleep(50);
                count50ms++;
                //20s超时设置
                if (count50ms >= 400)
                {
                    label1.Text = "matlab资源加载时间过长！";
                    return;
                }
            }

            //跨线程，用委托方式执行
            UpdateUI update = delegate
            {
                //隐藏标签
                label1.Visible = false;
                //设置matlab图像窗体的父窗体为panel
                SetParent(figure1, panel1.Handle);
                //获取窗体原来的风格
                var style = GetWindowLong(figure1, GWL_STYLE);
                //设置新风格，去掉标题,不能通过边框改变尺寸
                SetWindowLong(figure1, GWL_STYLE, style & ~WS_CAPTION & ~WS_THICKFRAME);
                //移动到panel里合适的位置并重绘
                MoveWindow(figure1, 0, 0, panel1.Width + 20, panel1.Height + 40, true);
                //调用显示窗体函数，隐藏再显示相当于刷新一下窗体
                //radiobutton按钮使能
                radioButton1.Enabled = true;
                radioButton2.Enabled = true;
                radioButton3.Enabled = true;
                radioButton4.Enabled = true;
                radioButton5.Enabled = true;
                radioButton6.Enabled = true;
               
            };
            panel1.Invoke(update);
            //再移动一次，防止显示错误
            Thread.Sleep(100);
            MoveWindow(figure1, 0, 0, panel1.Width + 20, panel1.Height + 40, true);
        }

        private void radioButton1_CheckedChanged(object sender, EventArgs e)
        {
            matlabFunction.mysurf();//高斯分布函数
        }

        private void radioButton2_CheckedChanged(object sender, EventArgs e)
        {
             //matlabFunction.drawcos();//正余弦图
        }

        private void radioButton3_CheckedChanged(object sender, EventArgs e)
        {
             //matlabFunction.mypolar();//极坐标图
        }

        private void radioButton4_CheckedChanged(object sender, EventArgs e)
        {
            //matlabFunction.my3dlines();//螺旋曲线图
        }

        private void radioButton5_CheckedChanged(object sender, EventArgs e)
        {
            //matlabFunction.mysemilogx();//对数坐标图
        }

        private void radioButton6_CheckedChanged(object sender, EventArgs e)
        {
            //matlabFunction.mymeshc();//Z=X^2+Y^2,3维网格图
        }

        private void Form1_SizeChanged(object sender, EventArgs e)
        {
            MoveWindow(figure1, 0, 0, panel1.Width + 20, panel1.Height + 40, true);
        }

    }
}
