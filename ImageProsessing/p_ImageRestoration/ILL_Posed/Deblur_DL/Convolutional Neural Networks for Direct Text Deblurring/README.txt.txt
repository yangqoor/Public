1) Open Command Prompt and change its directory to this folder using 'cd' command.
2) Create a new environment using the command given and the spec-file.txt libraries.
'conda create --name myenv --file spec-file.txt'
3) Then activate the environment by using anyone of these commands.
'conda activate myenv' or 'source activate myenv'
4) Then run our code using 'python train.py' if you want to train.
5) For testing run 'python inference.py'. You can change the path in the python file according to the image you want to see.
