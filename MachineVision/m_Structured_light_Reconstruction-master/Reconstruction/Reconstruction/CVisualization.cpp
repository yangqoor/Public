#include "CVisualization.h"

CVisualization::CVisualization(string winName)
{
	this->m_winName = winName;
	namedWindow(this->m_winName);
}

CVisualization::~CVisualization()
{
	destroyWindow(this->m_winName);
}


int CVisualization::ShowPeriod(Mat pic, int time, double zoom, bool save, string savePath)
{
	Mat pic_resize;
	Size show_size = Size(pic.size().width*zoom, pic.size().height*zoom);
	resize(pic, pic_resize, show_size);
	Mat pic_show;
	pic_show.create(show_size, CV_8UC1);

	for (int h = 0; h < show_size.height; h++)
	{
		for (int w = 0; w < show_size.width; w++)
		{
			uchar value = 0;
			double pic_value = pic_resize.at<double>(h, w);

			if (pic_value < 0)
			{
				value = 0;
			}
			else
			{
				value = ((int)pic_value % 32) * 4 + 128;
			}
			pic_show.at<uchar>(h, w) = value;
		}
	}

	if (save)
	{
		imwrite(savePath, pic_show);
	}

	imshow(this->m_winName, pic_show);
	int key = waitKey(time);
	return key;
}


int CVisualization::Show(Mat pic, int time, bool norm, double zoom, bool save, string savePath)
{
	Mat show;
	Size showSize = Size(pic.size().width*zoom, pic.size().height*zoom);
	resize(pic, show, showSize);
	Mat present;
	
	// 需要标准归一化的情况
	if (norm)
	{
		// 确定Mat类别
		int range = 0;
		
		if (show.depth() == CV_8U)
		{
			range = 0xff;
		}
		else if (show.depth() == CV_16U)
		{
			range = 0xffff;
		}
		else if (show.depth() == CV_32F)
		{
			range = 0xffff;
		}
		else if (show.depth() == CV_64F)
		{
			range = 0xffff;
		}

		// 找最大最小值
		double min, max;
		min = range;
		max = 0;
		for (int i = 0; i < show.size().height; i++)
		{
			for (int j = 0; j < show.size().width; j++)
			{
				int value = 0;
				if (show.depth() == CV_8U)
				{
					value = show.at<uchar>(i, j);
				}
				else if (show.depth() == CV_16U)
				{
					value = show.at<ushort>(i, j);
				}
				else if (show.depth() == CV_32F)
				{
					value = show.at<float>(i, j);
				}
				else if (show.depth() == CV_64F)
				{
					value = show.at<double>(i, j);
				}
				if (value < 0)
				{
					continue;
				}
				if ((double)value < min)
					min = (double)value;
				if ((double)value > max)
					max = (double)value;
			}
		}
		//printf("Max:%f, Min:%f", max, min);
		// 归一
		present.create(show.size(), CV_8UC1);
		present.setTo(0);
		for (int i = 0; i < show.size().height; i++)
		{
			for (int j = 0; j < show.size().width; j++)
			{
				if (show.depth() == CV_8U)
				{
					present.at<uchar>(i, j) = (show.at<uchar>(i, j) - min) / (max - min) * 0xff;
				}
				else if (show.depth() == CV_16U)
				{
					present.at<uchar>(i, j) = (show.at<ushort>(i, j) - min) / (max - min) * 0xff;
				}
				else if (show.depth() == CV_32F)
				{
					present.at<uchar>(i, j) = (show.at<float>(i, j) - min) / (max - min) * 0xff;
				}
				else if (show.depth() == CV_64F)
				{
					double showvalue = show.at<double>(i, j);
					if (showvalue < 0)
					{
						continue;
					}
					double value = 0xff * (show.at<double>(i, j) - min) / (max - min);
					if (value > 255.0)
					{
						value = 255;
					}
					present.at<uchar>(i, j) = (uchar)value;
				}
			}
		}
	}
	else
	{
		present = show;
	}

	if (save)
	{
		imwrite(savePath, present);
	}

	imshow(this->m_winName, present);
	return waitKey(time);
}