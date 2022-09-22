#!/bin/bash
#SBATCH --job-name=me_R
#SBATCH --ntasks=1
#SBATCH --nodes=1             
#SBATCH --mem=1gb                    
#SBATCH --time=00:03:00   
#SBATCH --partition=windfall
#SBATCH --account=windfall

module load python/3.9/3.9.10

python3 my_python_script.py
