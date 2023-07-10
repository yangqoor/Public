#include <opencv2/opencv.hpp>
#include "global_fun.h"
#include "static_para.h"
#include "storage_mod.h"
#include "visual_mod.h"
#include <string>
#include <sstream>
#include <fstream>

using namespace std;
using namespace cv;

struct CalibParas {
  Mat line_A;
  Mat line_B;
  Mat cam_0_mat;
  Mat cam_1_mat;
  Mat M;
  Mat D;
};

struct DataSets {
  Mat cam_0;
  Mat cam_1;
  Mat max_0;
  Mat min_0;
  Mat max_1;
  Mat min_1;
};

struct ResultSets {
  Mat mask;
  Mat h_mat;
  Mat w_mat;
  Mat depth;
  Mat error;
};

// Output: float; size: camera size
bool LoadCamSizeMatFromTxt(string txt_path, Mat & output_mat) {
  output_mat.create(kCamHeight, kCamWidth, CV_32FC1);
  fstream file;
  file.open(txt_path, ios::in);
  if (!file) {
    return false;
  }
  for (int h = 0; h < kCamHeight; h++) {
    for (int w = 0; w < kCamWidth; w++) {
      float tmp_val;
      file >> tmp_val;
      output_mat.at<float>(h, w) = tmp_val;
    }
  }
  file.close();
  return true;
}

DataSets LoadStereoCamImage(int idx) {
  DataSets result;
  stringstream ss;
  ss << idx;
  string idx2str;
  ss >> idx2str;
  string main_file_path = "E:/Structured_Light_Data/20171125/StatueMRC_2/";
  string img_file_path = "dyna/";
  string img_file_name = "dyna_mat";
  string img_file_suffix = ".png";
  string cam_0_path =
    main_file_path + "cam_0/" + img_file_path + img_file_name
    + idx2str + img_file_suffix;
  string cam_1_path =
    main_file_path + "cam_1/" + img_file_path + img_file_name
    + idx2str + img_file_suffix;
  result.cam_0 = imread(cam_0_path, CV_LOAD_IMAGE_GRAYSCALE);
  result.max_0.create(kCamHeight, kCamWidth, CV_8UC1);
  result.min_0.create(kCamHeight, kCamWidth, CV_8UC1);
  for (int h = kCamWinRad; h < kCamHeight - kCamWinRad - 1; h++) {
    for (int w = kCamWinRad; w < kCamWidth - kCamWinRad - 1; w++) {
      double min_val, max_val;
      Mat patch = result.cam_0.rowRange(
        h - kCamWinRad, h + kCamWinRad + 1).colRange(
          w - kCamWinRad, w + kCamWinRad + 1);
      minMaxLoc(patch, &min_val, &max_val);
      result.max_0.at<uchar>(h, w) = (uchar)max_val;
      result.min_0.at<uchar>(h, w) = (uchar)min_val;
    }
  }

  result.cam_1 = imread(cam_1_path, CV_LOAD_IMAGE_GRAYSCALE);
  result.max_1.create(kCamHeight, kCamWidth, CV_8UC1);
  result.min_1.create(kCamHeight, kCamWidth, CV_8UC1);
  for (int h = kCamWinRad; h < kCamHeight - kCamWinRad - 1; h++) {
    for (int w = kCamWinRad; w < kCamWidth - kCamWinRad - 1; w++) {
      double min_val, max_val;
      Mat patch = result.cam_1.rowRange(
        h - kCamWinRad, h + kCamWinRad + 1).colRange(
          w - kCamWinRad, w + kCamWinRad + 1);
      minMaxLoc(patch, &min_val, &max_val);
      result.max_1.at<uchar>(h, w) = (uchar)max_val;
      result.min_1.at<uchar>(h, w) = (uchar)min_val;
    }
  }
  return result;
}

bool SetParaSet(CalibParas & calib) {
  calib.M.create(kCamHeight*kCamWidth, 3, CV_64FC1);
  calib.D.create(kCamHeight*kCamWidth, 3, CV_64FC1);
  double dx = calib.cam_0_mat.at<double>(0, 2);
  double fx = calib.cam_0_mat.at<double>(0, 0);
  double dy = calib.cam_0_mat.at<double>(1, 2);
  double fy = calib.cam_0_mat.at<double>(1, 1);
  for (int h = 0; h < kCamHeight; h++) {
    for (int w = 0; w < kCamWidth; w++) {
      int cvec_idx = h*kCamWidth + w;
      Mat tmp_vec(3, 1, CV_64FC1);
      tmp_vec.at<double>(0, 0) = (w - dx) / fx;
      tmp_vec.at<double>(1, 0) = (h - dy) / fy;
      tmp_vec.at<double>(2, 0) = 1.0;
      Mat tmp_M = (calib.cam_1_mat.colRange(0, 3)*tmp_vec).t();
      Mat tmp_D = calib.cam_1_mat.colRange(3, 4).t();
      tmp_M.copyTo(calib.M.rowRange(cvec_idx, cvec_idx + 1));
      tmp_D.copyTo(calib.D.rowRange(cvec_idx, cvec_idx + 1));
    }
  }
  return true;
}

