#!/bin/bash
#SBATCH -p testdlc_gpu-rtx2080 #bosch_cpu-cascadelake #,ml_gpu-rtx2080 #ml_gpu-rtx2080     # bosch_gpu-rtx2080    #alldlc_gpu-rtx2080     # partition (queue)
#SBATCH -o logs/%x.%A-%a.%N.out       # STDOUT  %A will be replaced by the SLURM_ARRAY_JOB_ID value
#SBATCH -e logs/%x.%A-%a.%N.err       # STDERR  %A will be replaced by the SLURM_ARRAY_JOB_ID value
#SBATCH -a 0-4 # array size
#SBATCH --mem=5G
#SBATCH --job-name="transbench101_micro-autoencoder-grad_norm"

echo "Workingdir: $PWD";
echo "Started at $(date)";
echo "Running job $SLURM_JOB_NAME using $SLURM_JOB_CPUS_PER_NODE cpus per node with given JID $SLURM_JOB_ID on queue $SLURM_JOB_PARTITION";

SCRIPT_DIR="/home/jhaa/NASLib/scripts/vscode_remote_debugging"
while read var value
do
    export "$var"="$value"
done < $SCRIPT_DIR/config.conf

searchspace=$1
dataset=$2
predictor=$3
start_seed=$4
experiment=$5

if [ -z "$searchspace" ]
then
    echo "Search space argument not provided"
    exit 1
fi

if [ -z "$dataset" ]
then
    echo "Dataset argument not provided"
    exit 1
fi

if [ -z "$predictor" ]
then
    echo "Predictor argument not provided"
    exit 1
fi

if [ -z "$start_seed" ]
then
    echo "Start seed not provided"
    exit 1
fi

if [ -z "$experiment" ]
then
    echo "experiment not provided"
    exit 1
fi

start=`date +%s`
test_id=0
# seed=$(($start_seed + ${SLURM_ARRAY_TASK_ID}))
seed=$(($start_seed + ${test_id}))
python -m debugpy --listen 0.0.0.0:$PORT --wait-for-client naslib/runners/zc/runner.py --config-file naslib/configs/${experiment}/${predictor}/${searchspace}-${start_seed}/${dataset}/config_${seed}.yaml
# python naslib/runners/zc/runner.py --config-file naslib/configs/${experiment}/${predictor}/${searchspace}-${start_seed}/${dataset}/config_${seed}.yaml
end=`date +%s`
runtime=$((end-start))

echo Runtime: $runtime
