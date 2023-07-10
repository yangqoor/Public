%% Functions from "http://dragonwood-blastevil.blogspot.com/2013/04/read-viper-data-into-matlab.html"
function BB = parseStr(str)

    dq = strfind(str, '"'); % double quote locations
    bn = strfind(str, ')'); % brace number
    if ( length(dq) / 2 ~= length(bn) )
        error('dq should be equal to 2 * bn');
    end
    BB = [];
    for i = 1 : length(bn)
        tmpBB = parseOneSeg(str( dq( (i-1) * 2 + 1) + 1 : bn(i) - 1) );
        BB = cat(1, BB, tmpBB);
    end

end

function tmpBB = parseOneSeg(str)
    dq = strfind(str, '"');
    BB = parseBB(str(1 : dq - 1) );

    strNum = str2num( str( strfind(str, '[') + 1 : strfind(str, ',') - 1) );
    endNum = str2num( str( strfind(str, ', ') + 2 : length(str) ) );
    tmpBB = repmat(BB, endNum - strNum, 1);
end

function BB = parseBB(str)
    BB = zeros(1, 4);
    sp = strfind(str, ' '); % space location
    sp = [0 sp length(str)+1];
    for i = 1 : 4
        BB(i) = str2num( str( sp(i)+1 : sp(i+1) - 1) );
    end
end