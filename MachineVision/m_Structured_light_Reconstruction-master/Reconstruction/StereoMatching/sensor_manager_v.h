#ifndef _SENSORMANAGERV_H_
#define _SENSORMANAGERV_H_

#include <string>
#include <opencv2/opencv.hpp>
#include <strstream>
#include "static_para.h"
#include "global_fun.h"

using namespace std;
using namespace cv;

// Sensor module
// usage: init, load/unload, close
class SensorManagerV {
private:
	int data_num_;
	int now_num_;
	string file_path_;
	string file_name_;
	string file_suffix_;
	Mat * data_mats_;

  // Read patterns
  bool LoadPatterns(int pattern_num, string file_path,
    string file_name, string file_suffix);

  // Release patterns
  bool UnloadPatterns();

  // Set project patterns, count from 0
  bool SetProPicture(int nowNum = 0);

  // Get now projected pattern
  Mat GetProPicture();
public:
	SensorManagerV();
	~SensorManagerV();

	// Initialization
	bool InitSensor();

	// Close sensor.
	bool CloseSensor();

	// Get camera picture according to index
	Mat GetCamPicture(int idx);
};

#endif