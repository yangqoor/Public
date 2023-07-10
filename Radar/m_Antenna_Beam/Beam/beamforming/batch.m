make_rp;



rp.TNRdB = 10; rp.INRdB = 20; rp.Nsnaps= 20; rp.mu = 1e-9; rp.color='r'; rp.name = 'run1';
run_lms_mvdr(rp);
rp.TNRdB = 10; rp.INRdB = 20; rp.Nsnaps= 100; rp.mu = 1e-9;  rp.color='g'; rp.name = 'run2';
run_lms_mvdr(rp);
rp.TNRdB = 10; rp.INRdB = 20; rp.Nsnaps= 200; rp.mu = 1e-9; rp.color='b';  rp.name = 'run3';
run_lms_mvdr(rp);



rp.TNRdB = 10; rp.INRdB = 20; rp.Nsnaps= 200; rp.mu = 1e-8;  rp.color='r';rp.name = 'run4';
run_lms_mvdr(rp);
rp.TNRdB = 10; rp.INRdB = 20; rp.Nsnaps= 200; rp.mu = 1e-9;  rp.color='g';  rp.name = 'run5';
run_lms_mvdr(rp);
rp.TNRdB = 10; rp.INRdB = 20; rp.Nsnaps= 200; rp.mu = 1e-10; rp.color='b';  rp.name = 'run6';
run_lms_mvdr(rp);




rp.TNRdB = 10; rp.INRdB = 10; rp.Nsnaps= 200; rp.mu = 1e-9; rp.color='r';  rp.name = 'run7';
run_lms_mvdr(rp);
rp.TNRdB = 10; rp.INRdB = 20; rp.Nsnaps= 200; rp.mu = 1e-9;  rp.color='g';  rp.name = 'run8';
run_lms_mvdr(rp);
rp.TNRdB = 10; rp.INRdB = 30; rp.Nsnaps= 200; rp.mu = 1e-9; rp.color='b'; rp.name = 'run9';
run_lms_mvdr(rp);



