#include <opencv2/opencv.hpp> //头文件
using namespace cv; //包含cv命名空间

static void ShowHelpText();

int main()
{
	system("color 2F");
	ShowHelpText();

	Mat img = imread("F:\\520.jpg");
	namedWindow("原图",CV_WINDOW_NORMAL);
	imshow("原图", img);
	waitKey(0);
	return 0;
}
static void ShowHelpText()
{
	//输出欢迎信息和OpenCV版本
	printf("\n\n\t\t\t\t欢迎使用OpenCV\n");
	printf("\n\n\t\t\t   当前使用的OpenCV版本为：" CV_VERSION);
	printf("\n\n  ----------------------------------------------------------------------------\n");

	//输出一些帮助信息
	printf("\n\n\t\t\t\t任意键退出\n");
}