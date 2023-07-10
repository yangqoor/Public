#include <opencv2/opencv.hpp>
#include<opencv2/highgui/highgui.hpp>
#include<opencv2/imgproc/imgproc.hpp>//ͷ�ļ�
using namespace cv;//�����ռ�
int main()
{
	//���� grad_x �� grad_y ����
	Mat grad_x, grad_y;
	Mat abs_grad_x, abs_grad_y, dst;
	//������ʾԭʼͼ  
	Mat srcImage = imread("3tisucai.jpg",0);
	if (!srcImage.data) { printf("��ȡsrcImage����~�� \n"); return false; }	//����ԭʼͼ
	namedWindow("�Ҷ�ͼ", CV_WINDOW_NORMAL);
	imshow("�Ҷ�ͼ", srcImage);
	Mat bw;
	threshold(srcImage, bw, 227, 255, CV_THRESH_BINARY);//��ֵ����ֵ=220
	//Mat est, dist;
	//erode(bw, est, Mat(1, 1, CV_8U), Point(-1, -1), 1);
	//dilate(est, dist, Mat(1, 1, CV_8U), Point(-1, -1), 1);
	namedWindow("��ֵͼ", CV_WINDOW_NORMAL);
	imshow("��ֵͼ", bw);//��ֵͼ
	//�� X�����ݶ�
	Scharr(bw, grad_x, CV_16S, 1, 0, 0.3, 0, BORDER_DEFAULT);
	convertScaleAbs(grad_x, abs_grad_x);
	//��Y�����ݶ�
	Scharr(bw, grad_y, CV_16S, 0, 1, 0.3, 0, BORDER_DEFAULT);
	convertScaleAbs(grad_y, abs_grad_y);
	//���ƺϲ��ݶ�
	addWeighted(abs_grad_x, 0.5, abs_grad_y, 0.5, 0, dst);
	namedWindow("scharrЧ��ͼ", CV_WINDOW_NORMAL);   
	imshow("scharrЧ��ͼ", dst);
	//////��
	////Mat rst;
	////Mat kernel(3, 3, CV_32F, Scalar(-1));
	////// ����������  
	////kernel.at<float>(1, 1) = 7;
	////filter2D(dst, rst, dst.depth(), kernel);
	////namedWindow("scharr��", CV_WINDOW_NORMAL); //����һ����Ϊ "��"�Ĵ���  
	////imshow("scharr��", rst);
	//Mat rst,dilst;
	//
	//dilate(dst, rst, Mat(1, 1, CV_8U), Point(-1, -1), 1);
	//erode(rst,dilst, Mat(1, 1, CV_8U), Point(-1, -1), 1);
	//namedWindow("scharr��", CV_WINDOW_NORMAL); //����һ����Ϊ "��"�Ĵ���  
	//imshow("scharr��",dilst);

	waitKey(0);
	return 0;
}
