#! /bin/bash
# ====================================
#SBATCH --job-name=process_single_direc
#SBATCH --cpus-per-task=1
#SBATCH --mem=4GB
#SBATCH --time=0-00:29
#SBATCH --output=./slurm_output/direc_%j.out
#SBATCH --mail-user=aayush.kapur@mail.mcgill.ca
#SBATCH --mail-type=ALL
#SBATCH --account=def-hiroshi
# ====================================

# if [$# -eq 0]; then
#     echo "Usage: $0 <input_argument>"
#     exit 1
# fi

# input_arg=$1

source /home/kapmcgil/projects/def-hiroshi/kapmcgil/.csvkit/bin/activate
cd /home/kapmcgil/projects/def-hiroshi/kapmcgil/cp-parallel

# Launch python job
# (time python cp_calculate.py "/lustre03/project/6008063/neurohub/UKB/Bulk/90004" "$input_arg" "/home/kapmcgil/projects/def-hiroshi/kapmcgil/cp-parallel/outputs") 2>&1 | tee -a /home/kapmcgil/projects/def-hiroshi/kapmcgil/cp-parallel/logs/"$input_arg".txt

(time python cp_calculate.py "/lustre03/project/6008063/neurohub/UKB/Bulk/90004" 11 "/home/kapmcgil/projects/def-hiroshi/kapmcgil/cp-parallel/outputs") 2>&1 | tee -a /home/kapmcgil/projects/def-hiroshi/kapmcgil/cp-parallel/logs/11.txt
