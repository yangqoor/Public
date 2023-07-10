#include <iostream>
#include <fstream>
#include <string>
#include <strstream>
#include <opencv2/opencv.hpp>
#include <opencv2/highgui.hpp>


using namespace std;
using namespace cv;


bool xml2txt(string xml_path, 
	string xml_name, 
	string txt_path,  
	string * mat_names,
	int num_mat_name,
	int num_frame)
{
	bool status = true;

	Mat * mats;
	mats = new Mat[num_mat_name];

	for (int idx_frame = 0; idx_frame < num_frame; idx_frame++)
	{
		strstream ss;
		string idx2str;
		ss << idx_frame;
		ss >> idx2str;

		FileStorage fs;
		fs.open(xml_path + xml_name + idx2str + ".xml", FileStorage::READ);
		if (fs.isOpened())
		{
			for (int idx_mat = 0; idx_mat < num_mat_name; idx_mat++)
			{
				fs[mat_names[idx_mat]] >> mats[idx_mat];

				fstream file;
				file.open(txt_path + mat_names[idx_mat] +idx2str + ".txt", ios::out);
				if (file.is_open())
				{
					Size mat_size = mats[idx_mat].size();
					for (int h = 0; h < mat_size.height; h++)
					{
						for (int w = 0; w < mat_size.width; w++)
						{
							file << mats[idx_mat].at<double>(h, w) << " ";
						}
						file << endl;
					}
					file.close();
				}
				else
				{
					printf("Error in open txt file.\n");
					break;
				}
			}
			fs.release();
		}
		else
		{
			printf("Error in open xml file.\n");
			break;
		}

		printf("Frame %d finished.\n", idx_frame);
	}

	delete[]mats;

	return status;
}


int main()
{
	/*string file_path = "E:/Structured_Light_Data/20170414/1/dyna/";
	string file_name = "dyna_mat";
	string file_suffix = ".png";

	VideoWriter writer("1.avi", CV_FOURCC('X', 'V', 'I', 'D'), 6, Size(1280, 1024));
	for (int idx = 0; idx < 31; idx++)
	{
		stringstream ss;
		ss << idx;
		string idx2str;
		ss >> idx2str;

		Mat img = imread(file_path + file_name + idx2str + file_suffix);
		writer << img;
	}
	return 0;*/

	/*string xml_path = "E:/Structured_Light_Data/20170410/StatueForward2/pro/";
	string xml_name = "jpro_mat";
	string txt_path = "E:/Structured_Light_Data/20170410/StatueForward2/ground_truth/";*/
	string xml_path = "E:/Structured_Light_Data/20171104/StatueMR/pro/";
	string txt_path = "E:/Structured_Light_Data/20171104/StatueMR/pro_txt/";
	int total_frame = 1;

	// Create Folder
	string tmp_path = txt_path;
	for (int i = 0; i < tmp_path.length(); i++) {
		if (tmp_path[i] == '/')
			tmp_path[i] = '\\';
	}
	system((string("mkdir ") + tmp_path).c_str());

	string xml_name = "xpro_mat";
	string mat_names_depth[1] = { "xpro_mat" };
	xml2txt(xml_path,
		xml_name,
		txt_path,
		mat_names_depth,
		1,
		total_frame);

	xml_name = "ypro_mat";
	mat_names_depth[0] = "ypro_mat";
	xml2txt(xml_path,
		xml_name,
		txt_path,
		mat_names_depth,
		1,
		total_frame);

	system("PAUSE");
	return 0;
}