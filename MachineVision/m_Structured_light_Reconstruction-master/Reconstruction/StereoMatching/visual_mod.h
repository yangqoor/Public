#ifndef _VISUALMOD_H_
#define _VISUALMOD_H_

#include <string>
#include <opencv2/opencv.hpp>

using namespace std;
using namespace cv;

// visualization module. Create and Destroy Windows Antomatically.
class VisualModule {
private:
	string win_name_;		// name of created window

public:
	VisualModule(string win_name);
	~VisualModule();
	int Show(Mat pic, int time, bool norm = false, double zoom = 1.0);
  int CombineShow(Mat * pics, int num, int time, double zoom = 1.0);
};

#endif