CalibParas SetCalibParas() {
  CalibParas result;
  // Load lineA, lineB from data
  Mat line_A, line_B;
  string line_A_path = "EpiLine_A.txt";
  string line_B_path = "EpiLine_B.txt";
  bool status = true;
  status = LoadCamSizeMatFromTxt(line_A_path, result.line_A);
  status = LoadCamSizeMatFromTxt(line_B_path, result.line_B);
  // Set: CalibMat
  double calib_mat_cam0d[3][3] = {
    { 2432.058972474525, 0, 762.2933947666461 },
    { 0, 2435.900798664577, 353.2790048217345 },
    { 0, 0, 1 } };
  double calib_mat_cam1d[3][3] = {
    { 2428.270501026523, 0, 717.1879617522386 },
    { 0, 2425.524847530806, 419.6450731465209 },
    { 0, 0, 1 } };
  double calib_mat_rotd[3][3] = {
    { 0.9991682873520409, 0.01604901003987891, 0.03748550155365887 },
    { -0.01624095229582852, 0.9998564818205395, 0.004821538134006965 },
    { -0.0374027407887994, -0.00542632824227644, 0.9992855397449185 } };
  double calib_mat_transd[3][1] = {
    { -4.672867184359712 },
    { 0.08985783911144951 },
    { -1.53686618071908 } };
  Mat calib_mat_cam_0(3, 3, CV_64FC1, calib_mat_cam0d);
  Mat calib_mat_cam_1(3, 3, CV_64FC1, calib_mat_cam1d);
  Mat calib_mat_rot(3, 3, CV_64FC1, calib_mat_rotd);
  Mat calib_mat_trans(3, 1, CV_64FC1, calib_mat_transd);
  result.cam_0_mat.create(3, 4, CV_64FC1);
  result.cam_0_mat.setTo(0);
  calib_mat_cam_0.copyTo(result.cam_0_mat.colRange(0, 3));
  Mat tmp;
  tmp.create(3, 4, CV_64FC1);
  calib_mat_rot.copyTo(tmp.colRange(0, 3));
  calib_mat_trans.copyTo(tmp.colRange(3, 4));
  result.cam_1_mat = calib_mat_cam_1 * tmp;
  // Set M,D
  SetParaSet(result);

  return result;
}

float CalculateError(Mat patch0, Mat patch1, float max_0, 
                     float min_0, float max_1, float min_1) {
  Size patch_size = patch0.size();
  float sum_val = 0;
  for (int h = 0; h < patch_size.height; h++) {
    for (int w = 0; w < patch_size.width; w++) {
      float patch0_val = (float)patch0.at<uchar>(h, w);
      float patch1_val = (float)patch1.at<uchar>(h, w);
      float norm0 = (patch0_val - min_0) / (max_0 - min_0);
      float norm1 = (patch1_val - min_1) / (max_1 - min_1);
      // sum_val += (patch0_val - patch1_val) * (patch0_val - patch1_val);
      sum_val += (norm0 - norm1) * (norm0 - norm1);
    }
  }
  return sum_val;
}

