%THIS EXAMPLE IS FOR SUBMITTING A SCRIPT FROM A REMOTE CLIENT SESSION TO
%RUN ON THE OSC OAKLEY CLUSTER.  THE SCRIPT MAY CONTAIN PARFOR LOOPS.

%See https://www.osc.edu/documentation/howto/configuring_pct for more
%information.

%IMPORTANT: This script should be run in your MATLAB client session. Do NOT
%submit it to the cluster using the batch command. You may wish to just
%copy lines out of this script and paste them into your MATLAB command
%window instead of running the entire script.

%Prerequisite: You should already have configured the cluster profile in your
%client and set your MATLAB path appropriately.

%This example runs the script "eigtest" on the cluster. It is located in
%OSCMatlabPCT/PCTtestfiles/eigtest.m.

%Initialize cluster object using the appropriate profile for your situation
intelCluster = parcluster('genericNonSharedOakleyIntel_R2014a');

%Submit the job. All file dependencies must be on the path or in your
%current working directory. This job script is "eigtest"; it will run with 
%up to 11 workers. It's important to note that the number of processors
%requested on the cluster is one more than the number of workers. This
%job will request 12 processors (one node on Oakley); if you request 12
%workers, your job will require two Oakley nodes.
%NOTE: Fill in the CurrentFolder value with the path to your home directory.
%jobObject=batch(intelCluster,'eigtest','Pool',11,'CurrentFolder', '/nfs/00/username');
jobObject=batch(intelCluster,'eigtest','Pool',11,'CurrentFolder', '/nfs/15/uda0235');
%At this point you will be prompted for your OSC user name and password.
%Answer "no" to the key file question.
%If you want to attach files to your submission, use the following form:
%jobObject = batch(intelCluster, 'mytestscript','Pool',12,'AttachedFiles',{'file1','file2','etc'});

%Wait until the job has been successfully queued. This step is optional.
wait(jobObject,'queued')

%Return a success message that includes the OSC Job ID and the index of the
%job within the MDCS (used to access the job object later).
matlabJobIndex = intelCluster.Jobs(end).ID;
oscJobID = intelCluster.getJobClusterData(jobObject).ClusterJobIDs{1};
fprintf('Your job has been submitted with OSC JobID: %s\nThe MDCS job index is %d\n', oscJobID, matlabJobIndex);

%Wait for the job to complete. The wait command is optional. You can also
%monitor your job on the cluster using qstat.
wait(jobObject)

%Retrieve the workspace from your job.
%THIS WORKS ONLY FOR ENTRY SCRIPTS. USE fetchOutputs FOR FUNCTIONS
%NOTE: Jobs with outputs over 2GB cannot fetch data in this manner,
%and load will return "index out of %range" error, due to the cluster not
%being able to save the workspace upon job completion.  Please manually 
%save your large data into a v7.3 MAT file outside the MATLAB working
%directory using the save command in your entry function.
load(jobObject)

%Submitting multiple jobs: You may modify this script to submit a sequence
%of jobs. The following is valid.
%jobObject=batch(intelCluster,'eigtest1','Pool',11,'CurrentFolder', '/nfs/00/username');
%jobObject=batch(intelCluster,'eigtest2','Pool',11,'CurrentFolder', '/nfs/00/username');
%jobObject=batch(intelCluster,'eigtest3','Pool',11,'CurrentFolder', '/nfs/00/username');
%jobObject=batch(intelCluster,'eigtest4','Pool',11,'CurrentFolder', '/nfs/00/username');
%In this example you are replacing the value of jobObject with each new job
%submitted. See the script reconnect_client_session.m for commands to get
%the jobObject values back.
