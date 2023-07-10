function [xOpt,fval] = psorunhybridfcn(fitnessfcn,xOpt,...
    Aineq,bineq,Aeq,beq,LB,UB,nonlcon,options)

if iscell(options.HybridFcn)
    HybridFcn = options.HybridFcn{1} ;
    hybridOptions = options.HybridFcn{2} ;
else
    HybridFcn = options.HybridFcn ;
    hybridOptions = optimset('LargeScale','off') ;
end


fprintf('\nBest point before hybrid function: %s',...
    mat2str(xOpt,5))
fprintf('\n\nTurning over to hybrid function %s...\n\n',...
    func2str(HybridFcn))

if exist(func2str(HybridFcn),'file') ~= 2
    warning('pso:hybridfcn:nofile',...
        'Hybrid function %s cannot be found. Check toolboxes.',...
        func2str(HybridFcn))
    fval = fitnessfcn(xOpt) ;
    return
end

% Check for constraints
if strcmp(func2str(HybridFcn),func2str(@fmincon)) && ...
        all([isempty([Aineq,bineq]), isempty([Aeq,beq]), ...
        isempty([LB;UB]),isempty(nonlcon)])
    msg = sprintf('Warning: %s does not accept problems without any',...
        func2str(HybridFcn)) ;
    fprintf('%s constraints. Switching to fminunc.\n\n',msg)
    HybridFcn = @fminunc ;
elseif (strcmp(func2str(HybridFcn),func2str(@fminunc)) || ...
        strcmp(func2str(HybridFcn),func2str(@fminsearch))) && ...
        ~all([isempty([Aineq,bineq]), isempty([Aeq,beq]), ...
        isempty([LB;UB]),isempty(nonlcon)])
    msg = sprintf('Warning: %s does not accept problems with',...
        func2str(HybridFcn)) ;
    fprintf(0,'%s constraints. Switching to fmincon.\n\n',msg)
    HybridFcn = @fmincon ;
end

if strcmp(func2str(HybridFcn),func2str(@fmincon)) || ...
        strcmp(func2str(HybridFcn),func2str(@patternsearch))
    [xOpt,fval] = HybridFcn(fitnessfcn,xOpt,Aineq,bineq,...
        Aeq,beq,LB,UB,nonlcon,hybridOptions) ;
elseif strcmp(func2str(HybridFcn),func2str(@fminunc)) || ...
        strcmp(func2str(HybridFcn),func2str(@fminsearch))
    [xOpt,fval] = HybridFcn(fitnessfcn,xOpt,hybridOptions) ;
else
    warning('pso:hybridfcn:unrecognized',...
        'Unrecognized hybrid function. Ignoring for now.')
end