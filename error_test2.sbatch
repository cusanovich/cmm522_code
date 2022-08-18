#!/bin/bash
#SBATCH --job-name=errtest2
#SBATCH --ntasks=1
#SBATCH --nodes=1             
#SBATCH --mem=100mb                    
#SBATCH --time=00:01:00   
#SBATCH --partition=windfall
#SBATCH --account=windfall

cd ~/
ls ccbb_projects/ latest_nature_paper/ > ccbb_projects/error_test.out 2> ccbb_projects/error_test.log

