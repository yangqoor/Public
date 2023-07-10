load EpiLineParaCamPro.mat
fid = fopen('EpiLine_A.txt', 'w+');
for h = 1:CamInfo.HEIGHT
  for w = 1:CamInfo.WIDTH
    fprintf(fid, '%f ', EpiLine.lineA(h, w));
  end
  fprintf(fid, '\n');
end
fclose(fid);
fid = fopen('EpiLine_B.txt', 'w+');
for h = 1:CamInfo.HEIGHT
  for w = 1:CamInfo.WIDTH
    fprintf(fid, '%f ', EpiLine.lineB(h, w));
  end
  fprintf(fid, '\n');
end
fclose(fid);
