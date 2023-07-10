%Samuel Rivera
% 
% Copyright (C) 2009, 2010 Samuel Rivera, Liya Ding, Onur Hamsici, Paulo
%   Gotardo, Fabian Benitez-Quiroz and the Computational Biology and 
%   Cognitive Science Lab (CBCSL).
% 
% Contact: Samuel Rivera (sriveravi@gmail.com)


function [AE , stdErr, variance, allE]  = calcAveError( rootName, whole )

allE = [];
tempE = [];

if isdir( 'rootName' )
    if exist( [ rootName 'KRRRegressionDetectAAMResult4.mat'], 'file' )


        display( 'AAM results calculating');
        for i = 0:4
            %all the face coordinates stored here
            leftEyeData =  [ rootName 'KRRRegressionDetectAAMResult' int2str(i) '.mat'];

            load( leftEyeData ); 
            s = (size(testResult,1)); 
            for j = 1:size(testResult,2)
                [Leye(i+1,j), tempE1] = aveError(testResult(1:s/2,j),testResult(s/2+1:end,j)) ;
            tempE = [ tempE; tempE1];
            end
            allE = [ allE ; tempE ];
            tempE = [];
        end

        AE = mean(  mean(Leye(:))); 

        stdErr = sqrt(var( allE,1))/size(allE,1);
        variance =  var( allE,1);    

    elseif whole
        for i = 0:4
            %all the face coordinates stored here
            leftEyeData =  [ rootName 'KRRRegressionDetectWholeFaceNoWarpResult' int2str(i) '.mat'];

            load( leftEyeData ); 
            s = (size(testResult,1)); 
            for j = 1:size(testResult,2)
                [Leye(i+1,j), tempE1] = aveError(testResult(1:s/2,j),testResult(s/2+1:end,j)) ;
            tempE = [ tempE; tempE1];
            end
            allE = [ allE ; tempE ];
            tempE = [];
        end

        AE = mean(  mean(Leye(:))); 

        stdErr = sqrt(var( allE,1))/size(allE,1);
        variance =  var( allE,1);    

    else
        for i = 0:4
            leftEyeData = [ rootName 'KRREyeDetectLeftEyeResult' int2str(i) '.mat'];
            rightEyeData = [rootName 'KRREyeDetectRightEyeResult' int2str(i) '.mat'];
            leftEyebrowData = [rootName 'KRRLeftEyebrowResult' int2str(i) '.mat'];
            rightEyebrowData = [rootName 'KRRRightEyebrowResult' int2str(i) '.mat'];
            mouthDataFile = [rootName 'KRRRegressionDetectMouthCropResult' int2str(i) '.mat'];
            noseDataFile = [rootName 'KRRRegressionDetectNoseResult' int2str(i) '.mat'];
            chinDataFile = [rootName 'KRRRegressionDetectChinResult' int2str(i) '.mat'];


            %for eye results
            load( leftEyeData ); 
            s = (size(testResult,1)); 
            for j = 1:size(testResult,2)
                [Leye(i+1,j), tempE1] = aveError(testResult(1:s/2,j),testResult(s/2+1:end,j)) ;
            tempE = [ tempE; tempE1];
            end
            allE = [ allE ; tempE ];
            tempE = [];

            load( rightEyeData ); 
            for j = 1:size(testResult,2)
                [ Reye(i+1,j) , tempE1] = aveError(testResult(1:s/2,j),testResult(s/2+1:end,j)) ;
                tempE = [ tempE; tempE1];
            end
            allE = [ allE ; tempE ];
            tempE = [];


            load( leftEyebrowData ); 
            s = (size(testResult,1));
            for j = 1:size(testResult,2)
                [ Leyebrow(i+1,j), tempE1] = aveError(testResult(1:s/2,j),testResult(s/2+1:end,j)) ;
                tempE = [ tempE; tempE1];
            end
            allE = [ allE ; tempE ];
            tempE = [];


            load( rightEyebrowData ); 
            for j = 1:size(testResult,2)
                [ Reyebrow(i+1,j) , tempE1] = aveError(testResult(1:s/2,j),testResult(s/2+1:end,j)) ;
                tempE = [ tempE; tempE1];
            end
            allE = [ allE ; tempE ];
            tempE = [];


            %for nose
            load( noseDataFile ); 
            s = (size(testResult,1));
            for j = 1:size(testResult,2)
                [ Nose(i+1,j) , tempE1] = aveError(testResult(1:s/2,j),testResult(s/2+1:end,j)) ;
                tempE = [ tempE; tempE1];
            end
            allE = [ allE ; tempE ];
            tempE = [];


            %for mouth
            load( mouthDataFile ); 
            s = (size(testResult,1));
            for j = 1:size(testResult,2)
                [ Mouth(i+1,j) , tempE1] = aveError(testResult(1:s/2,j),testResult(s/2+1:end,j)) ;
                tempE = [ tempE; tempE1];
            end
            allE = [ allE ; tempE ];
            tempE = [];


            %for chin
            load( chinDataFile ); 
            s = (size(testResult,1));
            for j = 1:size(testResult,2)
                [ Chin(i+1,j) , tempE1] = aveError(testResult(1:s/2,j),testResult(s/2+1:end,j)) ;
                tempE = [ tempE; tempE1];
            end
            allE = [ allE ; tempE ];
            tempE = [];
        end

        AE = mean(  [ mean(Leye(:)),  mean(Reye(:)),  mean(Leyebrow(:)), ...
                mean(Reyebrow(:)),  mean(Nose(:)),  mean(Mouth(:)),  mean(Chin(:)) ]); 

        stdErr = sqrt(var( allE,1))/size(allE,1);
        variance =  var( allE,1);    


    end
else
    %they are averloaded vectors 
    v1 =  rootName;
    v2 = whole; 
    
    for i1 = 1:size(v1,2)
         [ AE, err] = aveError( v1(:,i1), v2(:,i1));
         
         allE = [ allE; err];
         
    end

    AE = mean(  allE,1); 
    stdErr = sqrt(var( allE,1))/size(allE,1);
    variance =  var( allE,1);  


    
end


