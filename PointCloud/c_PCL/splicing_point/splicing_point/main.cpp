#include <iostream> //标准输入输出流
#include <pcl/io/pcd_io.h> //PCL的PCD格式文件的输入输出头文件
#include <pcl/point_types.h> //PCL对各种格式的点的支持头文件
//比如，你的程序遇到调用栈用完了的威胁。你说，你到什么地方借内存，
//存放你的错误信息？cerr的目的，就是在你最需要它的紧急情况下，
//还能得到输出功能的支持。 缓冲区的目的，就是减少刷屏的次数

// 程序拼接A和B到C
int main(int argc, char** argv)
{
	if (argc != 2) // 需要一个参数 -f 或 -p
	{
		std::cerr << "please specify command line arg '-f' or '-p'" << std::endl;
		exit(0);
	}
	// 用于拼接不同点云的点的变量
	pcl::PointCloud<pcl::PointXYZ> cloud_a, cloud_b, cloud_c; //创建点云（不是指针），存储点坐标xyz
															  // 用于拼接不同点云的域（点和法向量）的变量
	pcl::PointCloud<pcl::Normal> n_cloud_b; //创建点云，储存法向量
	pcl::PointCloud<pcl::PointNormal> p_n_cloud_c; //创建点云，储存点坐标和法向量

												   //填充点云数据
	cloud_a.width = 5; //设置宽度
	cloud_a.height = cloud_b.height = n_cloud_b.height = 1; //设置高度
	cloud_a.points.resize(cloud_a.width * cloud_a.height); //变形，无序
	if (strcmp(argv[1], "-p") == 0) //根据输入参数，设置点云
	{
		cloud_b.width = 3; //cloud_b用于拼接不同点云的点
		cloud_b.points.resize(cloud_b.width * cloud_b.height);
	}
	else {
		n_cloud_b.width = 5; //n_cloud_b用于拼接不同点云的域
		n_cloud_b.points.resize(n_cloud_b.width * n_cloud_b.height);
	}
	for (size_t i = 0; i < cloud_a.points.size(); ++i) //设置cloud_a中点的坐标（随机数）
	{
		cloud_a.points[i].x = 1024 * rand() / (RAND_MAX + 1.0f);
		cloud_a.points[i].y = 1024 * rand() / (RAND_MAX + 1.0f);
		cloud_a.points[i].z = 1024 * rand() / (RAND_MAX + 1.0f);
	}
	if (strcmp(argv[1], "-p") == 0)
		for (size_t i = 0; i < cloud_b.points.size(); ++i) //设置cloud_b中点的坐标（随机数）
		{
			cloud_b.points[i].x = 1024 * rand() / (RAND_MAX + 1.0f);
			cloud_b.points[i].y = 1024 * rand() / (RAND_MAX + 1.0f);
			cloud_b.points[i].z = 1024 * rand() / (RAND_MAX + 1.0f);
		}
	else // -f
		for (size_t i = 0; i < n_cloud_b.points.size(); ++i) //设置n_cloud_b中点的坐标（随机数）
		{
			n_cloud_b.points[i].normal[0] = 1024 * rand() / (RAND_MAX + 1.0f);
			n_cloud_b.points[i].normal[1] = 1024 * rand() / (RAND_MAX + 1.0f);
			n_cloud_b.points[i].normal[2] = 1024 * rand() / (RAND_MAX + 1.0f);
		}

	// 打印拼接用的数据 A和B
	std::cerr << "Cloud A: " << std::endl;
	for (size_t i = 0; i < cloud_a.points.size(); ++i) //打印cloud_a的点坐标信息
		std::cerr << "    " << cloud_a.points[i].x << " " << cloud_a.points[i].y << " " << cloud_a.points[i].z << std::endl;

	std::cerr << "Cloud B: " << std::endl; //打印Cloud B
	if (strcmp(argv[1], "-p") == 0) //若输入参数是-p，打印cloud_b；
		for (size_t i = 0; i < cloud_b.points.size(); ++i)
			std::cerr << "    " << cloud_b.points[i].x << " " << cloud_b.points[i].y << " " << cloud_b.points[i].z << std::endl;
	else //若-f，打印n_cloud_b
		for (size_t i = 0; i < n_cloud_b.points.size(); ++i)
			std::cerr << "    " << n_cloud_b.points[i].normal[0] << " " << n_cloud_b.points[i].normal[1] << " " << n_cloud_b.points[i].normal[2] << std::endl;

	//复制点云中的点
	if (strcmp(argv[1], "-p") == 0)
	{
		cloud_c = cloud_a;
		cloud_c += cloud_b; // cloud_a + cloud_b 意思是cloud_c包含了a和b中的点，c的点数 = a的点数+b的点数
		std::cerr << "Cloud C: " << std::endl; ////打印Cloud C
		for (size_t i = 0; i < cloud_c.points.size(); ++i) //打印Cloud C
			std::cerr << "    " << cloud_c.points[i].x << " " << cloud_c.points[i].y << " " << cloud_c.points[i].z << " " << std::endl;
	}
	else //若输入参数是-f
	{
		pcl::concatenateFields(cloud_a, n_cloud_b, p_n_cloud_c); //拼接（点）cloud_a和（法向量）n_cloud_b到p_n_cloud_c
		std::cerr << "Cloud C: " << std::endl;
		for (size_t i = 0; i < p_n_cloud_c.points.size(); ++i) //打印Cloud C
			std::cerr << "    " <<
			p_n_cloud_c.points[i].x << " " << p_n_cloud_c.points[i].y << " " << p_n_cloud_c.points[i].z << " " <<
			p_n_cloud_c.points[i].normal[0] << " " << p_n_cloud_c.points[i].normal[1] << " " << p_n_cloud_c.points[i].normal[2] << std::endl;
	}
	
	return (0);
}