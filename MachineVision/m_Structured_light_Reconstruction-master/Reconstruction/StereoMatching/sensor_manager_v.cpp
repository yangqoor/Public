#include "sensor_manager_v.h"


// Sensor module.
// Used for manage camera and projector.
// Project pattern and capture image.
SensorManagerV::SensorManagerV() {
  this->data_num_ = 0;
  this->now_num_ = 0;
  this->file_path_ = "";
  this->file_name_ = "";
  this->file_suffix_ = "";
  this->pattern_mats_ = NULL;
  this->cam_device_ = NULL;
  this->pro_device_ = NULL;
}

SensorManagerV::~SensorManagerV() {
	if (this->pattern_mats_ != NULL) {
		delete[]this->pattern_mats_;
		this->pattern_mats_ = NULL;
	}
	if (this->cam_device_ != NULL) {
		delete this->cam_device_;
		this->cam_device_ = NULL;
	}
	if (this->pro_device_ != NULL) {
		delete this->pro_device_;
		this->pro_device_ = NULL;
	}
}

// Initialize sensor.
// Create camera, projector and initialize them.
bool SensorManagerV::InitSensor() {
	bool status;

  this->cam_device_ = new CamManager();
  status = this->cam_device_->InitCamera();

	this->pro_device_ = new ProManager();
	status = this->pro_device_->InitProjector();

	return status;
}

// Close sensor.
// Release spaces.
bool SensorManagerV::CloseSensor() {
	bool status = true;

	if (this->cam_device_ != NULL) {
		this->cam_device_->CloseCamera();
		delete this->cam_device_;
		this->cam_device_ = NULL;
	}
	if (this->pro_device_ != NULL) {
		delete this->pro_device_;
		this->pro_device_ = NULL;
	}
	this->UnloadPatterns();

	return status;
}

// Read patterns
bool SensorManagerV::LoadPatterns(int pattern_num, string file_path,
                                 string file_name, string file_suffix) {
	// Check status
	if (this->pattern_mats_ != NULL) {
		this->UnloadPatterns();
	}
	// Set input parameters
	this->pattern_num_ = pattern_num;
	this->now_num_ = 0;
	this->file_path_ = file_path;
	this->file_name_ = file_name;
	this->file_suffix_ = file_suffix;
	this->pattern_mats_ = new Mat[this->pattern_num_];
	// Load patterns
	for (int i = 0; i < this->pattern_num_; i++) {
    string idx2Str;
    strstream ss;
    ss << i;
    ss >> idx2Str;
    
    Mat tmp_mat;
    string read_path = this->file_path_ + this->file_name_ + idx2Str + this->file_suffix_;
    tmp_mat = imread(read_path, CV_LOAD_IMAGE_GRAYSCALE);
    tmp_mat.copyTo(this->pattern_mats_[i]);

		if (tmp_mat.empty()) {
			ErrorHandling("SensorManagerV::LoadPatterns::<Read>, imread error, file_path:" + file_name);
		}
	}
	return true;
}

// Release patterns
bool SensorManagerV::UnloadPatterns()
{
	if (this->pattern_mats_ != NULL)
	{
		delete[]this->pattern_mats_;
		this->pattern_mats_ = NULL;
	}
	this->pattern_num_ = 0;
	this->now_num_ = 0;
	this->file_path_ = "";
	this->file_name_ = "";
	this->file_suffix_ = "";

	return true;
}

// Set project patterns, count from 0
bool SensorManagerV::SetProPicture(int nowNum) {
	bool status = true;
	// Check parameters
	if (nowNum >= this->pattern_num_) {
		status = false;
		return status;
	}
	this->now_num_ = nowNum;
	status = this->pro_device_->PresentPicture(
    this->pattern_mats_[this->now_num_], 150);
	return status;
}

// 获取相机图像
Mat SensorManagerV::GetCamPicture(int idx) {
	bool status = true;
	Mat tmpMat;
	status = this->cam_device_->GetPicture(idx, tmpMat);
  Mat output_mat;
  tmpMat.copyTo(output_mat);
	return output_mat;
}

// 获取投影仪投影的图像
Mat SensorManagerV::GetProPicture() {
	return this->pattern_mats_[this->now_num_];
}