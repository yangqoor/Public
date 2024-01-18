
disp('------ In compile_mex ---------------');

addpath('./C_code');

disp('Creating ENN_matching...');
%mex OPTIMFLAGS="/Ox /Oi /Oy /DNDEBUG /fp:fast /arch:SSE2 /DMEX_MODE /openmp" -inline ./C_code/TreeCANN.cpp ./C_code/ENN_matching_mex.cpp -output ./C_code/ENN_matching
mex OPTIMFLAGS="/Ox /Oi /Oy /DNDEBUG /fp:fast /arch:SSE2 /DMEX_MODE /openmp"  ./C_code/TreeCANN.cpp ./C_code/ENN_matching_mex.cpp -output ./C_code/ENN_matching

disp('Creating TreeCANN_extract_patches...');
%mex OPTIMFLAGS="/Ox /Oi /Oy /DNDEBUG /fp:fast /arch:SSE2 /DMEX_MODE /openmp" -inline ./C_code/TreeCANN.cpp ./C_code/TreeCANN_reduce_patches_mex.cpp -output ./C_code/TreeCANN_reduce_patches
mex OPTIMFLAGS="/Ox /Oi /Oy /DNDEBUG /fp:fast /arch:SSE2 /DMEX_MODE /openmp"  ./C_code/TreeCANN.cpp ./C_code/ENN_matching_mex.cpp -output ./C_code/ENN_matching

disp('Creating TreeCANN_propagation_stage...');
%mex OPTIMFLAGS="/Ox /Oi /Oy /DNDEBUG /fp:fast /arch:SSE2 /DMEX_MODE /openmp" -inline ./C_code/TreeCANN.cpp ./C_code/TreeCANN_propagation_stage_mex.cpp -output ./C_code/TreeCANN_propagation_stage
mex OPTIMFLAGS="/Ox /Oi /Oy /DNDEBUG /fp:fast /arch:SSE2 /DMEX_MODE /openmp"  ./C_code/TreeCANN.cpp ./C_code/TreeCANN_propagation_stage_mex.cpp -output ./C_code/TreeCANN_propagation_stage

disp('3 new mex files should now appear under the ./C_code/ directory)');
