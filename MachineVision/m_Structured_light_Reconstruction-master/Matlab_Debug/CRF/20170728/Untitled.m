load total_belief_field1.mat
load belief_field/belief_field6_iter_1.mat
my_imshow(mask_mats{5, 1}, viewportMatrix, true, []);

h = 200 + 86 -1;
w = 600 + 121 -1;

ShowDepthFieldOnPoint(beliefField, w, h);
ShowDepthFieldOnPoint(total_belief_field{5, 1}, w, h);