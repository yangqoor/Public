#include "GlobalFunction.h"


int ErrorHandling(string message)
{
	cout << "An Error Occurs:" << message << endl;
	cout << "Input response:";
	int a;
	cin >> a;
	return 0;
}


int CreateDir(string dir_path)
{
	string tmp_path;
	for (int i = 1; i < dir_path.length(); i++)
	{
		if (dir_path[i] == '/')
		{
			tmp_path = dir_path.substr(0, i);

			int status;
			status = MY_ACCESS(tmp_path.c_str(), 0);
			if (status != 0)
			{
				status = MY_MKDIR(tmp_path.c_str());
				if (status != 0)
				{
					ErrorHandling("Error in CreateDir(): " + tmp_path);
					return -1;
				}
			}
		}
	}

	return 0;
}


bool WriteMatData(string path, string name, string idx2str, string suffix, Mat data_mat)
{
	bool status = true;

	if (suffix == ".xml")
	{
		FileStorage fs;
		fs.open(path + name + idx2str + suffix, FileStorage::WRITE);
		if (fs.isOpened())
		{
			fs << name << data_mat;
			fs.release();
		}
		else
		{
			ErrorHandling("Error in WriteMat(): FileStorage open error.\n");
			status = false;
		}
	}
	else if (suffix == ".txt")
	{
		fstream file;
		file.open(path + name + idx2str + suffix, ios::out);
		if (file.is_open())
		{
			Size mat_size = data_mat.size();
			for (int h = 0; h < mat_size.height; h++)
			{
				for (int w = 0; w < mat_size.width; w++)
				{
					file << data_mat.at<double>(h, w) << " ";
				}
				file << endl;
			}
			file.close();
		}
		else
		{
			ErrorHandling("Error in WriteMat(): fstream open error.\n");
			status = false;
		}
	}
	else
	{
		status = false;
	}

	return status;
}