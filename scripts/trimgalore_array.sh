#!/bin/bash

#SBATCH --partition=128x24               # Partition/queue to run on
#SBATCH --time=1-00:00:00                # Max time for job to run
#SBATCH --job-name=trimgalore            # Name for job (shows when running squeue)
#SBATCH --mail-type=ALL                  # Mail events(NONE,BEGIN,END,FAIL,ALL)
#SBATCH --mail-user=aanakamo@ucsc.edu    # Where to send mail
#SBATCH --ntasks=1                       # Number of tasks to run
#SBATCH --cpus-per-task=9                # Number of CPU cores to use per task
#SBATCH --nodes=1                        # Number of nodes to use
#SBATCH --mem=8G                         # Ammount of RAM to allocate for the task
#SBATCH --output=/hb/groups/kelley_lab/anne/slurm_out/slurm_%j.out            # Standard output and error log
#SBATCH --error=/hb/groups/kelley_lab/anne/slurm_out/slurm_%j.err             # Standard output and error log
#SBATCH --no-requeue                     # don't requeue the job upon NODE_FAIL
#SBATCH --array=[1-187]                  # array job

### for paralellizing each trim_galore run for SRA samples into a job array

cd /hb/groups/kelley_lab/anne/hibernation/trimgalore_out

LINE=$(sed -n "${SLURM_ARRAY_TASK_ID}"p ../data/transcriptomic/species_tissue_sra_state.txt)
species=$(echo ${LINE} | awk '{ print $1; }')
tissue=$(echo ${LINE} | awk '{ print $2; }')
sra_acc=$(echo ${LINE} | awk '{ print $3; }')
state=$(echo ${LINE} | awk '{ print $4; }')

echo "running trim_galore for sra sample: ${sra_acc} (${species}, ${tissue}, ${state})"

sra_path=../data/transcriptomic/${species}/${tissue}
mkdir -p ${species}/${tissue}/fastqc
mkdir -p ${species}/${tissue}/trimgalore

module load trimgalore

trim_galore --cores 2 --paired -q 20 --fastqc --fastqc_args "--nogroup --outdir ${species}/${tissue}/fastqc" \
            --stringency 5 --illumina --length 50 -o ${species}/${tissue}/trimgalore --clip_R1 8 --clip_R2 8 \
            ${sra_path}/${sra_acc}_pass_1.fastq ${sra_path}/${sra_acc}_pass_2.fastq

module unload trimgalore
