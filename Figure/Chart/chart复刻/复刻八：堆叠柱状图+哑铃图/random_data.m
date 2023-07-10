rng(1)
% random data
Name={'Serranidae','Zoarcidae','Myctophidae','Sebastidae','Liparidae','Carangidae','Scombridae','Psychrolutidae',...
      'Notothenioid','Macrouridae','Soleidae','Pleuronectidae','Paralichthyidae','Sternoptychidae','Ophidiidae',...
      'Lutjanidae','Sparidae','Moridae','Monacanthidae','Agonidae','Triglidae','Platycephalidae','Ophichthidae',...
      'Antennariidae','Holocentridae','Bothidae','Chaerodontidae','Clupeidae','Tetraodontidae','Nemipteridae',...
      'Muraenidae','Mullidae','Lethrinidae','Balistidae','Stomiidae','Exocoetidae','Acanthuridae','Sciaenidae',...
      'Syngnathidae','Pomacanthidae','Haemulidae','Blenniidae','Apogonidae','Pomacentridae','Cobiidae','Labridae'}.';
N=size(Name,1);
RatioData=rand(N,3);
RatioData=RatioData./sum(RatioData,2);
%
Shallow=RatioData(:,1);
Deep=RatioData(:,2);
Intermediate=RatioData(:,3);
%
Median=rand(N,1).*40;
High=Median+rand(N,1).*20;
Low=Median-rand(N,1).*20;
Low(Low<0)=0;
%
Exact=rand(N,1).*50-25+Median;
Exact(Exact<0)=0;
% 
T=table(Name,Shallow,Deep,Intermediate,Median,Low,High,Exact)
writetable(T,'ta_results_revisions_data.csv')

% 46×8 table
% 
%         Name            Shallow        Deep      Intermediate    Median     Low       High      Exact 
%   _________________    __________    ________    ____________    ______    ______    ______    _______
% 
%   {'Serranidae'   }       0.23487     0.51173        0.2534      34.542    25.344    39.748      19.47
%   {'Zoarcidae'    }       0.45237     0.18439       0.36324      29.885    18.958     45.98      26.22
%   {'Myctophidae'  }    0.00016433     0.41345       0.58638       22.25    6.2775    26.118     14.417
%   {'Sebastidae'   }       0.45166     0.19425       0.35409      5.4582         0    18.247      20.34
%   {'Liparidae'    }       0.13722    0.018108       0.84467      2.3967         0     12.89     21.397
% 
%           :                :            :             :            :         :         :          :   
% 
%   {'Blenniidae'   }       0.43205     0.55718      0.010768      14.803    8.4557    33.606    0.21309
%   {'Apogonidae'   }       0.16076      0.3803       0.45894      25.189     12.75    36.829      12.59
%   {'Pomacentridae'}       0.48011     0.37817       0.14172       8.407         0    25.984     25.991
%   {'Cobiidae'     }        0.1007     0.11194       0.78736       30.11    10.634    47.005     25.903
%   {'Labridae'     }       0.25089     0.53185       0.21726      2.6615         0    20.769     8.4957











