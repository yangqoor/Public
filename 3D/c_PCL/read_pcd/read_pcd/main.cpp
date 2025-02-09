#include <iostream> //��׼���������
#include <pcl/io/pcd_io.h> //PCL��PCD��ʽ�ļ����������ͷ�ļ�
#include <pcl/point_types.h> //PCL�Ը��ָ�ʽ�ĵ��֧��ͷ�ļ�

int main(int argc, char** argv)
{
	pcl::PointCloud<pcl::PointXYZ>::Ptr cloud(new pcl::PointCloud<pcl::PointXYZ>); // �������ƣ�ָ�룩

	if (pcl::io::loadPCDFile<pcl::PointXYZ>("my_point_cloud.pcd", *cloud) == -1) //* ����PCD��ʽ���ļ�������ļ������ڣ�����-1
	{
		PCL_ERROR("Couldn't read file test_pcd.pcd \n"); //�ļ�������ʱ�����ش�����ֹ����
		return (-1);
	}
	std::cout << "Loaded "
		<< cloud->width * cloud->height
		<< " data points from test_file.pcd with the following fields: "
		<< std::endl;
	//for (size_t i = 0; i < cloud->points.size (); ++i) //��ʾ���еĵ�
	for (size_t i = 0; i < 5; ++i) // Ϊ�˷���۲죬ֻ��ʾǰ5����
		std::cout << "    " << cloud->points[i].x
		<< " " << cloud->points[i].y
		<< " " << cloud->points[i].z << std::endl;
	system("pause");//��ͣ
	return (0);
}