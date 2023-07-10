#include "opencv2/imgproc/imgproc.hpp"
#include"opencv2/highgui/highgui.hpp"
#include<iostream>
int main()
{
	//无初始化矩阵
	cv::Mat image1;
	//6行6列8位单通道矩阵
	cv::Mat image2(6,6,CV_8UC1);
	//7*7，8位3通道矩阵
	cv::Mat image3(cv::Size(7,7),CV_8UC3);
	//8*8，1+3j填充复矩阵
	cv::Mat image4(8,8,CV_32FC2,cv::Scalar(1,3));
	//9*9，8位3通道矩阵
	cv::Mat image5(cv::Size(9,9),CV_8UC3,cv::Scalar(1,2,3));
	//image2赋值给image6
	cv::Mat image6(image2);
	//输出矩阵
	std::cout << image1 << std::endl;
	std::cout << image2 << std::endl;
	std::cout << image3 << std::endl;
	std::cout << image4 << std::endl;
	std::cout << image5 << std::endl;
	std::cout << image6 << std::endl;
	return 0;
}