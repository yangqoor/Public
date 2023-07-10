#include <iostream> //��׼���������
#include <boost/thread/thread.hpp>
#include <pcl/range_image/range_image.h>
#include <pcl/io/pcd_io.h> //PCL��PCD��ʽ�ļ����������ͷ�ļ�
#include <pcl/visualization/range_image_visualizer.h>
#include <pcl/visualization/pcl_visualizer.h>
#include <pcl/features/range_image_border_extractor.h>
#include <pcl/keypoints/narf_keypoint.h>
#include <pcl/console/parse.h>

typedef pcl::PointXYZ PointType; //�������

								 //���� ȫ�ֱ���
float angular_resolution = 0.5f; //������ֱ���
float support_size = 0.2f; //����Ȥ��ĳߴ磨�����ֱ����
pcl::RangeImage::CoordinateFrame coordinate_frame = pcl::RangeImage::CAMERA_FRAME; //�����ܣ������ܣ������Ǽ����ܣ�
bool setUnseenToMaxRange = false; //�Ƿ����в��ɼ��ĵ� ���� ������


								  //����
								  //���û����������в���-h����ӡ������Ϣ
void printUsage(const char* progName)
{
	std::cout << "\n\nUsage: " << progName << " [options] <scene.pcd>\n\n"
		<< "Options:\n"
		<< "-------------------------------------------\n"
		<< "-r <float>   angular resolution in degrees (default " << angular_resolution << ")\n"
		<< "-c <int>     coordinate frame (default " << (int)coordinate_frame << ")\n"
		<< "-m           Treat all unseen points as maximum range readings\n"
		<< "-s <float>   support size for the interest points (diameter of the used sphere - "
		<< "default " << support_size << ")\n"
		<< "-h           this help\n"
		<< "\n\n";
}


