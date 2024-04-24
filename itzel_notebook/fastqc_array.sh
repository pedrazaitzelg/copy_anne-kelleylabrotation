#!/bin/bash

#SBATCH --partition=128x24               # Partition/queue to run on
#SBATCH --time=1-00:00:00                # Max time for job to run
#SBATCH --job-name=fastqc                # Name for job (shows when running squeue)
#SBATCH --mail-type=ALL                  # Mail events(NONE,BEGIN,END,FAIL,ALL)
#SBATCH --mail-user=igpedraz@ucsc.edu    # Where to send mail
#SBATCH --output=fastqc.err
#SBATCH --error=fastqc.err
#SBATCH --ntasks=1                       # Number of tasks to run
#SBATCH --cpus-per-task=8                # Number of CPU cores to use per task
#SBATCH --nodes=1                        # Number of nodes to use
#SBATCH --mem=10G                        # Ammount of RAM to allocate for the task
#SBATCH --output=slurm_%j.out            # Standard output and error log
#SBATCH --error=slurm_%j.err             # Standard output and error log
#SBATCH --no-requeue                     # don't requeue the job upon NODE_FAIL
#SBATCH --array=[1-11]                  # array job - refers to number of lines on txt file

### for paralellizing each fastqc run for SRA samples into a job array

cd /hb/groups/kelley_training/itzel/data/transcriptomic/fastqc_out

module load  fastqc

LINE=$(sed -n "${SLURM_ARRAY_TASK_ID}"p ../data/transcriptomic/species_tissue_sra_state.txt)
species=$(echo ${LINE} | awk '{ print $1; }')
tissue=$(echo ${LINE} | awk '{ print $2; }')
sra_acc=$(echo ${LINE} | awk '{ print $3; }')
state=$(echo ${LINE} | awk '{ print $4; }')

echo "running fastqc for sra sample: ${sra_acc} (${species}, ${tissue}, ${state})"

sra_path=../${species}/${tissue}
mkdir -p ${species}/${tissue}

fastqc -t 8 --outdir ${species}/${tissue} --extract ${sra_path}/${sra_acc}_pass_1.fastq.gz ${sra_path}/${sra_acc}_pass_2.fastq.gz
