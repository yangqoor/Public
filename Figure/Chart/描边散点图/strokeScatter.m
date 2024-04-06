function stHdl = strokeScatter(varargin)
    set(gca,'NextPlot','add');
    scHdl = scatter(varargin{:});
    stHdl = scatter(varargin{:},'MarkerEdgeColor','none');
    scHdl.Annotation.LegendInformation.IconDisplayStyle='off';
end