#include "CStorage.h"

CStorage::CStorage()
{
	this->m_matFilePath = "";
	this->m_matFileName = "";
	this->m_matFileSuffix = "";
	this->m_storagePath = "";
}

CStorage::~CStorage()
{

}

bool CStorage::Store(Mat * pictures, int num)
{

	// �жϲ����Ƿ�Ϸ�
	if (num <= 0)
		return false;

	bool status = true;

	// �洢
	for (int i = 0; i < num; i++)
	{
		std::strstream ss;
		string IdxtoStr;
		ss << i;
		ss >> IdxtoStr;

		status = imwrite(
			this->m_matFilePath	
			+ this->m_matFileName 
			+ IdxtoStr 
			+ this->m_matFileSuffix,
			pictures[i]);
		if (!status)
		{
			// ����Ŀ¼
			string temp = this->m_matFilePath;
			for (int x = 0; x < temp.length(); x++)
			{
				if (temp[x] == '/')
					temp[x] = '\\';
			}
			system((string("mkdir ") + temp).c_str());
			status = imwrite(
				this->m_matFilePath 
				+ this->m_matFileName
				+ IdxtoStr 
				+ this->m_matFileSuffix,
				pictures[i]);
		}
	}
	//if (num == 1)
	//{
	//	status = imwrite(this->m_storagePath, *pictures);
	//	if (!status)
	//	{
	//		// ����Ŀ¼
	//		string temp = this->m_matFilePath;
	//		for (int i = 0; i < temp.length(); i++)
	//		{
	//			if (temp[i] == '/')
	//				temp[i] = '\\';
	//		}
	//		system((string("mkdir ") + temp).c_str());
	//		status = imwrite(this->m_storagePath, *pictures);
	//	}
	//}
	//else
	//{
	//	for (int i = 0; i < num; i++)
	//	{
	//		status = imwrite(this->m_storagePath, pictures[i]);
	//		if (!status)
	//		{
	//			// ����Ŀ¼
	//			string temp = this->m_matFilePath;
	//			for (int i = 0; i < temp.length(); i++)
	//			{
	//				if (temp[i] == '/')
	//					temp[i] = '\\';
	//			}
	//			system((string("mkdir ") + temp).c_str());
	//			status = imwrite(this->m_storagePath, pictures[i]);
	//		}
	//	}
	//}

	if (!status)
	{
		ErrorHandling("CStorage.Store->imwrite Error.");
	}

	return true;
}

// �趨�洢Ŀ¼
bool CStorage::SetMatFileName(string matFilePath,
	string matFileName,
	string matFileSuffix)
{

	// �������
	this->m_matFilePath = matFilePath;
	this->m_matFileName = matFileName;
	this->m_matFileSuffix = matFileSuffix;
	//this->m_storagePath = matFilePath + matFileName + matFileSuffix;

	//// stringת��
	//string temp = matFilePath;
	//for (int i = 0; i < temp.length(); i++)
	//{
	//	if (temp[i] == '/')
	//		temp[i] = '\\';
	//}

	//// ����Ŀ¼
	//system((string("mkdir ") + temp).c_str());
	
	return true;
}