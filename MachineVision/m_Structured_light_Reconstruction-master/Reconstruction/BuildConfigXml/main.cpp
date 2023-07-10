#include <iostream>
#include <opencv2/opencv.hpp>
#include <string>

enum PlatformFlag
{
	WINDOWS,
	UBUNTU,
};
const PlatformFlag kPlatformFlag = UBUNTU;

using namespace std;
using namespace cv;

int main()
{
	/// xml file parameters
	string xml_file_path = "../Reconstruction/";
	string xml_file_name = "config.xml";


	/// program parameters
	
	// main path
	string main_path_win = "E:/Structured_Light_Data/";
	string main_path_linux = "/home/rukun/Structured_Light_Data/";
	string data_set_path = "20170410/StatueForward/";

	// collected data path
	string dyna_mat_path = "dyna/";
	string dyna_mat_name = "dyna_mat";
	string dyna_mat_suffix = ".png";

	string ipro_mat_path = "ipro/";
	string ipro_mat_name = "ipro_mat";
	string ipro_mat_suffix = ".xml";

	// output result path
	string depth_mat_path = "result/depth_mat/";
	string depth_mat_name = "depth_mat";
	string depth_mat_suffix = ".txt";

	string ipro_output_path = "result/ipro_mat/";
	string ipro_output_name = "ipro_mat";
	string ipro_output_suffix = ".txt";

	string point_cloud_path = "result/point_cloud/";
	string point_cloud_name = "pc";
	string point_cloud_suffix = ".txt";

	string point_show_path = "result/show/";
	string point_show_name = "show";
	string point_show_suffix = ".png";

	string trace_path = "result/trace/";
	string trace_name = "trace";
	string trace_suffix = ".txt";


	/// write xml file
	FileStorage fs;
	bool flag = fs.open(xml_file_path + xml_file_name, FileStorage::WRITE);
	if (!flag)
	{
		printf("Error in open xml: %s\n", xml_file_path + xml_file_name);
		system("PAUSE");
		return 0;
	}
	fs << "main_path_win" << main_path_win;
	fs << "main_path_linux" << main_path_linux;
	fs << "data_set_path" << data_set_path;

	fs << "dyna_mat_path" << dyna_mat_path;
	fs << "dyna_mat_name" << dyna_mat_name;
	fs << "dyna_mat_suffix" << dyna_mat_suffix;

	fs << "ipro_mat_path" << ipro_mat_path;
	fs << "ipro_mat_name" << ipro_mat_name;
	fs << "ipro_mat_suffix" << ipro_mat_suffix;

	fs << "depth_mat_path" << depth_mat_path;
	fs << "depth_mat_name" << depth_mat_name;
	fs << "depth_mat_suffix" << depth_mat_suffix;

	fs << "ipro_output_path" << ipro_output_path;
	fs << "ipro_output_name" << ipro_output_name;
	fs << "ipro_output_suffix" << ipro_output_suffix;

	fs << "point_cloud_path" << point_cloud_path;
	fs << "point_cloud_name" << point_cloud_name;
	fs << "point_cloud_suffix" << point_cloud_suffix;

	fs << "point_show_path" << point_show_path;
	fs << "point_show_name" << point_show_name;
	fs << "point_show_suffix" << point_show_suffix;

	fs << "trace_path" << trace_path;
	fs << "trace_name" << trace_name;
	fs << "trace_suffix" << trace_suffix;
	printf("Finished.\n");
	fs.release();


	system("PAUSE");
	return 0;
}