function []=MmwDemo_Tracking_s(cluInfo,F,Q,measurementNoiseVariance,...
                             activeThreshold,forgetThreshold,iirForgetFactor,Track_Thres)
    global Tracker
    global activeTrackerList
    global idleTrackerList
    global RADARDEMO_CT_MAX_NUM_CLUSTER
    global RADARDEMO_CT_MAX_NUM_TRACKER
    global RADARDEMO_CT_MAX_NUM_ASSOC
    global RADARDEMO_CT_MAX_DIST
    global RADARMEDO_CT_MAX_NUM_EXPIRE

    % 这3个变量与cluster有关，每帧重置
    pendingIndication(1:RADARDEMO_CT_MAX_NUM_CLUSTER) = 1;                                % 某个Cluster是否处理过 1表示未处理
    associatedList=-1*ones(RADARDEMO_CT_MAX_NUM_TRACKER*100,RADARDEMO_CT_MAX_NUM_ASSOC);  % 某个Tracker关联到的Cluster                                                                                  
    numAssoc(1:RADARDEMO_CT_MAX_NUM_TRACKER*100)=0;                                       % 某个Tracker关联到的Cluster的数目
    numTracker = length(activeTrackerList); 
    numCluster = size(cluInfo,2);
    
    %% RADARDEMO_clusterTracker_inputDataTransfer  输入数据转换
    for k = 1: numCluster
		inputInfo(k).xSize = cluInfo(k).xsize;
		inputInfo(k).ySize = cluInfo(k).ysize;
        inputInfo(k).zSize = cluInfo(k).zsize;   
		inputInfo(k).doppler = cluInfo(k).v;   
		inputInfo(k).numPoints = cluInfo(k).numPoints;
		inputInfo(k).rangeVar = cluInfo(k).centerRangeVar;
		inputInfo(k).angleVar = cluInfo(k).centerAngleVar;
		inputInfo(k).dopplerVar = cluInfo(k).centerDopplerVar;
        
		posx = cluInfo(k).x;
		posy = cluInfo(k).y;
        posz = cluInfo(k).z;  
		inputInfo(k).range = (sqrt(posx*posx + posy*posy)); 
		%%calc azimuth
		inputInfo(k).azimuth = atan(posy/posx);
        if posx < 0
            inputInfo(k).azimuth = inputInfo(k).azimuth +pi;
        end
    end
    if ~isempty(cluInfo)
        inputX=cluInfo(k).x;
        inputY=cluInfo(k).y;
    else 
        inputX=[];
        inputY=[];
    end
  
    %% RADARDEMO_clusterTracker_timeUpdateTrackers
    %计算activeTrackList中的所有Track的S_apriori_hat   H_s_apriori_hat
    for k=1:numTracker
        tid=activeTrackerList(k);
        Tracker(tid).S_apriori_hat= F * Tracker(tid).S_hat;
        %RADARDEMO_tracker_computeH
        posx = Tracker(tid).S_apriori_hat(1,:); 
        posy = Tracker(tid).S_apriori_hat(2,:); 
        velx = Tracker(tid).S_apriori_hat(3,:); 
        vely = Tracker(tid).S_apriori_hat(4,:);
        
        %% 从球面坐标转换为笛卡尔坐标
        Tracker(tid).H_s_apriori_hat(1)= sqrt(posx*posx + posy*posy);% 求R的长度
        Tracker(tid).H_s_apriori_hat(2)= atan(posy/posx);            % 求角度
        if posx < 0
            Tracker(tid).H_s_apriori_hat(2)= atan(posy/posx)+ pi;
        end
        Tracker(tid).H_s_apriori_hat(3)=(posx*velx+posy*vely)/sqrt(posx*posx + posy*posy);%切向速度分量
    end
    clear posx posy velx vely
    if (numCluster > 0)
       %% RADARDEMO_clusterTracker_associateTrackers
        hitFlag=0;
        if numCluster > 0 && numTracker > 0
            for mid=1:numCluster
                 % 计算从一个度量到所有跟踪器的距离
                 % 记录最小分布，并关联索引 
                minDist = RADARDEMO_CT_MAX_DIST;
                for j=1:numTracker
                    tid=activeTrackerList(j);
                    u_tilda =[inputInfo(mid).range;inputInfo(mid).azimuth;inputInfo(mid).doppler ]- Tracker(tid).H_s_apriori_hat;
                
                    dist(mid,tid) = u_tilda'*matinv(Tracker(tid).C)*u_tilda ;  %distance
                    if dist(mid,tid) < minDist
                        minDist = dist(mid,tid);
                        minTid = tid;
                    end
                end
               r_Th = max(Track_Thres(1),Tracker(tid).diagonal2^0.5/2);
               x_Th = Track_Thres(2);
               v_Th = Track_Thres(3);
 
               ang_ref = 2*atan(x_Th/Tracker(tid).H_s_apriori_hat(1));
               distTH= [r_Th;ang_ref; v_Th]'*matinv(Tracker(tid).C)*[r_Th; ang_ref; v_Th];  %distance
               [distTH2, ~, ~,~] = gateCreateLim(20, matinv(Tracker(tid).C), Tracker(tid).H_s_apriori_hat, [10 4 0]);

                if minDist < distTH
                    Tracker(tid).distTHPrev=5*minDist;  %为啥要乘5，理论依据在哪里呢？
                    len = numAssoc(minTid)+1;    
                    
                    %add to the association list
                    associatedList(minTid,len)=mid;
                    numAssoc(minTid)=numAssoc(minTid)+1;
                    
                    %remove from pending Indication list
                    pendingIndication(mid) = 0;
                    
                    %error protection
                    if numAssoc(minTid) >= RADARDEMO_CT_MAX_NUM_ASSOC
                        disp('RADARDEMO_CLUSTERTRACKER_NUM_ASSOC_EXCEED_MAX');
                    end
                end
            end  %for nMeas
        end

       %% RADARDEMO_clusterTracker_allocateNewTrackers   分配新轨迹
        for mid=1:numCluster
            if pendingIndication(mid) == 1    %1表示没处理过
                if ~isempty(idleTrackerList)
                    %RADARDEMO_clusterTrackerList_addToList 
                    tid=idleTrackerList(1);
                    activeTrackerList=[activeTrackerList tid];
                    idleTrackerList=idleTrackerList(2:end);
                    idleTrackerList=[idleTrackerList idleTrackerList(end)+1];
                    Tracker(tid).state=0;%RADARDEMO_TRACKER_STATE_DETECTION
                    Tracker(tid).detect2activeCount=0;
                    Tracker(tid).detect2freeCount = 0;
                    Tracker(tid).active2freeCount = 0;
                    Tracker(tid).typeCount = 0;

                    Tracker(tid).xSize = inputInfo(mid).xSize;
                    Tracker(tid).ySize = inputInfo(mid).ySize;
                    Tracker(tid).zSize = inputInfo(mid).zSize;   %SKL
                    
                    Tracker(tid).diagonal2 = inputInfo(mid).xSize^2 + inputInfo(mid).ySize^2; 
                    Tracker(tid).speed2 = inputInfo(mid).doppler * inputInfo(mid).doppler;
                    
                    Tracker(tid).doppler = inputInfo(mid).doppler;
                    pendingIndication(mid) = 0;

                    %Initialization S_hat, P 坐标转换，极坐标系到直角坐标系
                    Tracker(tid).S_hat(1,:)=inputInfo(mid).range * cos(inputInfo(mid).azimuth);
                    Tracker(tid).S_hat(2,:)=inputInfo(mid).range * sin(inputInfo(mid).azimuth);
                    Tracker(tid).S_hat(3,:)=inputInfo(mid).doppler * cos(inputInfo(mid).azimuth);
                    Tracker(tid).S_hat(4,:)=inputInfo(mid).doppler * sin(inputInfo(mid).azimuth);

                    Tracker(tid).P=diag(ones(1,4)) ;
                    Tracker(tid).C=diag(ones(1,3)) ;
