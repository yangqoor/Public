#include <opencv2/opencv.hpp> //ͷ�ļ�
using namespace cv; //����cv�����ռ�

static void ShowHelpText();

int main()
{
	system("color 2F");
	ShowHelpText();

	Mat img = imread("F:\\520.jpg");
	namedWindow("ԭͼ",CV_WINDOW_NORMAL);
	imshow("ԭͼ", img);
	waitKey(0);
	return 0;
}
static void ShowHelpText()
{
	//�����ӭ��Ϣ��OpenCV�汾
	printf("\n\n\t\t\t\t��ӭʹ��OpenCV\n");
	printf("\n\n\t\t\t   ��ǰʹ�õ�OpenCV�汾Ϊ��" CV_VERSION);
	printf("\n\n  ----------------------------------------------------------------------------\n");

	//���һЩ������Ϣ
	printf("\n\n\t\t\t\t������˳�\n");
}