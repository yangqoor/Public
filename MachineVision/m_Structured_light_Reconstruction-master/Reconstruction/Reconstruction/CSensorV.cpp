#include "CSensorV.h"


// ������ģ�顣
// ����ģ�⴫�����������ݡ�
// Ϊ�����������ص������Ѿ����߲ɼ��ã���ģ������ģ�⴫����ģ��������ݵĶ��롣


CSensor::CSensor()
{
	this->m_dataNum = 0;
	this->m_nowNum = 0;
	this->m_filePath = "";
	this->m_fileName = "";
	this->m_fileSuffix = "";

	this->m_dataMats = 0;

}


CSensor::~CSensor()
{
	if (this->m_dataMats != NULL)
	{
		delete[]this->m_dataMats;
		this->m_dataMats = NULL;
	}
}


// ��ʼ�����������趨һЩ����
// ��Ҫ�Ƕ�ȡ���ļ�·������
bool CSensor::InitSensor()
{
	bool status = true;

	FileStorage fs;
	fs.open(CONFIG_PATHNAME, FileStorage::READ);
	if (!fs.isOpened())
	{
		status = false;
	}
	else
	{
		string main_path;
		string data_set_path;
		if (kPlatformFlag == WINDOWS)
		{
			fs["main_path_win"] >> main_path;
		}
		else if (kPlatformFlag == UBUNTU)
		{
			fs["main_path_linux"] >> main_path;
		}
		else
		{
			return false;
		}
		fs["data_set_path"] >> data_set_path;
		this->data_path_ = main_path + data_set_path;
		fs["dyna_mat_path"] >> this->dyna_path_;
		fs["dyna_mat_name"] >> this->dyna_name_;
		fs["dyna_mat_suffix"] >> this->dyna_suffix_;
		fs.release();
	}
	

	return status;
}


// �رմ�����
bool CSensor::CloseSensor()
{
	bool status = true;
	
	this->UnloadDatas();

	return status;
}


// Read data into memory
bool CSensor::LoadDatas(int max_frame_num)
{
	// if avaliable
	if (this->m_dataMats != NULL)
	{
		this->UnloadDatas();
	}

	// Read dynaMats from files
	this->m_dataNum = max_frame_num;
	this->m_nowNum = 0;
	this->m_filePath = this->data_path_ + this->dyna_path_;
	this->m_fileName = this->dyna_name_;
	this->m_fileSuffix = this->dyna_suffix_;

	// Read files
	this->m_dataMats = new Mat[this->m_dataNum];
	for (int i = 0; i < this->m_dataNum; i++)
	{
		Mat tempMat;
		string idx2Str;
		strstream ss;
		ss << i ;
		ss >> idx2Str;
		
		tempMat = imread(this->m_filePath
			+ this->m_fileName
			+ idx2Str
			+ this->m_fileSuffix, CV_LOAD_IMAGE_GRAYSCALE);
		tempMat.copyTo(this->m_dataMats[i]);

		/*cout << this->m_filePath
			+ this->m_fileName
			+ idx2Str
			+ this->m_fileSuffix << endl;*/

		if (tempMat.empty())
		{
			ErrorHandling("CSensor::LoadPatterns::<Read>, imread error: "
				+ this->m_filePath
				+ this->m_fileName
				+ idx2Str
				+ this->m_fileSuffix);
		}
	}

	return true;
}


// Release data
bool CSensor::UnloadDatas()
{
	if (this->m_dataMats != NULL)
	{
		delete[]this->m_dataMats;
		this->m_dataMats = NULL;
	}
	
	this->m_dataNum = 0;
	this->m_nowNum = 0;
	this->m_filePath = "";
	this->m_fileName = "";
	this->m_fileSuffix = "";

	return true;
}


// ����ͶӰ��ͶӰ��ͼ��
bool CSensor::SetProPicture(int nowNum)
{
	bool status = true;

	// �������Ƿ�Ϸ�
	if (nowNum >= this->m_dataNum)
	{
		status = false;
		return status;
	}

	this->m_nowNum = nowNum;

	return status;
}


// ��ȡ���ͼ��
Mat CSensor::GetCamPicture()
{
	bool status = true;

	Mat tempMat;
	this->m_dataMats[this->m_nowNum].copyTo(tempMat);

	return tempMat;
}