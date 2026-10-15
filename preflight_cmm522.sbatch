#!/bin/bash
# ============================================================================
# CMM 522 -- run the pre-flight check as a batch job
#
#     cd ~/ccbb_projects/cmm522_code
#     sbatch preflight_cmm522.sbatch
#
# Watch it with:   squeue --me
# Read the result: preflight_<jobid>.log
#
# Batch rather than interactive because the R package step can take half an
# hour when the site has no binary repository configured, and an interactive
# session is a poor place to wait that out.
# ============================================================================

#SBATCH --job-name=cmm522_preflight
#SBATCH --account=cusanovichlab
#SBATCH --partition=standard
#SBATCH --nodes=1
#SBATCH --ntasks=4
#SBATCH --time=02:00:00
#SBATCH --output=preflight_%j.log

cd "${SLURM_SUBMIT_DIR}"

echo "Submitted from: ${SLURM_SUBMIT_DIR}"
echo "Running on:     $(hostname)"
echo "Started:        $(date)"
echo

bash preflight_cmm522.sh
STATUS=$?

echo
echo "Finished: $(date)"
if [ "$STATUS" -eq 0 ]; then
    echo "Pre-flight passed. Nothing needs attention."
else
    echo "Pre-flight found problems. Search this log for 'WARN' and 'FAIL'."
fi
exit "$STATUS"
