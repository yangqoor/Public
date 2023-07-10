myObj = VideoWriter('newfile.avi');
myObj.FrameRate = 1;
open(myObj);
hf = figure(1);
for k = 1:1:num_frames_gen
scatter3(a_X_test_out_norm(k,1),a_X_test_out_norm(k,2),a_X_test_out_norm(k,3),'r','filled')
hold on;
scatter3(a_X_test_out_rec(k,1),a_X_test_out_rec(k,2),a_X_test_out_rec(k,3),'b')
% plot3(k,a_X_seq_clusters_test_norm(k,1),a_X_seq_clusters_test_norm(k,2),'r');
% hold on;
% plot3(k,a_X_seq_clusters_test_rec(k,1),a_X_seq_clusters_test_rec(k,2),'b');

%axis([-2 2 -2 2 -2 2]);
frame = getframe(hf);
writeVideo(myObj,frame.cdata);
end
close(myObj)

% figure(2);
% plot3(1:1:num_frames_gen,a_X_seq_clusters_test_norm(:,1),a_X_seq_clusters_test_norm(:,2),'r');
% hold on;
% plot3(1:1:num_frames_gen,a_X_seq_clusters_test_rec(:,1),a_X_seq_clusters_test_rec(:,2),'b');

% Computes the error between the reconstructed value and the original data
% this statistic does not tell about the similarity of the structure of the
% generated sequence and true sequence
% For a CRBM of action 2, action 4,5,6 gives low normalized value mainly
% because of less number of frames to generate,
% We need to find a better statistic which tells us how close the generated
% sequence is to the true sequence
% Maybe the variance/influenceof each codeword in each action space can be
% considered
% visually, sequences from action 4,5,6 have large differences between the
% generated and true sequence when applied on CRBM of action 2.
val = sum(sum( (a_X_test_out_norm - a_X_test_out_rec).^2 ))/num_frames_gen;
err = (a_X_test_out_norm - a_X_test_out_rec).^2;
figure(2);
plot(err);
disp(val);