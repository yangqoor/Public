#ifndef _STORAGEMOD_H_
#define _STORAGEMOD_H_

#include <iostream>
#include <string>
#include <strstream>
#include <fstream>
#include <opencv2\opencv.hpp>
#include "global_fun.h"
using namespace std;
using namespace cv;

// 数据存储模块。存储中间数据做存档
class StorageModule {
private:
	string file_path_;
	string file_name_;
	string file_suffix_;
	string final_path_;		// 用于存储的最终路径。debug用。
public:
	StorageModule();
	~StorageModule();
	bool StoreAsImage(Mat *pictures, int num, int sta_idx = 0);		// Store mat as image type
  bool StoreAsText(Mat *text_mat, int num, int sta_idx = 0);     // Store mat as text type
  bool StoreAsXml(Mat *test_mat, int num, int sta_idx = 0);      // Store mat as xml

	bool SetMatFileName(string file_path, string file_name, string file_suffix);
	bool CreateFolder(string FilePath);
};

#endif