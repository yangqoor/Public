#include<iostream>    
#include <opencv2/opencv.hpp>    
#include<opencv2/core/core.hpp>      
#include<opencv2/highgui/highgui.hpp>   

using namespace std;
using namespace cv;

class VideoProcessor {

private:
	//Opencv视频捕捉对象  
	VideoCapture capture;
	//每帧调用的回调函数  
	void(*process)(Mat&, Mat&);
	//确定是否调用回调函数的bool变量  
	bool callIt;
	//输入窗口的名称  
	string windowNameInput;
	string windowNameOutput;
	//延迟  
	int delay;
	//已处理的帧数  
	long fnumber;
	//在该帧数停止  
	long frameToStop;
	//是否停止处理  
	bool stop;
public:
	VideoProcessor() :callIt(true), delay(0), fnumber(0), stop(false), frameToStop(-1) {};

	//设置回调函数  
	void setFrameProcessor(
		void(*frameProcessingCallback)(Mat&, Mat&)) {
		process = frameProcessingCallback;
	}

	//设置视频文件的名称  
	bool setInput(string filename) {
		fnumber = 0;
		//释放之前打开过的资源  
		capture.release();
		//打开视频文件  
		return capture.open(filename);
	}

	//创建输入窗口  
	void displayInput(string wn) {
		windowNameInput = wn;
		namedWindow(windowNameInput);
	}

	//创建输出窗口  
	void displayOutput(string wn) {
		windowNameOutput = wn;
		namedWindow(windowNameOutput);
	}

	//不再显示处理后的帧  
	void dontDisplay() {
		destroyWindow(windowNameInput);
		destroyWindow(windowNameOutput);
		windowNameInput.clear();
		windowNameOutput.clear();
	}

	//获取并处理序列帧  
	void run() {
		//当前帧  
		Mat frame;
		//输出帧  
		Mat output;

		//打开失败时  
		if (!isOpened())return;
		stop = false;
		while (!isStopped())
		{
			//读取下一帧  
			if (!readNextFrame(frame))break;
			//显示输出帧  
			if (windowNameInput.length() != 0)
				imshow(windowNameInput, frame);
			//调用处理函数  
			if (callIt) {
				//处理当前帧  
				process(frame, output);
				//增加帧数  
				fnumber++;
			}
			else
			{
				output = frame;
			}

			//显示输出帧  
			if (windowNameOutput.length() != 0)
				imshow(windowNameOutput, output);
			//引入延迟  
			if (delay >= 0 && waitKey(delay) >= 0)
				stopIt();
			//检查是否需要停止运行  
			if (frameToStop >= 0 && getFrameNumber() == frameToStop)
				stopIt();
		}

	}

	//停止运行  
	void stopIt() {
		stop = true;
	}

	//是否已停止  
	bool isStopped() {
		return stop;
	}

	//是否开始了捕获设备  
	bool isOpened() {
		return capture.isOpened();
	}

	//设置帧间的延迟 0意味着在每帧都等待用户按键 负数意味着没有延迟  
	void setDelay(int d) {
		delay = d;
	}

	//得到下一帧 可能是视频文件或摄像头  
	bool readNextFrame(Mat &frame) {
		return capture.read(frame);
	}

	//需要调用回调函数  
	void callProcess() {
		callIt = true;
	}

	//不需要调用回调函数  
	void dontCallProcess() {
		callIt = false;
	}

	void stopAtFrameNo(long frame) {
		frameToStop = frame;
	}

	//返回下一帧的帧数  
	long getFrameNumber() {
		//得到捕获设备的信息  
		long fnumber = static_cast<long>(capture.get(CV_CAP_PROP_POS_FRAMES));
		return fnumber;
	}

	int getFrameRate() {
		return capture.get(CV_CAP_PROP_FPS);
	}
};

void canny(Mat &img, Mat &out) {

	////灰度转换  
	if (img.channels() == 3)
	{
		cvtColor(img, out, CV_BGR2GRAY);
	}
	//计算Canny边缘  
	Canny(out, out, 100, 200);
	//反转图像  
	threshold(out, out, 128, 255, THRESH_BINARY_INV);
}

int main() {

	//创建实例  
	VideoProcessor processor;
	//打开视频文件  
	processor.setInput("F:\\fs laser\\plasma_wave.avi");
	//声明显示窗口  
	processor.displayInput("Current Frame");
	processor.displayOutput("Output Frame");
	//以原始帧率播放视频  
	processor.setDelay(1000. / processor.getFrameRate());
	//设置处理回调函数  
	processor.setFrameProcessor(canny);
	//开始处理过程  
	processor.run();

	waitKey();
	return 0;
}