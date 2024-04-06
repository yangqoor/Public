function getPNASJPG(YEAR)
if nargin < 1
    YEAR = 2023;
end
YEAR         = num2str(YEAR);
str_YEAR     = ['d',YEAR(1:3),'0','.y',YEAR];
options      = weboptions('Timeout',inf);
url_archive  = ['https://www.pnas.org/loi/pnas/group/',str_YEAR];
html_archive = webread(url_archive,options);
A_issue      = strfind(html_archive,'past-issue__content__item--all-details d-flex flex-column');
str_issue    = html_archive(A_issue(1)+50:A_issue(1)+100);
S1_issue     = strfind(str_issue,'|');
S2_issue     = strfind(str_issue,'</h2>');
str1_issue   = str_issue(S1_issue(1):S1_issue(2));
str2_issue   = str_issue(S1_issue(2):S2_issue);
num1_issue   = str2num(str1_issue(str1_issue>=48&str1_issue<=57));
num2_issue   = str2num(str2_issue(str2_issue>=48&str2_issue<=57));

ibegin = 1; jbegin = 1; kbegin = 1;
forderName=['Year_',num2str(YEAR)];
if exist(['.\image_',forderName,'\ijkbreak.mat'],'file')
    load(['.\image_',forderName,'\ijkbreak.mat']);
end
if ~exist(['.\image_',forderName],'dir')
    mkdir(['.\image_',forderName]);
end
disp([ibegin,jbegin,kbegin])

for i = ibegin:num2_issue
    url_issue  = ['https://www.pnas.org/toc/pnas/',num2str(num1_issue),'/',num2str(i)];
    html_issue = webread(url_issue,options);
    A_article  = strfind(html_issue,'Research Article');
    Z_article  = strfind(html_issue,'Recent Issues');
    html_issue = html_issue(A_article(1):Z_article(1));

    B_article  = strfind(html_issue,'icon-open-access');
    A_article  = strfind(html_issue,'text-reset animation-underline');
    Z_article  = strfind(html_issue,'title="');
    for j = jbegin:length(B_article)
        tA_article   = A_article(find(B_article(j)<A_article,1));
        url_article  = html_issue(tA_article:Z_article(find(Z_article>tA_article,1)));
        url_article  = url_article(39:end-3);
        url_article  = ['https://www.pnas.org',url_article]; 
        html_article = webread(url_article,options);

        A_JPG   = strfind(html_article,[url_article(find(url_article=='/',1,'last'):end),'/asset/']);
        Z_JPG   = strfind(html_article,'jpg" height=');

        for k = kbegin:length(A_JPG)
            try
            ibegin = i ; jbegin = j; kbegin = k;
            save(['.\image_',forderName,'\ijkbreak.mat'],'ibegin','jbegin','kbegin')
            url_JPG = ['https://www.pnas.org/cms/10.1073',html_article(A_JPG(k):Z_JPG(k)+2)];
            name_JPG = ['.\image_',forderName,'\',url_JPG(find(url_JPG=='/',1,'last')+1:end)];
            websave(name_JPG,url_JPG,options);
            disp(['Downloading Year-',YEAR,...
                 ' Issue-',num2str(i),' Artical-',num2str(j),...
                 ' Pic-',num2str(k),':',url_article(22:end)])
            catch
            end
        end
        kbegin = 1;
    end
    jbegin = 1;
end
end