function opts=ComputeScales(opts)
%% %Create the pyramid scales for kernel till the maximum kernel size
minSize=max(3,2*floor((opts.kSizeMax-1)/25)+1);

numIndex=1;
opts.kScale(numIndex)=minSize;
while (opts.kScale(numIndex)<opts.kSizeMax)
    numIndex=numIndex+1;
    opts.kScale(numIndex)=ceil(opts.kScale(numIndex-1)*sqrt(1.6));
    % Convert to odd if the size turnsout to be even
    opts.kScale(numIndex)=opts.kScale(numIndex) + (mod(opts.kScale(numIndex),2)==0);
end
opts.kScale(numIndex)=opts.kSizeMax;

% Create Image scales from kernel scales.
opts.imScale=(opts.kScale)./opts.kSizeMax;
end