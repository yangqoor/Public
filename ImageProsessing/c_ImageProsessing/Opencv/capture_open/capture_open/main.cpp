#include <opencv2/opencv.hpp>  
#include <iostream>  
using namespace cv;
using namespace std;

string name = "my";

int main()
{
	VideoCapture capture; //������Ƶ������  
	capture.open(0); //������ͷ������Ƶ 0��ʾ������ͷ����  

	if (!capture.isOpened()) //���ж��Ƿ������ͷ  
	{
		cout << "can not open";
		cin.get();
		return -1;
	}

	namedWindow(name);

	while (1) {
		Mat cap; //����һ��Mat���������ڴ洢ÿһ֡��ͼ��  
		capture >> cap; //��ȡ��ǰ֡  
		if (!cap.empty()) //�жϵ�ǰ֡�Ƿ�׽�ɹ� **�ⲽ����Ҫ  
			imshow(name, cap); //����ǰ֡��׽�ɹ�����ʾ  
		else
			cout << "can not ";
		waitKey(30); //��ʱ30����  
	}

	return 0;
}