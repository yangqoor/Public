#include <opencv2/opencv.hpp>  
#include <iostream>  
using namespace cv;
using namespace std;

string name = "my";

int main()
{
	VideoCapture capture; //声明视频读入类  
	capture.open(0); //从摄像头读入视频 0表示从摄像头读入  

	if (!capture.isOpened()) //先判断是否打开摄像头  
	{
		cout << "can not open";
		cin.get();
		return -1;
	}

	namedWindow(name);

	while (1) {
		Mat cap; //定义一个Mat变量，用于存储每一帧的图像  
		capture >> cap; //读取当前帧  
		if (!cap.empty()) //判断当前帧是否捕捉成功 **这步很重要  
			imshow(name, cap); //若当前帧捕捉成功，显示  
		else
			cout << "can not ";
		waitKey(30); //延时30毫秒  
	}

	return 0;
}