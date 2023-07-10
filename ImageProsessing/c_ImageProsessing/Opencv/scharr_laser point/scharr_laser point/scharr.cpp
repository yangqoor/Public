#include <opencv2/opencv.hpp>
#include<opencv2/highgui/highgui.hpp>
#include<opencv2/imgproc/imgproc.hpp>//头文件
using namespace cv;//命名空间
int main()
{
	//创建 grad_x 和 grad_y 矩阵
	Mat grad_x, grad_y;
	Mat abs_grad_x, abs_grad_y, dst;
	//载入显示原始图  
	Mat srcImage = imread("3tisucai.jpg",0);
	if (!srcImage.data) { printf("读取srcImage错误~！ \n"); return false; }	//载入原始图
	namedWindow("灰度图", CV_WINDOW_NORMAL);
	imshow("灰度图", srcImage);
	Mat bw;
	threshold(srcImage, bw, 227, 255, CV_THRESH_BINARY);//二值化阈值=220
	//Mat est, dist;
	//erode(bw, est, Mat(1, 1, CV_8U), Point(-1, -1), 1);
	//dilate(est, dist, Mat(1, 1, CV_8U), Point(-1, -1), 1);
	namedWindow("二值图", CV_WINDOW_NORMAL);
	imshow("二值图", bw);//二值图
	//求 X方向梯度
	Scharr(bw, grad_x, CV_16S, 1, 0, 0.3, 0, BORDER_DEFAULT);
	convertScaleAbs(grad_x, abs_grad_x);
	//求Y方向梯度
	Scharr(bw, grad_y, CV_16S, 0, 1, 0.3, 0, BORDER_DEFAULT);
	convertScaleAbs(grad_y, abs_grad_y);
	//近似合并梯度
	addWeighted(abs_grad_x, 0.5, abs_grad_y, 0.5, 0, dst);
	namedWindow("scharr效果图", CV_WINDOW_NORMAL);   
	imshow("scharr效果图", dst);
	//////锐化
	////Mat rst;
	////Mat kernel(3, 3, CV_32F, Scalar(-1));
	////// 分配像素置  
	////kernel.at<float>(1, 1) = 7;
	////filter2D(dst, rst, dst.depth(), kernel);
	////namedWindow("scharr锐化", CV_WINDOW_NORMAL); //创建一个名为 "锐化"的窗口  
	////imshow("scharr锐化", rst);
	//Mat rst,dilst;
	//
	//dilate(dst, rst, Mat(1, 1, CV_8U), Point(-1, -1), 1);
	//erode(rst,dilst, Mat(1, 1, CV_8U), Point(-1, -1), 1);
	//namedWindow("scharr锐化", CV_WINDOW_NORMAL); //创建一个名为 "锐化"的窗口  
	//imshow("scharr锐化",dilst);

	waitKey(0);
	return 0;
}
