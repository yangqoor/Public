clc;clear

list1 = dir('.\');

for i = 5:length(list1)
    if list1(i).isdir
        path1 = [list1(i).folder '\' list1(i).name '\'];
        list2 = dir(path1);
        
        for j = 3:length(list2)
            if list2(j).isdir
                path2 = [list2(j).folder '\' list2(j).name '\'];
                list3 = dir(path2);
                
                for k = 3:length(list3)
                    if list3(k).isdir
                        path3 = [list3(k).folder '\' list3(k).name];

                        switch list2(j).name
                            case 'Matlab'
                                path2_n = [list2(j).folder '\m_' list3(k).name '\'];
                                status1 = movefile(path3, path2_n);
                            case 'Python'
                                path2_n = [list2(j).folder '\p_' list3(k).name '\'];
                                status1 = movefile(path3, path2_n);
                            case 'C++'
                                path2_n = [list2(j).folder '\c_' list3(k).name '\'];
                                status1 = movefile(path3, path2_n);
                            case 'c#'
                                path2_n = [list2(j).folder '\c#_' list3(k).name '\'];
                                status1 = movefile(path3, path2_n);
                        end
                    end
                end
                status2 = rmdir(path2);
            end
        end

    end
end