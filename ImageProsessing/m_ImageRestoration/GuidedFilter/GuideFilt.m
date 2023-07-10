function [q]=GuideFilt(guide,src,regular,radius)
%guideµ¼ÏòÍ¼¡£srcÔ­Í¼¡£radiusÂË²¨°ë¾¶
GuideMean=meanfilt(guide,radius);
srcMean=meanfilt(src,radius);
Guidecorr=meanfilt(guide.*guide,radius);
SGcorr=meanfilt(guide.*src,radius);

GuideVar=Guidecorr-GuideMean.*GuideMean;
SGcov=SGcorr-GuideMean.*srcMean;

a=SGcov./(GuideVar+regular);
b=srcMean-a.*GuideMean;

amean=meanfilt(a,radius);
bmean=meanfilt(b,radius);

q=amean.*guide+bmean;