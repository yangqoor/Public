#ifndef _GLOBAL_FUNCTION_
#define _GLOBAL_FUNCTION_

#include "StaticParameters.h"
#include <iostream>
#include <string>
#include <fstream>
#include <opencv2/opencv.hpp>
using namespace std;
using namespace cv;

// ´íÎó´¦Àíº¯Êý
int ErrorHandling(string message);


int CreateDir(string dir_path);


bool WriteMatData(string path, string name, string idx2str, string suffix, Mat data_mat);

#endif