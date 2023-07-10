echo off;	
fprintf('Adding directories to path ... ');
addpath(pwd);
addpath([pwd '/conformal3']);
addpath([pwd '/helperfunctions']);
fprintf(' done\n');

fprintf('Compiling c functions ... \n');
mexall
cd conformal3
mexall
cd ..
cd helperfunctions
mexall
cd ..

if(exist('./minimize.m')~=2)
 fprintf('\n\n\nWe ran into a little fixable problem!!');
 fprintf('It appears that you have not installed minimize.m\n');
 fprintf('Attempting to download it from http://www.kyb.tuebingen.mpg.de/bs/people/carl/code/minimize.old/minimize.m\n');
 fprintf('If that does not work please install file manually in current directory.\nThanks a bunch.\n\n');
 ret=dos('curl http://www.kyb.tuebingen.mpg.de/bs/people/carl/code/minimize.old/minimize.m > minimize.m');
 if(ret==0 || dos('wget http://www.kyb.tuebingen.mpg.de/bs/people/carl/code/minimize.old/minimize.m')==0)
  fprintf('Well, that seemed to have worked!\nConsider the problem fixed!\n');
 end;
end;

if(isempty(which('sedumi')))
 fprintf('We ran into a fixable problem!!'); 
 fprintf('It appears that SeDuMi is not installed or not in the path.\n');
 fprintf('fastmvu requires SeDuMi to be in the path.\n');
end;

fprintf('\n\nInstallation complete!\nTo test the code, please execute uscitiesDemo.m.\nHave a nice day and good luck with your research.\n');