%                     Tracker(tid).C=(zeros(3,3))+1e-4;
                    Tracker(tid).S_apriori_hat = F * Tracker(tid).S_hat;
                    
                    Tracker(tid).distTHPrevList=10000;
                    
                    posx = Tracker(tid).S_apriori_hat(1,:); 
                    posy = Tracker(tid).S_apriori_hat(2,:); 
                    velx = Tracker(tid).S_apriori_hat(3,:); 
                    vely = Tracker(tid).S_apriori_hat(4,:);

                    %convert from spherical to Cartesian coordinates
                    Tracker(tid).H_s_apriori_hat(1,:)=sqrt(posx*posx + posy*posy);
                    Tracker(tid).H_s_apriori_hat(2,:)=atan(posy/posx);
                    if posx < 0
                        Tracker(tid).H_s_apriori_hat(2,:)=atan(posy/posx) +pi;
                    end
                    Tracker(tid).H_s_apriori_hat(3,:)=(posx*velx+posy*vely)/sqrt(posx*posx + posy*posy);
                    
                else
                    disp('RADARDEMO_CLUSTERTRACKER_FAIL_ALLOCATE_TRACKER');
                end

            end
        end
    end
   %% RADARDEMO_clusterTracker_updateTrackers
   numExpireTracker=0;
   expireList=[];
   R=zeros(3,3);
   Rm=zeros(3,3);
   numTracker=length(activeTrackerList);
   for i=1:numTracker
       tid=activeTrackerList(i);
       temp=find(associatedList(tid,:)>-1);
       if ~isempty(temp)
           %there is some measurement associate with this tracker
           hitflag = 1;
           RADARDEMO_clusterTracker_updateTrackerStateMachine(tid,hitflag,activeThreshold,forgetThreshold);
           %calculate the new measure based on all the assocated measures, xSize and ySize will be set to the maximum xSize and ySize
