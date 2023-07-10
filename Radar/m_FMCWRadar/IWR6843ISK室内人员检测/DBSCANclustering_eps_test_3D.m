function  [sumClu]=DBSCANclustering_eps_test_3D(eps,Obj,xFactor,yFactor,minPointsInCluster,FrameIndx)
   
    %�����ж�׼��        (x-r0)^2 + (y-y0)^2/yFactor^2 + (v-v0)^2 /vFactor^2< eps^2   
    %maxClusters��        ��������
    %minPointsInCluster�� һ��cluster����С����
    %maxPoints��          һ��cluster������������
    %Obj��׼���ݽṹ       = [x,y,R,v��peakVal��SNR��aoaVar];
  
    %����
    epsilon2_= eps*eps;      
    numPoints	=	size(Obj,1);
    visited= zeros(numPoints,1);
    clusterId=0;
    sumClu=[]; 
    
    figure(2);
    colors = 'bgrcm';
    for i=1:numPoints
        if visited(i) == 0    %δ��ǵ� �����еĵ���Ϊ0
            visited(i) = 1;   %ȡ��һ�����ĵ�q�����Ϊ1
            tempIdx=i;   
            x=Obj(i,1);
            y=Obj(i,2);
            %�Ե�һ���ο���������ж�
            numInEps=1; 
            for k=1:numPoints
                if visited(k) == 0        %״̬0  
                    summ = (Obj(k,1)-x)^2/xFactor^2+...
                         (Obj(k,2)-y)^2 /yFactor^2;
                    if summ < epsilon2_     %�õ����ڴ�cluster
                        numInEps = numInEps+ 1;                      
                        tempIdx=[tempIdx k];
                    end
                end
            end            
            if numInEps > minPointsInCluster
                visited(i) = 1;   %���ĵ�
                for in = 1:numInEps   %�״α����ĵ����ǣ���̬��ǣ�
                    visited(tempIdx(in)) = 1;   
                end
                next = 2;
                while  next<=length(tempIdx)
                    point_ref = tempIdx(next);
                    x = Obj(point_ref,1);
                    y = Obj(point_ref,2);
                    tempInd = [];
                    for ind=1:numPoints
                        if visited(ind) == 0        %״̬0  
                            summ = (Obj(ind,1)-x)^2/xFactor^2+...
                                 (Obj(ind,2)-y)^2/yFactor^2;                            
                            if summ < epsilon2_     %�õ����ڴ�cluster
                               tempInd = [tempInd ind];
                            end
                        end
                    end

                    if length(tempInd) > minPointsInCluster
                        visited(point_ref) = 1;   %���ĵ�
                        numInEps = numInEps+ length(tempInd);
                        tempIdx = [tempIdx tempInd];
                        for kk = 1:length(tempInd)
                            visited(tempInd(kk)) = 1;   %���ĵ�
                        end
                    else
                        visited(point_ref) = -1; %�߽��
                    end
                    next = next+1;
                end
                
                tempClu=Obj(tempIdx,:);%obj = [ Y,X,h ,objSpeed,snr];
                cluLength=size(tempIdx,2);
              
                for pi=1:cluLength
                    ind = tempIdx(pi);
                    if  visited(ind)==1
                           plot(tempClu(pi,2),tempClu(pi,1),'.','color', colors(mod(clusterId,length(colors))+1));
                         hold on;
                    elseif  visited(ind)==-1
                           plot(tempClu(pi,2),tempClu(pi,1),'*','color', colors(mod(clusterId,length(colors))+1));                    
                         hold on;
                    end
                end
                title(['����������*:�߽�� , o�����ĵ� , .:������)֡����',num2str(FrameIndx)]);
                xlabel('�㼣ˮƽλ�� �� m');
                ylabel('�㼣��ֱλ�� �� m');
                hold on;
            else
                visited(i) = -2; %������  
                cluLength = 1;
                plot(Obj(i,2),Obj(i,1),'r.');
           
                hold on;
            end
             
            if cluLength > 1
                clusterId=clusterId+1;    % New cluster ID
                output_IndexArray(tempIdx)=clusterId;
                sumClu(clusterId).numPoints=cluLength;   % x y  peakValue  speed   
                sumClu(clusterId).x_mean=mean(tempClu(:,1));   % x y  peakValue  speed  
                sumClu(clusterId).y_mean=mean(tempClu(:,2)); 
                sumClu(clusterId).z_mean=mean(tempClu(:,3)); 

               % ͨ�� SNR��Ȩ
               sumClu(clusterId).x_SNR =(1./tempClu(:,5)')*tempClu(:,1)/sum(1./tempClu(:,5));   % x y  peakValue  speed   
               sumClu(clusterId).y_SNR =(1./tempClu(:,5)')*tempClu(:,2)/sum(1./tempClu(:,5));   % x y  peakValue  speed
%              sumClu(clusterId).z_SNR=(1./[tempClu.InvSNR])*[tempClu.z]'/sum(1./[tempClu.InvSNR]); 
               sumClu(clusterId).z_SNR =(1./tempClu(:,5)')*tempClu(:,3)/sum(1./tempClu(:,5));

                % ��ȡ��ֵ
                [ ~,I]=max(1./tempClu(:,5));
                tempx=tempClu(:,1);
                tempy=tempClu(:,2);
                tempz=tempClu(:,3);
          
                sumClu(clusterId).x_peak=tempx(I);    
                sumClu(clusterId).y_peak=tempy(I);
                sumClu(clusterId).z_peak=tempz(I);

                %yȡ���λ�� xȡ��ֵ
                sumClu(clusterId).x_edge = mean(tempClu(:,1));   
                sumClu(clusterId).y_edge = min(tempClu(: ,2));
                sumClu(clusterId).z_edge = mean(tempClu(:,3));
     
                sumClu(clusterId).x=sumClu(clusterId).x_mean;  
                sumClu(clusterId).y=sumClu(clusterId).y_mean;
                sumClu(clusterId).z=sumClu(clusterId).z_mean;
        
                sumClu(clusterId).xsize=max(abs(tempClu(:,1)-sumClu(clusterId).x));
                sumClu(clusterId).ysize=max(abs(tempClu(:,2)-sumClu(clusterId).y));
                sumClu(clusterId).zsize=max(abs(tempClu(:,3)-sumClu(clusterId).z));
                sumClu(clusterId).v=mean(tempClu(:,4)); 
                sumClu(clusterId).head =  sumClu(clusterId).y - sumClu(clusterId).ysize/2;

                if sumClu(clusterId).xsize < 1e-3
                    sumClu(clusterId).xsize=1;
                end
                if sumClu(clusterId).ysize < 1e-3
                    sumClu(clusterId).ysize=1;
                end

                if cluLength>1
                   sumClu(clusterId).centerRangeVar=var(sqrt(tempClu(:,1).^2+tempClu(:,2).^2));
                   sumClu(clusterId).centerAngleVar=mean(deg2rad(tempClu(:,2)).^2);
                   sumClu(clusterId).centerDopplerVar=var(tempClu(:,4));

                else
                   sumClu(clusterId).centerRangeVar=1;
                   sumClu(clusterId).centerAngleVar=1;
                   sumClu(clusterId).centerDopplerVar=1;
                end
            else
               continue;
            end
 
         end
    end   

    grid on
    xlim([-5,5])
    ylim([0,8])
    hold off
  
end