X=[1 3 0.5 2.5 2];
explode=[0 1 0 5 0];

SP=shadowPie(X,explode,'ShadowType',{'/','.','|','+','x'});
SP=SP.draw(); 