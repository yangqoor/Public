#include <iostream> //��׼����/���
#include <pcl/io/pcd_io.h> //pcd�ļ�����/���
#include <pcl/point_types.h> //���ֵ�����
#include <pcl/registration/icp.h> //ICP(iterative closest point)��׼

int main(int argc, char** argv)
{
	//��������ָ��
	pcl::PointCloud<pcl::PointXYZ>::Ptr cloud_in(new pcl::PointCloud<pcl::PointXYZ>); //����������ƣ�ָ�룩
	pcl::PointCloud<pcl::PointXYZ>::Ptr cloud_out(new pcl::PointCloud<pcl::PointXYZ>); //�������/Ŀ����ƣ�ָ�룩

																					   //���ɲ�������cloud_in
	cloud_in->width = 5;
	cloud_in->height = 1;
	cloud_in->is_dense = false;
	cloud_in->points.resize(cloud_in->width * cloud_in->height); //���Σ�����
	for (size_t i = 0; i < cloud_in->points.size(); ++i) //�������ʼ���������
	{
		cloud_in->points[i].x = 1024 * rand() / (RAND_MAX + 1.0f);
		cloud_in->points[i].y = 1024 * rand() / (RAND_MAX + 1.0f);
		cloud_in->points[i].z = 1024 * rand() / (RAND_MAX + 1.0f);
	}
	std::cout << "Saved " << cloud_in->points.size() << " data points to input:"
		<< std::endl;
	//��ӡ����cloud_in�����е��������Ϣ
	for (size_t i = 0; i < cloud_in->points.size(); ++i) std::cout << "    " <<
		cloud_in->points[i].x << " " << cloud_in->points[i].y << " " <<
		cloud_in->points[i].z << std::endl;

	// ������cloud_out
	*cloud_out = *cloud_in; //��ʼ��cloud_out
	std::cout << "size:" << cloud_out->points.size() << std::endl;
	for (size_t i = 0; i < cloud_in->points.size(); ++i)
		cloud_out->points[i].x = cloud_in->points[i].x + 0.7f; //ƽ��cloud_in�õ�cloud_out
	std::cout << "Transformed " << cloud_in->points.size() << " data points:"
		<< std::endl;
	//��ӡ����cloud_out�����е��������Ϣ��ÿһ�ж�Ӧһ�����xyz���꣩
	for (size_t i = 0; i < cloud_out->points.size(); ++i)
		std::cout << "    " << cloud_out->points[i].x << " " <<
		cloud_out->points[i].y << " " << cloud_out->points[i].z << std::endl;
	//*********************************
	// ICP��׼
	//*********************************
	pcl::IterativeClosestPoint<pcl::PointXYZ, pcl::PointXYZ> icp; //����ICP��������ICP��׼
	icp.setInputCloud(cloud_in); //�����������
	icp.setInputTarget(cloud_out); //����Ŀ����ƣ�������ƽ��з���任���õ�Ŀ����ƣ�
	pcl::PointCloud<pcl::PointXYZ> Final; //�洢���
										  //������׼������洢��Final��
	icp.align(Final);
	//���ICP��׼����Ϣ���Ƿ���������϶ȣ�
	std::cout << "has converged:" << icp.hasConverged() << " score: " <<
		icp.getFitnessScore() << std::endl;
	//������յı任����4x4��
	std::cout << icp.getFinalTransformation() << std::endl;

	return (0);
}