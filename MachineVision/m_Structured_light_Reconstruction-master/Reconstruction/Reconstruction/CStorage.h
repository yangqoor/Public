#ifndef _CSTORAGE_H_
#define _CSTORAGE_H_

#include <iostream>
#include <string>
#include <strstream>
#include <opencv2/opencv.hpp>
#include "GlobalFunction.h"
using namespace std;
using namespace cv;

// ���ݴ洢ģ�顣�洢�м��������浵
class CStorage
{
private:
	string m_matFilePath;
	string m_matFileName;
	string m_matFileSuffix;
	string m_storagePath;		// ���ڴ洢������·����debug�á�
public:
	CStorage();
	~CStorage();
	bool Store(Mat *pictures, int num);		// �洢ͼƬ��

	bool SetMatFileName(std::string matFilePath,	// �趨�洢·��������
		std::string matFileName,
		std::string matFileSuffix);
};

#endif