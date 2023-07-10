function dShowCorrespondence(Img_c, Img_p, pos_c, pos_p)
    if size(pos_c, 1) == 3
        pos_c = pos_c / pos_c(3);
    end
    if size(pos_p, 1) == 3
        pos_p = pos_p / pos_p(3);
    end
    show_Img_c = Img_c(pos_c(1)-10:pos_c(1)+10, pos_c(2)-10:pos_c(2)+10);
    show_Pattern =Img_p(pos_p(1)-10:pos_p(1)+10, pos_p(2)-10:pos_p(2)+10);
    figure(1)
    imshow([show_Img_c;show_Pattern]);
end