function prob=set_sizes(prob)
 
 prob.k_sz1=size(prob.k,1); 
 prob.k_sz2=size(prob.k,2);
 prob.k_sz=prob.k_sz1*prob.k_sz2;
 prob.y_sz1=size(prob.y,1);
 prob.y_sz2=size(prob.y,2);
 prob.y_sz=prob.y_sz2*prob.y_sz1;
    