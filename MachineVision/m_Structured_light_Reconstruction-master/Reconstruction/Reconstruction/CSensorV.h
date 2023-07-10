#ifndef _CSENSOR_H_
#define _CSENSOR_H_

#include <string>
#include <opencv2/opencv.hpp>
#include <strstream>
#include "StaticParameters.h"
#include "GlobalFunction.h"
#include "CStorage.h"

using namespace std;
using namespace cv;

// ������ģ�顣
class CSensor
{
private:
	// ��ǰ��ȡ������أ�
	int m_dataNum;
	int m_nowNum;
	string m_filePath;
	string m_fileName;
	string m_fileSuffix;

	// �������ݣ�
	string data_path_;	// һ�����ݵ�path
	string dyna_path_;
	string dyna_name_;
	string dyna_suffix_;

	// �洢�����ͼ��
	Mat * m_dataMats;

public:
	CSensor();
	~CSensor();

	// ��ʼ��������
	bool InitSensor();

	// �رմ�����
	bool CloseSensor();

	// ��ȡͼ��
	bool LoadDatas(int max_frame_num);

	// �ͷ��Ѷ�ȡͼ��
	bool UnloadDatas();

	// ����ͶӰ��ͶӰ��ͼ��
	bool SetProPicture(int nowNum);
	
	// ��ȡ���ͼ��
	Mat GetCamPicture();
};

#endif