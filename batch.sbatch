#!/bin/bash
#SBATCH --job-name=Sample_Slurm_Job
#SBATCH --ntasks=1
#SBATCH --nodes=1
#SBATCH --mem=1gb
#SBATCH --time=00:03:00
#SBATCH --partition=windfall
#SBATCH --account=windfall

pwd > out.txt
hostname >> out.txt
date >> out.txt
sleep 2m

