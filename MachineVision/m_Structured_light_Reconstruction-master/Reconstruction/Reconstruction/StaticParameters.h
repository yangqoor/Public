#ifndef _STATICPARAMETERS_H_
#define _STATICPARAMETERS_H_

// Platform
#ifdef _WIN64
#include <io.h>
#define MY_ACCESS _access
#include <direct.h>
#define MY_MKDIR(a) _mkdir((a))
#define MY_PLATFORM_FLAG WINDOWS
#else
#include <unistd.h>
#include <stdarg.h>
#define MY_ACCESS access
#include <sys/stat.h>
#define MY_MKDIR(a) mkdir((a), 0755)
#define MY_PLATFORM_FLAG UBUNTU
#endif

enum PlatformFlag
{
	WINDOWS,
	UBUNTU,
};
extern const PlatformFlag kPlatformFlag;

#include <string>
using namespace std;

// 投影仪的分辨率
extern const int PROJECTOR_RESLINE;
extern const int PROJECTOR_RESROW;

// 相机的分辨率
extern const int CAMERA_RESLINE;
extern const int CAMERA_RESROW;

// 计算机偏移量
extern const int PC_BIASLINE;
extern const int PC_BIASROW;

// 格雷码和PhaseShifting的数目
extern const int GRAY_V_NUMDIGIT;
extern const int GRAY_H_NUMDIGIT;
extern const int PHASE_NUMDIGIT;

// Visualization 相关参数
extern const int SHOW_PICTURE_TIME;
extern const bool VISUAL_DEBUG;

//// 棋盘格相关参数
//extern const int CHESS_FRAME_NUMBER;
//extern const int CHESS_LINE;
//extern const int CHESS_ROW;

// 数据读取相关
extern const string CONFIG_PATHNAME;
extern const int DYNAFRAME_MAXNUM;

// 数据输出相关
extern const int FOV_MIN_DISTANCE;
extern const int FOV_MAX_DISTANCE;

// 计算相关
extern const int SEARCH_WINDOW_SIZE;
extern const int MATCH_WINDOW_SIZE;

#endif