%            mid=associatedList(i);
%            combined=inputInfo;
           mid=associatedList(tid,associatedList(tid,:)>-1);
           if length(mid) > 1
               %RADARDEMO_clusterTracker_combineMeasure  
               totsize=sum([inputInfo(mid).numPoints]);
              
               combined.range=sum([inputInfo(mid).numPoints].*[inputInfo(mid).range])/totsize;          %以点数为权重
               combined.azimuth=sum([inputInfo(mid).numPoints].*[inputInfo(mid).azimuth])/totsize;      %以点数为权重
               combined.doppler=sum([inputInfo(mid).numPoints].*[inputInfo(mid).doppler])/totsize;      %以点数为权重
              
               combined.rangeVar=sum([inputInfo(mid).numPoints].*[inputInfo(mid).rangeVar])/totsize;    %以点数为权重
               combined.angleVar=sum([inputInfo(mid).numPoints].*[inputInfo(mid).angleVar])/totsize;    %以点数为权重
               combined.dopplerVar=sum([inputInfo(mid).numPoints].*[inputInfo(mid).dopplerVar])/totsize;%以点数为权重
              
               combined.xSize=max([inputInfo(mid).xSize]);
               combined.ySize=max([inputInfo(mid).ySize]);
               combined.zSize=max([inputInfo(mid).zSize]);  %SKL
           else
               combined=inputInfo(mid);
           end  
           
           R(1,1)=combined.rangeVar* measurementNoiseVariance;
           R(2,2)=combined.angleVar* measurementNoiseVariance;
           R(3,3)=combined.dopplerVar* measurementNoiseVariance;
           
           Rm(1,1)=4;
           Rm(2,2)=(2*atan(0.5*1/Tracker(tid).H_s_apriori_hat(1)))^2;
           Rm(3,3)=1;
           
           %% RADARDEMO_clusterTracker_kalmanUpdate() 卡尔曼更新
           
           Tracker(tid).P_apriori=F * Tracker(tid).P * F'+ Q;   %噪声矩阵
           
           Tracker(tid).P_apriori=0.5*(Tracker(tid).P_apriori + Tracker(tid).P_apriori');     
            combined_posx =  combined.range   *  cos(combined.azimuth);
            combined_posy =  combined.range   *  sin(combined.azimuth);
            combined_velx =  combined.doppler *  cos(combined.azimuth);
            combined_vely =  combined.doppler *  sin(combined.azimuth); %极坐标 变为直角坐标系
            
            combine_s_hat = [combined_posx combined_posy combined_velx combined_vely]';
            
            Tracker(tid).S_apriori_hat =Tracker(tid).S_apriori_hat *(1-iirForgetFactor) + combine_s_hat * iirForgetFactor;

            H=zeros(3,4);
            S=Tracker(tid).S_apriori_hat;

            r2 = (S(1)*S(1) + S(2)*S(2) );
            r = sqrt(r2);
            H(1,1) = S(1)/r; 
            H(1,2) = S(2)/r; 
            H(2,1) = -S(2)/r2; 
            H(2,2) = S(1)/r2;  
            H(3,1) = ((S(2)*(S(3)*S(2) - S(1)*S(4)))/r/r2);
            H(3,2) = ((S(1)*(S(4)*S(1) - S(3)*S(2)))/r/r2);
            H(3,3) = (S(1)/r); 
            H(3,4) = (S(2)/r); 

            % Kalman gain using matrix inverse via Cholesky decomposition
            %K = obj.P_apriori(:,:,tid) * H' * matinv(H * obj.P_apriori(:,:,tid) * H' + R);
            %KG=Tracker(tid).P_apriori * H' * inv(H * Tracker(tid).P_apriori * H' + R);

            Tracker(tid).C  = (H * Tracker(tid).P_apriori * H' + R + Rm);
            
            %% 计算卡尔曼增益公式
            KG=Tracker(tid).P_apriori * H' / (H * Tracker(tid).P_apriori * H' + R + Rm);
            
            %obj.P(:,:,tid) = obj.P_apriori(:,:,tid) - K * H * obj.P_apriori(:,:,tid)
            %% 估计协方差更新
            Tracker(tid).P=Tracker(tid).P_apriori- KG * H * Tracker(tid).P_apriori;
            
            %obj.S_hat(:,tid) = obj.S_apriori_hat(:,tid) + K * (um - obj.H_s_apriori_hat(:,tid));
            %% 对关联上的轨迹进行更新
            Tracker(tid).S_hat =Tracker(tid).S_apriori_hat + KG * ([combined.range;combined.azimuth;combined.doppler]- Tracker(tid).H_s_apriori_hat);

            %update speed2 and doppler
            Tracker(tid).speed2=Tracker(tid).S_hat(3,:)^2+Tracker(tid).S_hat(4,:)^2;
            Tracker(tid).doppler = combined.doppler;

            %update xSize and ySize
            Tracker(tid).xSize = min (max([Tracker(tid).xSize,combined.xSize ]),3);
            Tracker(tid).ySize = min (max([Tracker(tid).ySize,combined.ySize ]),8);
            Tracker(tid).zSize = min (max([Tracker(tid).zSize,combined.zSize ]),5);
            
            diag2 = Tracker(tid).xSize * Tracker(tid).xSize + Tracker(tid).ySize * Tracker(tid).ySize;
            Tracker(tid).diagonal2 = diag2;
            
       else
           hitFlag = 0;
           RADARDEMO_clusterTracker_updateTrackerStateMachine(tid,hitFlag,activeThreshold,forgetThreshold);
           if ((Tracker(tid).state == -1) && (numExpireTracker < RADARMEDO_CT_MAX_NUM_EXPIRE))
               %collect the free list and free at the end of the function;
                numExpireTracker= numExpireTracker+1;
                expireList(numExpireTracker) = tid;
           else 
                %RADARDEMO_clusterTracker_kalmanUpdateWithNoMeasure(tracker, handle->F, handle->Q);
                Tracker(tid).P_apriori= F * Tracker(tid).P *F' + Q;
                Tracker(tid).P =Tracker(tid).P_apriori;
                Tracker(tid).S_hat=Tracker(tid).S_apriori_hat;
           end
       end
   end
   %free the expired tracker
    for j = 1:numExpireTracker
        %RADARDEMO_clusterTrackerList_removeFromList(handle, expireList[j]);
        activeTrackerList=activeTrackerList(activeTrackerList(:) ~=expireList(j));
        idleTrackerList=[idleTrackerList expireList(j)];
    end


end
