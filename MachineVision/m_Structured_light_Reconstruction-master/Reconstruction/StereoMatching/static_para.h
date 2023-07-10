#ifndef _STATICPARA_H_
#define _STATICPARA_H_

#include <string>
#include <opencv2/opencv.hpp>
using namespace std;
using namespace cv;

// resolution of projector
extern const int kProWidth;
extern const int kProHeight;

// resolution of camera
extern const int kCamWidth;
extern const int kCamHeight;
extern const int kCamWinRad;
extern const int kLumiThred;

// bias resolution of computer screen
extern const int kScreenBiasHeight;
extern const int kScreenBiasWidth;

// 格雷码和PhaseShifting的数目
extern const int kVerGrayNum;
extern const int kHorGrayNum;
extern const int kPhaseNum;

// Visualization parameters
extern const int kShowPictureTime;
extern const bool kVisualFlagForDebug;

// Chess board parameters
extern const int kChessFrameNumber;
extern const int kChessWidth;
extern const int kChessHeight;
extern const int kStereoSize;
struct StereoCalibSet {
  Mat R;
  Mat T;
  Mat E;
  Mat F;
};

// data pathes
extern const string kProPatternPath;
extern const string kProVerGrayName;
extern const string kProVerGrayCodeName;
extern const string kProVerGrayCodeSuffix;
extern const string kProVerPhaseName;
extern const string kProDynaName;
extern const string kProWaitName;
extern const string kProFileSuffix;
extern const int kCamDeviceNum;

// Used for mats storage
struct CamMatSet {
  Mat * ver_gray;
  Mat * hor_gray;
  Mat * ver_phase;
  Mat * hor_phase;
  Mat * dyna;
  Mat * x_pro;
  Mat * y_pro;
  CamMatSet();
  ~CamMatSet();
};

#endif