int main(int argc, char** argv)
{

	//���� ������ ����
	if (pcl::console::find_argument(argc, argv, "-h") >= 0)
	{
		printUsage(argv[0]);
		return 0;
	}
	if (pcl::console::find_argument(argc, argv, "-m") >= 0)
	{
		setUnseenToMaxRange = true;
		cout << "Setting unseen values in range image to maximum range readings.\n";
	}
	int tmp_coordinate_frame;
	if (pcl::console::parse(argc, argv, "-c", tmp_coordinate_frame) >= 0)
	{
		coordinate_frame = pcl::RangeImage::CoordinateFrame(tmp_coordinate_frame); //�Ժ����ķ�ʽ��ʼ����0�������ܣ�1�������ܣ�
		cout << "Using coordinate frame " << (int)coordinate_frame << ".\n";
	}
	if (pcl::console::parse(argc, argv, "-s", support_size) >= 0)
		cout << "Setting support size to " << support_size << ".\n";
	if (pcl::console::parse(argc, argv, "-r", angular_resolution) >= 0)
		cout << "Setting angular resolution to " << angular_resolution << "deg.\n";
	angular_resolution = pcl::deg2rad(angular_resolution);

	//��ȡpcd�ļ������û��ָ���ļ����ʹ���������
	pcl::PointCloud<PointType>::Ptr point_cloud_ptr(new pcl::PointCloud<PointType>); //����ָ��
	pcl::PointCloud<PointType>& point_cloud = *point_cloud_ptr; //������Ƶı���
	pcl::PointCloud<pcl::PointWithViewpoint> far_ranges; //���ӽǵĵ㹹�ɵĵ���
	Eigen::Affine3f scene_sensor_pose(Eigen::Affine3f::Identity()); //����任
	std::vector<int> pcd_filename_indices = pcl::console::parse_file_extension_argument(argc, argv, "pcd");//���������Ƿ���pcd��ʽ�ļ��������ز��������е�������
	if (!pcd_filename_indices.empty())//���ָ����pcd�ļ�����ȡpcd�ļ��Ͷ�Ӧ��Զ����pcd�ļ�
	{
		std::string filename = argv[pcd_filename_indices[0]]; //�ļ���
		if (pcl::io::loadPCDFile(filename, point_cloud) == -1) //��ȡpcd�ļ�
		{
			cerr << "Was not able to open file \"" << filename << "\".\n"; //�Ƿ�Ӧ����std::cerr
			printUsage(argv[0]);
			return 0;
		}
		scene_sensor_pose = Eigen::Affine3f(Eigen::Translation3f(point_cloud.sensor_origin_[0],
			point_cloud.sensor_origin_[1],
			point_cloud.sensor_origin_[2])) *
			Eigen::Affine3f(point_cloud.sensor_orientation_); //���ô�����������
		std::string far_ranges_filename = pcl::getFilenameWithoutExtension(filename) + "_far_ranges.pcd"; //Զ�����ļ���
		if (pcl::io::loadPCDFile(far_ranges_filename.c_str(), far_ranges) == -1) //��ȡԶ����pcd�ļ�
			std::cout << "Far ranges file \"" << far_ranges_filename << "\" does not exists.\n";
	}
	else //û��ָ��pcd�ļ������ɵ��ƣ��������
	{
		setUnseenToMaxRange = true;
		cout << "\nNo *.pcd file given => Genarating example point cloud.\n\n";
		for (float x = -0.5f; x <= 0.5f; x += 0.01f)
		{
			for (float y = -0.5f; y <= 0.5f; y += 0.01f)
			{
				PointType point;
				point.x = x;  point.y = y;  point.z = 2.0f - y;
				point_cloud.points.push_back(point); //���õ����е������
			}
		}
		point_cloud.width = (int)point_cloud.points.size();
		point_cloud.height = 1;
	}


	//�ӵ������ݣ��������ͼ��
	float noise_level = 0.0;
	float min_range = 0.0f;
	int border_size = 1;
	boost::shared_ptr<pcl::RangeImage> range_image_ptr(new pcl::RangeImage); //����RangeImage����ָ�룩
	pcl::RangeImage& range_image = *range_image_ptr;  //����
	range_image.createFromPointCloud(point_cloud, angular_resolution, pcl::deg2rad(360.0f), pcl::deg2rad(180.0f),
		scene_sensor_pose, coordinate_frame, noise_level, min_range, border_size); //�ӵ��ƴ������ͼ��
	range_image.integrateFarRanges(far_ranges); //����Զ�������
	if (setUnseenToMaxRange)
		range_image.setUnseenToMaxRange();

	//��3D�۲�ͼ�δ��ڣ�����ӵ���
	pcl::visualization::PCLVisualizer viewer("3D Viewer"); //����3D Viewer����
	viewer.setBackgroundColor(1, 1, 1); //���ñ���ɫ
	pcl::visualization::PointCloudColorHandlerCustom<pcl::PointWithRange> range_image_color_handler(range_image_ptr, 0, 0, 0);
	viewer.addPointCloud(range_image_ptr, range_image_color_handler, "range image"); //��ӵ���
	viewer.setPointCloudRenderingProperties(pcl::visualization::PCL_VISUALIZER_POINT_SIZE, 1, "range image");
	//viewer.addCoordinateSystem (1.0f, "global");
	//PointCloudColorHandlerCustom<PointType> point_cloud_color_handler (point_cloud_ptr, 150, 150, 150);
	//viewer.addPointCloud (point_cloud_ptr, point_cloud_color_handler, "original point cloud");
	viewer.initCameraParameters();
	//setViewerPose (viewer, range_image.getTransformationToWorldSystem ());

	//��ʾ���ͼ��ƽ��ͼ�������3D��ʾ��
	pcl::visualization::RangeImageVisualizer range_image_widget("Range image");
	range_image_widget.showRangeImage(range_image);

	//��ȡNARF�ؼ���
	pcl::RangeImageBorderExtractor range_image_border_extractor; //�������ͼ��ı߽���ȡ����������ȡNARF�ؼ���
	pcl::NarfKeypoint narf_keypoint_detector(&range_image_border_extractor); //����NARF����
	narf_keypoint_detector.setRangeImage(&range_image);
	narf_keypoint_detector.getParameters().support_size = support_size;
	//narf_keypoint_detector.getParameters ().add_points_on_straight_edges = true;
	//narf_keypoint_detector.getParameters ().distance_for_additional_points = 0.5;

	pcl::PointCloud<int> keypoint_indices; //���ڴ洢�ؼ��������
	narf_keypoint_detector.compute(keypoint_indices); //����NARF�ؼ���
	std::cout << "Found " << keypoint_indices.points.size() << " key points.\n";

	//��range_image_widget����ʾ�ؼ���
	//for (size_t i=0; i<keypoint_indices.points.size (); ++i)
	//range_image_widget.markPoint (keypoint_indices.points[i]%range_image.width,
	//keypoint_indices.points[i]/range_image.width);


	//��3Dͼ�δ�������ʾ�ؼ���
	pcl::PointCloud<pcl::PointXYZ>::Ptr keypoints_ptr(new pcl::PointCloud<pcl::PointXYZ>); //�����ؼ���ָ��
	pcl::PointCloud<pcl::PointXYZ>& keypoints = *keypoints_ptr; //����
	keypoints.points.resize(keypoint_indices.points.size()); //���Ʊ��Σ�����
	for (size_t i = 0; i<keypoint_indices.points.size(); ++i)
		keypoints.points[i].getVector3fMap() = range_image.points[keypoint_indices.points[i]].getVector3fMap();

	pcl::visualization::PointCloudColorHandlerCustom<pcl::PointXYZ> keypoints_color_handler(keypoints_ptr, 0, 255, 0);
	viewer.addPointCloud<pcl::PointXYZ>(keypoints_ptr, keypoints_color_handler, "keypoints");
	viewer.setPointCloudRenderingProperties(pcl::visualization::PCL_VISUALIZER_POINT_SIZE, 7, "keypoints");

	// -----Main loop-----
	while (!viewer.wasStopped())
	{
		range_image_widget.spinOnce();  // ���� GUI�¼�
		viewer.spinOnce();
		//pcl_sleep(0.01);
	}
}