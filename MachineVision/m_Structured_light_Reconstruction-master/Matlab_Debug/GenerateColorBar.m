% set color bar
my_colorbar = zeros(64, 1, 3);
color_map = colormap;
my_colorbar(:,:,1) = color_map(:,1);
my_colorbar(:,:,2) = color_map(:,2);
my_colorbar(:,:,3) = color_map(:,3);
save my_colorbar
% for i = 1:360
%     h_i = floor(i / 60);
%     f = i / 60 - h_i;
%     v = 1;
%     s = 1;
%     p = v * (1 - s);
%     q = v * (1 - f * s);
%     t = v * (1 - (1 - f) * s);
%     r = 0;
%     g = 0;
%     b = 0;
%     switch h_i
%         case 0
%             r = v;
%             g = t;
%             b = p;
%         case 1
%             r = q;
%             g = v;
%             b = p;
%         case 2
%             r = p;
%             g = v;
%             b = t;
%         case 3
%             r = p;
%             g = q;
%             b = v;
%         case 4
%             r = t;
%             g = p;
%             b = v;
%         case 5
%             r = v;
%             g = p;
%             b = q;
%         otherwise
%             fprint('Error\n')
%     end
%     
% end