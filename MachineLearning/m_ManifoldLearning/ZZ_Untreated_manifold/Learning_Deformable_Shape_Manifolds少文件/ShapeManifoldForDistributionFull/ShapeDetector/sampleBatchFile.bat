#PBS -l walltime=160:00:00
#PBS -N fullTrain
#PBS -l mem=15GB
#PBS -j oe

#PBS -l nodes=1:ppn=4
set -x

module load matlab
module load matlab_osu_license

cd FabianData
matlab -r runFabianPositive
exit