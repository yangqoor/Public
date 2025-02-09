#include <iostream> //��׼���������
#include <pcl/io/pcd_io.h> //PCL��PCD��ʽ�ļ����������ͷ�ļ�
#include <pcl/point_types.h> //PCL�Ը��ָ�ʽ�ĵ��֧��ͷ�ļ�

int  main(int argc, char** argv)
{
	pcl::PointCloud<pcl::PointXYZ> cloud; // �������ƣ�����ָ�룩

										  //����������
	cloud.width = 5; //���õ��ƿ��
	cloud.height = 1; //���õ��Ƹ߶�
	cloud.is_dense = false; //���ܼ���
	cloud.points.resize(cloud.width * cloud.height); //���Σ�����
													 //������Щ�������
	for (size_t i = 0; i < cloud.points.size(); ++i)
	{
		cloud.points[i].x = 1024 * rand() / (RAND_MAX + 1.0f);
		cloud.points[i].y = 1024 * rand() / (RAND_MAX + 1.0f);
		cloud.points[i].z = 1024 * rand() / (RAND_MAX + 1.0f);
	}
	//���浽PCD�ļ�
	pcl::io::savePCDFileASCII("test_pcd.pcd", cloud); //�����Ʊ��浽PCD�ļ���
	std::cerr << "Saved " << cloud.points.size() << " data points to test_pcd.pcd." << std::endl;
	//��ʾ��������
	for (size_t i = 0; i < cloud.points.size(); ++i)
		std::cerr << "    " << cloud.points[i].x << " " << cloud.points[i].y << " " << cloud.points[i].z << std::endl;
	system("pause");
	return (0);
}