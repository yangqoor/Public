#ifndef _CVISUALIZATION_H_
#define _CVISUALIZATION_H_

#include <string>
#include <opencv2/opencv.hpp>

using namespace std;
using namespace cv;

// ���ӻ�ģ�飬����debug���Զ��������ٴ��ڡ�
class CVisualization
{
private:
	string m_winName;		// ��������
public:
	CVisualization(string winName);
	~CVisualization();
	int ShowPeriod(Mat pic, int time, double zoom = 1.0, bool save = false, string savePath = "");
	int Show(Mat pic, int time, bool norm = false, double zoom = 1.0, bool save = false, string savePath = "");
};

#endif