#include <iostream> //标准输入输出流
#include <pcl/io/pcd_io.h> //PCL的PCD格式文件的输入输出头文件
#include <pcl/point_types.h> //PCL对各种格式的点的支持头文件

int  main(int argc, char** argv)
{
	pcl::PointCloud<pcl::PointXYZ> cloud; // 创建点云（不是指针）

										  //填充点云数据
	cloud.width = 5; //设置点云宽度
	cloud.height = 1; //设置点云高度
	cloud.is_dense = false; //非密集型
	cloud.points.resize(cloud.width * cloud.height); //变形，无序
													 //设置这些点的坐标
	for (size_t i = 0; i < cloud.points.size(); ++i)
	{
		cloud.points[i].x = 1024 * rand() / (RAND_MAX + 1.0f);
		cloud.points[i].y = 1024 * rand() / (RAND_MAX + 1.0f);
		cloud.points[i].z = 1024 * rand() / (RAND_MAX + 1.0f);
	}
	//保存到PCD文件
	pcl::io::savePCDFileASCII("test_pcd.pcd", cloud); //将点云保存到PCD文件中
	std::cerr << "Saved " << cloud.points.size() << " data points to test_pcd.pcd." << std::endl;
	//显示点云数据
	for (size_t i = 0; i < cloud.points.size(); ++i)
		std::cerr << "    " << cloud.points[i].x << " " << cloud.points[i].y << " " << cloud.points[i].z << std::endl;
	system("pause");
	return (0);
}