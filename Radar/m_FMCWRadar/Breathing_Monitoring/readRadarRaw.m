function [bI_st,bQ_st] = readRadarRaw(folderName,measurement)

switch measurement
        % Proband_1.0.0
    case '1.1', filename = '20191120T122632.6722028_1';
    case '1.2', filename = '20191121T123707.8896805_1';
    case '1.3', filename = '20191122T122923.3777715_1';
        % Proband_2.1.0
    case '2.1', filename = '20191120T131717.1086334_1';
    case '2.2', filename = '20191121T131532.5819625_1';
    case '2.3', filename = '20191122T130358.6712441_1';
        % Proband_3.0.1
    case '3.1', filename = '20191127T115656.1374257_1';
    case '3.2', filename = '20191128T124343.4409922_1';
    case '3.3', filename = '20191129T122744.8856478_1';
        % Proband_4.0.1
    case '4.1', filename = '20191129T131320.0818421_1';
    case '4.2', filename = '20191202T121559.9456583_1';
    case '4.3', filename = '20191203T121222.2758503_1';
        % Proband_5.0.0
    case '5.1', filename = '20191203T130234.5132236_1';
    case '5.2', filename = '20191204T121304.7997448_1';
    case '5.3', filename = '20191205T121522.4414096_1';
        % Proband_6.0.0
    case '6.1', filename = '20191203T134458.1434142_1';
    case '6.2', filename = '20191204T125408.4225468_1';
    case '6.3', filename = '20191205T125503.7694909_1';
        % Proband_7.0.1
    case '7.1', filename = '20191210T131043.0243695_1';
    case '7.2', filename = '20191211T121818.8779724_1';
    case '7.3', filename = '20191212T121224.9057437_1';
        % Proband_8.1.1
    case '8.1', filename = '20191210T122823.3108886_1';
    case '8.2', filename = '20191211T125350.6499072_1';
    case '8.3', filename = '20191212T124837.0841098_1';
        % Proband_9.0.0
    case '9.1', filename = '20191212T133215.9436564_1';
    case '9.2', filename = '20191213T124658.6486329_1';
    case '9.3', filename = '20191216T131729.2892346_1';
        % Proband_10.1.0
    case '10.1', filename = '20200109T122737.1167572_1';
    case '10.2', filename = '20200110T122027.9850530_1';
    case '10.3', disp('Record issue: no radar file available...'); keyboard
        % Proband_11.0.0
    case '11.2', filename = '20200114T125036.6626953_1';
    case '11.1', filename = '20200113T125426.4708101_1';
    case '11.3', filename = '20200115T124959.8181414_1';
        % Proband_12.0.1
    case '12.1', filename = '20200113T133613.4971846_1';
    case '12.2', filename = '20200114T120919.2159340_1';
    case '12.3', filename = '20200115T121155.2635871_1';
        
    otherwise
        disp('Wrong measurement number...')
        keyboard
end
    
dbfilename = [filename '.csv'];
rawdata = readmatrix([folderName, filesep, dbfilename]);
bI_st = rawdata(:, 11)';
bQ_st = rawdata(:, 12)';
    
end