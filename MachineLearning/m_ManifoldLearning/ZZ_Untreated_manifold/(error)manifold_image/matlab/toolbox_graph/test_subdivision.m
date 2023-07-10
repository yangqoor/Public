% Test of subdivision schemes.
%
%   Copyright (c) 2005 Gabriel Peyré

mesh_types = {'tetra','oct','ico'};
nmesh = length(mesh_types);
nsub = 3;
clf;
for i=1:nmesh
    mesh_type = mesh_types{i};
    mesh_name = mesh_type;
    [vertex,face] = gen_base_mesh(mesh_type);
    if i==1
        vertex = vertex*compute_rotation([0,1,0], -pi/2)';
        face = reverse_orientation(face);
    end
    if i==2
        vertex = vertex*compute_rotation([1,0,0], pi/8)';
        face = reverse_orientation(face);
    end
    for s=0:nsub
        subplot(nmesh,nsub+1,s+1+(nsub+1)*(i-1));
        plot_mesh(vertex,face);
        lighting flat;
        if i==1
            str = sprintf('Subdivision %d', s);
            title(str);
        end
        if s==0
            if strcmp(lang,'eng')==1
                ylabel( mesh_name );
            else
                ylabel( mesh_name );
            end
            set(get(gca,'YLabel'),'Visible','On');
        end
        if s~=nsub     
            [vertex,face] = subdivide_sphere(vertex,face);
        end
    end
end
    