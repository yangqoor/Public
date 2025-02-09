#include <iostream> //��׼���������
#include <pcl/io/pcd_io.h> //PCL��PCD��ʽ�ļ����������ͷ�ļ�
#include <pcl/point_types.h> //PCL�Ը��ָ�ʽ�ĵ��֧��ͷ�ļ�
//���磬��ĳ�����������ջ�����˵���в����˵���㵽ʲô�ط����ڴ棬
//�����Ĵ�����Ϣ��cerr��Ŀ�ģ�������������Ҫ���Ľ�������£�
//���ܵõ�������ܵ�֧�֡� ��������Ŀ�ģ����Ǽ���ˢ���Ĵ���

// ����ƴ��A��B��C
int main(int argc, char** argv)
{
	if (argc != 2) // ��Ҫһ������ -f �� -p
	{
		std::cerr << "please specify command line arg '-f' or '-p'" << std::endl;
		exit(0);
	}
	// ����ƴ�Ӳ�ͬ���Ƶĵ�ı���
	pcl::PointCloud<pcl::PointXYZ> cloud_a, cloud_b, cloud_c; //�������ƣ�����ָ�룩���洢������xyz
															  // ����ƴ�Ӳ�ͬ���Ƶ��򣨵�ͷ��������ı���
	pcl::PointCloud<pcl::Normal> n_cloud_b; //�������ƣ����淨����
	pcl::PointCloud<pcl::PointNormal> p_n_cloud_c; //�������ƣ����������ͷ�����

												   //����������
	cloud_a.width = 5; //���ÿ��
	cloud_a.height = cloud_b.height = n_cloud_b.height = 1; //���ø߶�
	cloud_a.points.resize(cloud_a.width * cloud_a.height); //���Σ�����
	if (strcmp(argv[1], "-p") == 0) //����������������õ���
	{
		cloud_b.width = 3; //cloud_b����ƴ�Ӳ�ͬ���Ƶĵ�
		cloud_b.points.resize(cloud_b.width * cloud_b.height);
	}
	else {
		n_cloud_b.width = 5; //n_cloud_b����ƴ�Ӳ�ͬ���Ƶ���
		n_cloud_b.points.resize(n_cloud_b.width * n_cloud_b.height);
	}
	for (size_t i = 0; i < cloud_a.points.size(); ++i) //����cloud_a�е�����꣨�������
	{
		cloud_a.points[i].x = 1024 * rand() / (RAND_MAX + 1.0f);
		cloud_a.points[i].y = 1024 * rand() / (RAND_MAX + 1.0f);
		cloud_a.points[i].z = 1024 * rand() / (RAND_MAX + 1.0f);
	}
	if (strcmp(argv[1], "-p") == 0)
		for (size_t i = 0; i < cloud_b.points.size(); ++i) //����cloud_b�е�����꣨�������
		{
			cloud_b.points[i].x = 1024 * rand() / (RAND_MAX + 1.0f);
			cloud_b.points[i].y = 1024 * rand() / (RAND_MAX + 1.0f);
			cloud_b.points[i].z = 1024 * rand() / (RAND_MAX + 1.0f);
		}
	else // -f
		for (size_t i = 0; i < n_cloud_b.points.size(); ++i) //����n_cloud_b�е�����꣨�������
		{
			n_cloud_b.points[i].normal[0] = 1024 * rand() / (RAND_MAX + 1.0f);
			n_cloud_b.points[i].normal[1] = 1024 * rand() / (RAND_MAX + 1.0f);
			n_cloud_b.points[i].normal[2] = 1024 * rand() / (RAND_MAX + 1.0f);
		}

	// ��ӡƴ���õ����� A��B
	std::cerr << "Cloud A: " << std::endl;
	for (size_t i = 0; i < cloud_a.points.size(); ++i) //��ӡcloud_a�ĵ�������Ϣ
		std::cerr << "    " << cloud_a.points[i].x << " " << cloud_a.points[i].y << " " << cloud_a.points[i].z << std::endl;

	std::cerr << "Cloud B: " << std::endl; //��ӡCloud B
	if (strcmp(argv[1], "-p") == 0) //�����������-p����ӡcloud_b��
		for (size_t i = 0; i < cloud_b.points.size(); ++i)
			std::cerr << "    " << cloud_b.points[i].x << " " << cloud_b.points[i].y << " " << cloud_b.points[i].z << std::endl;
	else //��-f����ӡn_cloud_b
		for (size_t i = 0; i < n_cloud_b.points.size(); ++i)
			std::cerr << "    " << n_cloud_b.points[i].normal[0] << " " << n_cloud_b.points[i].normal[1] << " " << n_cloud_b.points[i].normal[2] << std::endl;

	//���Ƶ����еĵ�
	if (strcmp(argv[1], "-p") == 0)
	{
		cloud_c = cloud_a;
		cloud_c += cloud_b; // cloud_a + cloud_b ��˼��cloud_c������a��b�еĵ㣬c�ĵ��� = a�ĵ���+b�ĵ���
		std::cerr << "Cloud C: " << std::endl; ////��ӡCloud C
		for (size_t i = 0; i < cloud_c.points.size(); ++i) //��ӡCloud C
			std::cerr << "    " << cloud_c.points[i].x << " " << cloud_c.points[i].y << " " << cloud_c.points[i].z << " " << std::endl;
	}
	else //�����������-f
	{
		pcl::concatenateFields(cloud_a, n_cloud_b, p_n_cloud_c); //ƴ�ӣ��㣩cloud_a�ͣ���������n_cloud_b��p_n_cloud_c
		std::cerr << "Cloud C: " << std::endl;
		for (size_t i = 0; i < p_n_cloud_c.points.size(); ++i) //��ӡCloud C
			std::cerr << "    " <<
			p_n_cloud_c.points[i].x << " " << p_n_cloud_c.points[i].y << " " << p_n_cloud_c.points[i].z << " " <<
			p_n_cloud_c.points[i].normal[0] << " " << p_n_cloud_c.points[i].normal[1] << " " << p_n_cloud_c.points[i].normal[2] << std::endl;
	}
	
	return (0);
}