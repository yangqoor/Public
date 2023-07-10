function my_closereq
global comein;

if comein==2,
    %Function to close the window
    selection = questdlg(['Exiting Now?'],...
                         ['Close ' get(gcf,'Name')],...
                          'Yes','No','No');
    switch selection,
        case 'Yes',
            delete(gcf);
        case 'No'
            return
    end
else
    delete(gcf);
end