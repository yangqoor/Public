% https://mp.weixin.qq.com/s?__biz=Mzg4MTcwODk5Ng==&mid=2247491550&idx=1&sn=2507086925e13c2b47be73e286124514&chksm=cf608575f8170c63066cde561b2653e1133d00a46a117a92436d464db6c52ac1182fed60036c&scene=178&cur_album_id=2243156475386839051#rd
HM=load('data7.mat');
HMHdl=heatmap(HM.Data);
colormap(HM.CMapInterp)
% 新版本可以将caxis换为clim
caxis(HM.climColorbar)

% 不显示数值
HMHdl.CellLabelColor='none';



