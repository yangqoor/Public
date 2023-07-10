function [referenceRaw,referenceFrequency] = readReferenceData(folderName,measurement)
    
switch measurement
        % Proband_1.0.0
    case '1.1', filename = '1.0.0.62.4.1_L20112019_131955';
    case '1.2', disp('Record issue: no reference file available...'); keyboard
    case '1.3', filename = '1.0.0.64.4.3_L22112019_122837';
        % Proband_2.1.0
    case '2.1', filename = '2.1.0.62.4.1+2_L20112019_140909';
    case '2.2', filename = '2.1.0.63.4.3_L21112019_141254';
    case '2.3', filename = '2.1.0.64.4.4_L22112019_130316';
        % Proband_3.0.1
    case '3.1',  filename = '3.0.1.9.0.1_L27112019_114941';
    case '3.2', disp('Record issue: no reference file available...'); keyboard
    case '3.3', filename = '3.0.1.11.0.4_L29112019_122702';
        % Proband_4.0.1
    case '4.1',  filename = '4.0.1.7.0.1_L29112019_131242';
    case '4.2', filename = '4.0.1.10.0.2_L02122019_121513';
    case '4.3', filename = '4.0.1.11.0.3_L03122019_121139';
        % Proband_5.0.0
    case '5.1', filename = '5.0.0.90.0.1_L03122019_130152';
    case '5.2', filename = '5.0.0.91.0.2_L04122019_121101';
    case '5.3', filename = '5.0.0.92.0.3_L05122019_121432';
        % Proband_6.0.0
    case '6.1', filename = '6.0.0.90.0.1_L03122019_134416';
    case '6.2', filename = '6.0.0.91.0.2_L04122019_125326';
    case '6.3', filename = '6.0.0.92.0.3_L05122019_125426';
        % Proband_7.0.1
    case '7.1', filename = '7.0.1.13.0.1_L10122019_131005';
    case '7.2', filename = '7.0.1.14.0.2_L11122019_121730';
    case '7.3', filename = '7.0.1.15.0.3_L12122019_121140';
        % Proband_8.1.1
    case '8.1', filename = '8.1.1.13.0.1_L10122019_122723';
    case '8.2', filename = '8.1.1.14.0.2_L11122019_125307';
    case '8.3', filename = '8.1.1.15.0.3_L12122019_124759';
        % Proband_9.0.0
    case '9.1', filename = '9.0.0.16.0.1_L12122019_133139';
    case '9.2', filename = '9.0.0.17.0.2_L13122019_124613';
    case '9.3', filename = '9.0.0.20.0.03_L16122019_131640';
        % Proband_10.1.0
    case '10.1', filename = '10.1.0.48.0.1_L09012020_122632';
    case '10.2', filename = '10.1.0.49.0.2_L10012020_121724';
    case '10.3', filename = '10.1.0.52.0.3_L13012020_120845';
        % Proband_11.0.0
    case '11.2', filename = '11.0.0.52.0.2_L14012020_124939';
    case '11.1', filename = '11.0.0.51.0.1_L13012020_125328';
    case '11.3', filename = '11.0.0.53.0.3_L15012020_124843';
        % Proband_12.0.1
    case '12.1', filename = '12.0.1.27.0.1_L13012020_133515';
    case '12.2', filename = '12.0.1.28.0.2_L14012020_120813';
    case '12.3', filename = '12.0.1.29.0.3_L15012020_121051';
            
    otherwise
        disp('Wrong measurement number...')
        keyboard
end

dbfilename = [folderName filename];
[record,~] = edfread([dbfilename '.edf']);

referenceRaw = cell2mat(record{:,2});
referenceFrequency = record{:,9};

end