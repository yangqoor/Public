function  plot_it(X,M,r,conn)

%subplot(2,1,1);
 cla;

 if size(X,2)>=3           
   plot3(X(:,1),X(:,2),X(:,3),'g.');
   hold on;
   plot3(M(:,1),M(:,2),M(:,3),'k+');
   hold on;
   gplot3(conn,M);
%    Mx = getframe(gca);
%    view(-10,5);
 elseif size(X,2) == 2 
   plot(X(:,1),X(:,2),'g.',M(:,1),M(:,2),'k.',M(:,1),M(:,2),'k+');
   hold on;
      h=ellipse(r,r,0,M(:,1),M(:,2));set(h,'Color',[0.8 0.8  1]);
   gplot(conn,M,'k-');
 end
        
 axis equal;
  
 drawnow;
    
