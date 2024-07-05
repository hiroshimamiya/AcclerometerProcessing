### How to use?
Run cp_calculate.py for converting the acceleration values in mg to cp categories based on cut-off points.

Split the operations across different jobs based on folder structure maintained in the dataset. Each folder contains data for about 2000 participants and we have 51 folders. Output dataframe and logs will also be saved per folder.

Dataset has been divided into the following folders: [list of folder](./folder_num.txt)

#### To execute:
##### Single directory
For all participants in dataset folder 10 with logs piped and time recorded.

`(time python cp_calculate.py "/lustre03/project/6008063/neurohub/UKB/Bulk/90004" 10 "/home/kapmcgil/projects/def-hiroshi/kapmcgil/cp-parallel/outputs") 2>&1 | tee -a /home/kapmcgil/projects/def-hiroshi/kapmcgil/cp-parallel/logs/10.txt`

##### Bulk using SLURM

Run a script which will submit multiple SLURM jobs in a batch: [job array script](job_array.sh)

##### SLURM notes

- sbatch: submit jobs after requesting a set of resources. Problem occurs when we have to submit multiple jobs for same script with different arguments.
    - https://slurm.schedmd.com/sbatch.html


- srun: allows parallel execution on the allocated resources: either as process or threads.
    - https://slurm.schedmd.com/srun.html
    - https://docs.alliancecan.ca/wiki/Advanced_MPI_scheduling


- job array: launch multiple jobs without creating different script for each job. Useful when we have similar tasks but arguments are different. Can be sequential or concurrent depending on workload at that in cluster.
    - https://slurm.schedmd.com/job_array.html

- SLURM with gnu parallel: explicitly make sure that multiple jobs submitted together are run in parallel fashion on the allocated resources.
    - https://portal.supercomputing.wales/index.php/index/slurm/interactive-use-job-arrays/batch-submission-of-serial-jobs-for-parallel-execution/