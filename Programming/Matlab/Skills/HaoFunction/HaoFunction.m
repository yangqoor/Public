function HaoFunction
h = figure('units','pixels','position',[10 50 410 485],'menubar','none','name',char([77,65,84,76,65,66,20989,25968,23383,20856]),'numbertitle','off','resize','off');
movegui(h,'center')
uicontrol('Parent',h,'Style','pushbutton','String',char([20351,29992,20171,32461]),'Position',[5,450,90,30],'callback',@DocFcn);
uicontrol('Parent',h,'Style','edit','String',char([20851,38190,35789,25628,32034]),'Position',[100,450,300,30],'callback',@SearchFcn);
table = uitable('Parent',h,'Position',[5 5 400 440],'ColumnEditable',false,'ColumnWidth',[{100},{280}],'ColumnName',[{char([20989,25968])},{char([35299,37322])}],'RowName',{},'CellSelectionCallback',@UITableCellSelection);
functioninfo = readcell('function.xlsx');
set(table,'data',functioninfo(:,1:2))
    function SearchFcn(varargin)
        keyword = varargin{1}.Parent.Children(2).String;
        id = contains(functioninfo,keyword);
        [idx,~] = find(id == 1);
        varargin{1}.Parent.Children(1).Data = functioninfo(idx,:);
    end
    function DocFcn(varargin)
        global CellId
        functionname = varargin{1}.Parent.Children(1).Data{CellId(1,1),1};
        eval(['doc ',functionname])
    end
    function UITableCellSelection(~, event)
        global CellId
        CellId = event.Indices;
    end
end