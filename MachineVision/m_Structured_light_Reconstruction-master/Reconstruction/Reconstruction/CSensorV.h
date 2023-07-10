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

// 传感器模块。
class CSensor
{
private:
	// 当前读取数据相关：
	int m_dataNum;
	int m_nowNum;
	string m_filePath;
	string m_fileName;
	string m_fileSuffix;

	// 总体数据：
	string data_path_;	// 一组数据的path
	string dyna_path_;
	string dyna_name_;
	string dyna_suffix_;

	// 存储的相机图案
	Mat * m_dataMats;

public:
	CSensor();
	~CSensor();

	// 初始化传感器
	bool InitSensor();

	// 关闭传感器
	bool CloseSensor();

	// 读取图案
	bool LoadDatas(int max_frame_num);

	// 释放已读取图案
	bool UnloadDatas();

	// 设置投影仪投影的图像
	bool SetProPicture(int nowNum);
	
	// 获取相机图像
	Mat GetCamPicture();
};

#endif