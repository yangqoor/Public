#include "static_para.h"

// 投影仪的分辨率
const int kProWidth = 1280;
const int kProHeight = 800;

// 相机的分辨率
const int kCamWidth = 1280;
const int kCamHeight = 1024;
const int kCamWinRad = 7;
const int kLumiThred = 30;

// 计算机偏移量
const int kScreenBiasHeight = 0;
const int kScreenBiasWidth = 1920;

// 格雷码和PhaseShifting的数目
const int kVerGrayNum = 6;
const int kHorGrayNum = 5;
const int kPhaseNum = 4;

// Visualization 相关参数
const int kShowPictureTime = 500;
const bool kVisualFlagForDebug = false;

//// 棋盘格相关参数
const int kChessFrameNumber = 15;
const int kChessWidth = 8;
const int kChessHeight = 6;
const int kStereoSize = kCamDeviceNum + kCamDeviceNum*(kCamDeviceNum - 1) / 2;

// 数据采集相关参数

const string kProPatternPath = "Patterns/";
const string kProVerGrayName = "vGray";
const string kProVerGrayCodeName = "vGrayCode";
const string kProVerGrayCodeSuffix = ".txt";
const string kProVerPhaseName = "vPhase";
const string kProDynaName = "dynaMat";
const string kProWaitName = "wait";
const string kProFileSuffix = ".bmp";
const int kCamDeviceNum = 2;

// Used for mats storage
CamMatSet::CamMatSet() {
  this->ver_gray = NULL;
  this->hor_gray = NULL;
  this->ver_phase = NULL;
  this->hor_phase = NULL;
  this->dyna = NULL;
  this->x_pro = NULL;
  this->y_pro = NULL;
}

CamMatSet::~CamMatSet() {
  if (this->ver_gray != NULL) {
    delete[] this->ver_gray;
    this->ver_gray = NULL;
  }
  if (this->hor_gray != NULL) {
    delete[] this->hor_gray;
    this->hor_gray = NULL;
  }
  if (this->ver_phase != NULL) {
    delete[] this->ver_phase;
    this->ver_phase = NULL;
  }
  if (this->hor_phase != NULL) {
    delete[] this->hor_phase;
    this->hor_phase = NULL;
  }
  if (this->dyna != NULL) {
    delete[] this->dyna;
    this->dyna = NULL;
  }
  if (this->x_pro != NULL) {
    delete[] this->x_pro;
    this->x_pro = NULL;
  }
  if (this->y_pro != NULL) {
    delete[] this->y_pro;
    this->y_pro = NULL;
  }
}