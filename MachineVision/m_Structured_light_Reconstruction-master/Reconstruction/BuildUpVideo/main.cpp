#include <opencv2/core/core.hpp>
#include <opencv2/highgui/highgui.hpp>
#include <iostream>
#include <string>
#include <strstream>

using namespace std;
using namespace cv;

int main() {
	// Output video
	string video_file_name = "./video1.avi";

	string file_path = "F:/Github/Structured_light_Reconstruction/Matlab_Debug/CRF/ShowPattern/PatternColorResult/";
	//string file_path = "E:/Structured_Light_Data/20170613/1/dyna/";
	string file_name = "show";
	//string file_name = "4RandDot";
	string file_suffix = ".png";

	int frame_num = 29;

	VideoWriter writer(video_file_name,
		CV_FOURCC('X', 'V', 'I', 'D'), 
		10.0,
		Size(1280, 1024));

	for (int i = 1; i < frame_num; i++) {
		stringstream ss;
		ss << i;
		string idx2str;
		ss >> idx2str;
		Mat tmp = imread(file_path + file_name + idx2str + file_suffix);
		writer << tmp;
	}

	return 0;
}