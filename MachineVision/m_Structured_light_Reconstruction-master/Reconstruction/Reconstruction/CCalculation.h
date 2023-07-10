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
	// ������������
	CSensor * m_sensor;

	// �ӿڴ�С
	int m_hBegin;
	int m_hEnd;
	int m_wBegin;
	int m_wEnd;

	// �������i,j
	Mat * m_iPro;
	Mat * m_jPro;

	// ��������ļ���
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

	// ÿ֡�ĵ�����Ϣ
	Mat * m_xMat;
	Mat * m_yMat;
	Mat * m_zMat;

	// �궨�ľ���
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

	// ����FloodFill��ȫ����ʱ����
	Mat m_tempMat;

	// ���ù��ܵ�С����
	bool ReleaseSpace();				// �ͷſռ�
	//int FloodFill(int h, int w, uchar from, uchar to);	// ��亯��
	
	// ��֡P����Ľ���
	bool FillFirstProjectorU();				// ��֡�Ľ���
	bool FilljPro(int frame_num);	// ����iPro������£����jPro
	bool CalculateEpipolarLine(int frame_num);
	
	// ������֡�е�ProU��
	bool FillOtherProU(int frame_num, int key_frame_num);

	// Convert between ipro_mat & depth_mat
	bool Ipro2Depth(int frame_num);
	bool Depth2Ipro(int frame_num);

	// Check the holes in the image
	bool MarkHoles(int frame_num);

	// Process key frame
	bool ProcessFrame(int frame_num); 
	
	// ����Zֵ��������
	bool FillCoordinate(int i);

	// ���iX��iY��deltaX��deltaY
	bool TrackPoints(int frameNum);

public:
	CCalculation();
	~CCalculation();
	bool Init();				// ��ʼ��
	bool CalculateFirst();		// ������֡
	bool CalculateOther();		// ���㶯̬֡
	bool FillJproGroundTruth();
	bool FillDepthGroundTruth();
	bool Result(std::string fileName, int i, bool view_port_only);	// ��¼���
};


#endif