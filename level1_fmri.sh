# TO DO: implement subject argument
module load matlab

# Set the path for our custom matlab functions and scripts
export MATLABPATH=/ufrc/rachaelseidler/share/FromExternal/Research_Projects_UF/CRUNCH/Code/Spm/helper/

#for SUB in “${subjects[@]}“; do
    #for SSN in “${sessions[@]}“; do

#matlab -nodesktop -nosplash -r "try; crunch_level1_motorImagery; catch; end; quit"

matlab -nodesktop -nosplash -r "try; crunch_level1_nback; catch; end; quit"

#done
#done
