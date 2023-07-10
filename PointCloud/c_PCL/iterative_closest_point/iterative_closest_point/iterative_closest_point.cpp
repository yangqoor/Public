#include <iostream> //标准输入/输出
#include <pcl/io/pcd_io.h> //pcd文件输入/输出
#include <pcl/point_types.h> //各种点类型
#include <pcl/registration/icp.h> //ICP(iterative closest point)配准

int main(int argc, char** argv)
{
	//创建点云指针
	pcl::PointCloud<pcl::PointXYZ>::Ptr cloud_in(new pcl::PointCloud<pcl::PointXYZ>); //创建输入点云（指针）
	pcl::PointCloud<pcl::PointXYZ>::Ptr cloud_out(new pcl::PointCloud<pcl::PointXYZ>); //创建输出/目标点云（指针）

																					   //生成并填充点云cloud_in
	cloud_in->width = 5;
	cloud_in->height = 1;
	cloud_in->is_dense = false;
	cloud_in->points.resize(cloud_in->width * cloud_in->height); //变形，无序
	for (size_t i = 0; i < cloud_in->points.size(); ++i) //随机数初始化点的坐标
	{
		cloud_in->points[i].x = 1024 * rand() / (RAND_MAX + 1.0f);
		cloud_in->points[i].y = 1024 * rand() / (RAND_MAX + 1.0f);
		cloud_in->points[i].z = 1024 * rand() / (RAND_MAX + 1.0f);
	}
	std::cout << "Saved " << cloud_in->points.size() << " data points to input:"
		<< std::endl;
	//打印点云cloud_in中所有点的坐标信息
	for (size_t i = 0; i < cloud_in->points.size(); ++i) std::cout << "    " <<
		cloud_in->points[i].x << " " << cloud_in->points[i].y << " " <<
		cloud_in->points[i].z << std::endl;

	// 填充点云cloud_out
	*cloud_out = *cloud_in; //初始化cloud_out
	std::cout << "size:" << cloud_out->points.size() << std::endl;
	for (size_t i = 0; i < cloud_in->points.size(); ++i)
		cloud_out->points[i].x = cloud_in->points[i].x + 0.7f; //平移cloud_in得到cloud_out
	std::cout << "Transformed " << cloud_in->points.size() << " data points:"
		<< std::endl;
	//打印点云cloud_out中所有点的坐标信息（每一行对应一个点的xyz坐标）
	for (size_t i = 0; i < cloud_out->points.size(); ++i)
		std::cout << "    " << cloud_out->points[i].x << " " <<
		cloud_out->points[i].y << " " << cloud_out->points[i].z << std::endl;
	//*********************************
	// ICP配准
	//*********************************
	pcl::IterativeClosestPoint<pcl::PointXYZ, pcl::PointXYZ> icp; //创建ICP对象，用于ICP配准
	icp.setInputCloud(cloud_in); //设置输入点云
	icp.setInputTarget(cloud_out); //设置目标点云（输入点云进行仿射变换，得到目标点云）
	pcl::PointCloud<pcl::PointXYZ> Final; //存储结果
										  //进行配准，结果存储在Final中
	icp.align(Final);
	//输出ICP配准的信息（是否收敛，拟合度）
	std::cout << "has converged:" << icp.hasConverged() << " score: " <<
		icp.getFitnessScore() << std::endl;
	//输出最终的变换矩阵（4x4）
	std::cout << icp.getFinalTransformation() << std::endl;

	return (0);
}