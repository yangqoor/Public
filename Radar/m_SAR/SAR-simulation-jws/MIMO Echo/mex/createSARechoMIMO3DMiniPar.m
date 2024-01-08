function sarData = createSARechoMIMO3DMiniPar(sarData,nVerMeasurement,lambda,nTx,nRx,KSlope,p,xM,yr_orig,yt_orig,yv_orig,k)
pxyz = p.pxyz;
sizeSarData = size(sarData);
c = 299792458; % physconst('lightspeed'); in m/s
parfor ixP = 1:p.xLim    % use a parfor to increase the processing efficiency
    for iyP = 1:p.yLim
        for izP = 1:p.zLim
            if pxyz(ixP,iyP,izP) > 1e-8
                stot = complex(zeros(sizeSarData));
                A = -(nVerMeasurement-1)/2;
                B = (nVerMeasurement-1)/2;
                for dely = A:B
                    
                    yr = yr_orig.' + dely*2*lambda * 1e-3 - yv_orig(end/2);
                    yt = yt_orig.' + dely*2*lambda * 1e-3 - yv_orig(end/2);
                    
                    Yr = repmat(yr,1,length(xM));
                    Yt = repmat(yt,1,length(xM));
                    XMr = repmat(xM,length(yr),1);
                    XMt = repmat(xM,length(yt),1);
                    
                    rr = sqrt( (p.xT(ixP) - XMr).^2 + (p.yT(iyP) - Yr).^2 + (p.zT(izP))^2);
                    Rt = sqrt( (p.xT(ixP) - XMt).^2 + (p.yT(iyP) - Yt).^2 + (p.zT(izP))^2);
                    
                    Rr = repmat(rr,1,1,length(k));
                    K = repmat(k,size(Rr,1),size(Rr,2),1);
                    
                    s = complex(zeros(nRx*nTx,length(xM),length(k)));
                    
                    Rt1 = repmat(Rt(1,:),size(Rr,1),1,length(k));
                    Rt2 = repmat(Rt(2,:),size(Rr,1),1,length(k));
                    
                    s(1:4,:,:) = pxyz(ixP,iyP,izP) .* (Rt1.*Rr).^(-1) .* exp(1j*K.*(Rt1 + Rr) - 1j*pi*KSlope/(c^2).*(Rt1.*Rr).^2);
                    s(5:8,:,:) = pxyz(ixP,iyP,izP) .* (Rt2.*Rr).^(-1) .* exp(1j*K.*(Rt2 + Rr) - 1j*pi*KSlope/(c^2).*(Rt2.*Rr).^2);
                    
                    idxStart = round((dely + (nVerMeasurement-1)/2)*nTx*nRx + 1);
                    idxEnd = round((dely + (nVerMeasurement-1)/2 + 1)*nTx*nRx);
                    
                    stot(idxStart:idxEnd,:,:) = s;
                end
                
                sarData = sarData + stot;
            end
        end
    end
end