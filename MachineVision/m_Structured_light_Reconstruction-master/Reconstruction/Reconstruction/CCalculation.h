#ifndef _CCALCULATION_H_
#define _CCALCULATION_H_

#include <fstream>
#include <queue>
#include "CSensorV.h"
#include "CVisualization.h"

using namespace std;

class CCalculation
{
private:
	// 传感器控制类
	CSensor * m_sensor;

	// 视口大小
	int m_hBegin;
	int m_hEnd;
	int m_wBegin;
	int m_wEnd;

	// 解码出的i,j
	Mat * m_iPro;
	Mat * m_jPro;

	// 计算出来的极线
	Mat * m_lineA;
	Mat * m_lineB;
	Mat * m_lineC;

	// for (h_key, w_key) in key frame:
	//	h_now = trace_h_.at(h_key, w_key)
	Mat * trace_h_;	
	Mat * trace_w_;	
	Mat * delta_trace_h_;
	Mat * delta_trace_w_;

	// Holes Mark
	Mat * holes_mark_;

	// 每帧的点云信息
	Mat * m_xMat;
	Mat * m_yMat;
	Mat * m_zMat;

	// 标定的矩阵
	string inner_para_path_;
	string inner_para_name_;
	string inner_para_suffix_;
	Mat m_camMatrix;
	Mat m_proMatrix;
	Mat m_R;
	Mat m_T;
	Mat m_C;
	Mat m_P;
	double m_cA;
	double m_cB;
	Mat m_cC;
	Mat m_cD;

	//parameers of input data
	string ipro_mat_path_;
	string ipro_mat_name_;
	string ipro_mat_suffix_;

	// parameters of output result
	string depth_mat_path_;
	string depth_mat_name_;
	string depth_mat_suffix_;
	string ipro_output_path_;
	string ipro_output_name_;
	string ipro_output_suffix_;
	string point_cloud_path_;
	string point_cloud_name_;
	string point_cloud_suffix_;
	string point_show_path_;
	string point_show_name_;
	string point_show_suffix_;
	string trace_path_;
	string trace_name_;
	string trace_suffix_;

	// 用于FloodFill的全局临时矩阵
	Mat m_tempMat;

	// 常用功能的小函数
	bool ReleaseSpace();				// 释放空间
	//int FloodFill(int h, int w, uchar from, uchar to);	// 填充函数
	
	// 首帧P坐标的解码
	bool FillFirstProjectorU();				// 首帧的解码
	bool FilljPro(int frame_num);	// 已有iPro的情况下，填充jPro
	bool CalculateEpipolarLine(int frame_num);
	
	// 填充后续帧中的ProU码
	bool FillOtherProU(int frame_num, int key_frame_num);

	// Convert between ipro_mat & depth_mat
	bool Ipro2Depth(int frame_num);
	bool Depth2Ipro(int frame_num);

	// Check the holes in the image
	bool MarkHoles(int frame_num);

	// Process key frame
	bool ProcessFrame(int frame_num); 
	
	// 根据Z值计算坐标
	bool FillCoordinate(int i);

	// 填充iX和iY，deltaX和deltaY
	bool TrackPoints(int frameNum);

public:
	CCalculation();
	~CCalculation();
	bool Init();				// 初始化
	bool CalculateFirst();		// 计算首帧
	bool CalculateOther();		// 计算动态帧
	bool FillJproGroundTruth();
	bool FillDepthGroundTruth();
	bool Result(std::string fileName, int i, bool view_port_only);	// 记录结果
};


#endif