ResultSets MatchImagePair(CalibParas calib, DataSets img) {
  ResultSets result;
  result.mask.create(kCamHeight, kCamWidth, CV_32FC1);
  result.h_mat.create(kCamHeight, kCamWidth, CV_32FC1);
  result.w_mat.create(kCamHeight, kCamWidth, CV_32FC1);
  result.error.create(kCamHeight, kCamWidth, CV_32FC1);
  result.depth.create(kCamHeight, kCamWidth, CV_32FC1);
  result.mask.setTo(0);
  result.depth.setTo(0);
  for (int h_0 = 0; h_0 < kCamWinRad; h_0++) {
    printf(".");
  }
  for (int h_0 = kCamWinRad; h_0 < kCamHeight - kCamWinRad - 1; h_0++) {
    for (int w_0 = kCamWinRad; w_0 < kCamWidth - kCamWinRad - 1; w_0++) {
      float A = calib.line_A.at<float>(h_0, w_0);
      float B = calib.line_B.at<float>(h_0, w_0);
      if ((A == 0) && (B == 0)) {
        continue;
      }
      float max_0 = (float)img.max_0.at<uchar>(h_0, w_0);
      float min_0 = (float)img.min_0.at<uchar>(h_0, w_0);
      if (max_0 - min_0 < kLumiThred) {
        continue;
      }
      Mat patch0 = img.cam_0.rowRange(
        h_0 - kCamWinRad, h_0 + kCamWinRad + 1).colRange(
          w_0 - kCamWinRad, w_0 + kCamWinRad + 1);
      int cvec_idx = h_0 * kCamWidth + w_0;
      float min_val = 999999999;
      int min_h_idx = -1;
      int min_w_idx = -1;
      float min_depth = 0;
      double M1 = calib.M.at<double>(cvec_idx, 0);
      double M3 = calib.M.at<double>(cvec_idx, 2);
      double D1 = calib.D.at<double>(cvec_idx, 0);
      double D3 = calib.D.at<double>(cvec_idx, 2);
      for (int w_1 = kCamWinRad; w_1 < kCamWidth - kCamWinRad - 1; w_1++) {
        float tmp_depth = -(D1 - D3*w_1) / (M1 - M3*w_1);
        int h_center = (int)round(-A / B * w_1 + 1 / B);
        for (int h_1 = h_center - 2; h_1 <= h_center + 2; h_1++) {
          if ((h_1 < kCamWinRad) || (h_1 > kCamHeight - kCamWinRad - 1)) {
            continue;
          }
          float max_1 = (float)img.max_1.at<uchar>(h_1, w_1);
          float min_1 = (float)img.min_1.at<uchar>(h_1, w_1);
          
          Mat patch1 = img.cam_1.rowRange(
            h_1 - kCamWinRad, h_1 + kCamWinRad + 1).colRange(
              w_1 - kCamWinRad, w_1 + kCamWinRad + 1);
          if (max_1 - min_1 < kLumiThred) {
            continue;
          }
          float tmp_error = CalculateError(patch0, patch1, max_0, min_0,
                                           max_1, min_1);
          if (tmp_error < min_val) {
            min_val = tmp_error;
            min_h_idx = h_1;
            min_w_idx = w_1;
            min_depth = tmp_depth;
          }
        }
      }
      if (min_val < 999999999) {
        result.mask.at<float>(h_0, w_0) = 1;
        result.depth.at<float>(h_0, w_0) = min_depth;
        result.h_mat.at<float>(h_0, w_0) = min_h_idx;
        result.w_mat.at<float>(h_0, w_0) = min_w_idx;
        result.error.at<float>(h_0, w_0) = min_val;
      }
    }
    printf(".");
    if (h_0 % 64 == 63) {
      printf("\n");
    }
  }
  for (int h_0 = 0; h_0 < kCamWinRad; h_0++) {
    printf(".");
  }
  printf("\n");
  return result;
}

void StoreResult(ResultSets result, int idx) {
  StorageModule store;
  store.SetMatFileName("result/", "depth_mat", ".txt");
  store.StoreAsText(&result.depth, 1, idx);
  store.SetMatFileName("result/", "h_mat", ".txt");
  store.StoreAsText(&result.h_mat, 1, idx);
  store.SetMatFileName("result/", "w_mat", ".txt");
  store.StoreAsText(&result.w_mat, 1, idx);
  store.SetMatFileName("result/", "error_mat", ".txt");
  store.StoreAsText(&result.error, 1, idx);
  store.SetMatFileName("result/", "mask", ".txt");
  store.StoreAsText(&result.mask, 1, idx);
  return;
}

int main() {
  bool status = true;
  double lumi_thred = 40;
  double error_thred = 999999999;
  const int kTotalFrame = 40;

  long start_time = clock();
  CalibParas calib_para;
  calib_para = SetCalibParas();
  DataSets data_sets[kTotalFrame];
  ResultSets result_sets[kTotalFrame];
  long calib_time = clock();
  printf("Calib finished. Time used: %.2f s\n", (float)(calib_time - start_time) / 1000);

  for (int frm_idx = 27; frm_idx < kTotalFrame; frm_idx++) {
    long frame_start = clock();
    // Load
    data_sets[frm_idx] = LoadStereoCamImage(frm_idx);
    long load_time = clock();
    printf("[%d]Load finished. Time used: %.2f s\n", 
           frm_idx, (float)(load_time - frame_start) / 1000);
    //VisualModule test("TEST");
    //test.Show(data_sets[frm_idx].cam_0, 0, false, 1.0);
    //test.Show(data_sets[frm_idx].cam_1, 0, false, 1.0);
    // Match
    result_sets[frm_idx] = MatchImagePair(calib_para, data_sets[frm_idx]);
    long match_time = clock();
    printf("[%d]Match finished. Time used: %.2f s\n",
           frm_idx, (float)(match_time - load_time) / 1000);
    // Output
    StoreResult(result_sets[frm_idx], frm_idx);
  }

  system("PAUSE");
  return 0;
}