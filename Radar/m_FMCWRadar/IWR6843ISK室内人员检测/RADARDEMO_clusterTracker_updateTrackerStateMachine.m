function  RADARDEMO_clusterTracker_updateTrackerStateMachine(tid,hitflag,activeThreshold,forgetThreshold)
    global Tracker
    switch Tracker(tid).state
        case 0    %RADARDEMO_TRACKER_STATE_DETECTION
            if hitflag
                Tracker(tid).detect2freeCount=0;
                if Tracker(tid).detect2activeCount > activeThreshold
					Tracker(tid).state = 1;   % RADARDEMO_TRACKER_STATE_ACTIVE
				else
					Tracker(tid).detect2activeCount=Tracker(tid).detect2activeCount+1;
                end
            else
                if Tracker(tid).detect2freeCount > forgetThreshold
					Tracker(tid).state = -1;  % RADARDEMO_TRACKER_STATE_EXPIRE
				else
					Tracker(tid).detect2freeCount= Tracker(tid).detect2freeCount+1;
                end
				if Tracker(tid).detect2activeCount > 0
					Tracker(tid).detect2activeCount= Tracker(tid).detect2activeCount-1;
                end

            end
%             break

        case 1   % RADARDEMO_TRACKER_STATE_ACTIVE
            if hitflag
				if Tracker(tid).active2freeCount > 0
					Tracker(tid).active2freeCount =Tracker(tid).active2freeCount-1;    
                end
                %wrx_0929 :type
                if abs(Tracker(tid).doppler)<0.2 &  abs(Tracker(tid).S_hat(1))<0.1
                    Tracker(tid).typeCount = Tracker(tid).typeCount + 1;
                end 
            else
				if Tracker(tid).active2freeCount > forgetThreshold
					Tracker(tid).state =-1 ;%¡­¡­RADARDEMO_TRACKER_STATE_EXPIRE =-1
				else
					Tracker(tid).active2freeCount =Tracker(tid).active2freeCount +1;
                end
            end
    end
end