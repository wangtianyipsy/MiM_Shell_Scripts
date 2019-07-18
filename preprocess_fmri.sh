
subjects=(CrunchPilot01)

module load matlab

# Set the path for our custom matlab functions and scripts
export MATLABPATH=/ufrc/rachaelseidler/share/FromExternal/Research_Projects_UF/CRUNCH/Code/Spm/helper/


for SUB in ${subjects[@]}; do
    #for SSN in “${sessions[@]}“; do   # this will be used in case of multiple sessions

	cd /ufrc/rachaelseidler/share/FromExternal/Research_Projects_UF/CRUNCH/Pilot_Study_Data/${SUB}/

	cp /ufrc/rachaelseidler/share/FromExternal/Research_Projects_UF/CRUNCH/Code/Spm/helper/Ugrant_defaults.m /ufrc/rachaelseidler/share/FromExternal/Research_Projects_UF/CRUNCH/Pilot_Study_Data/${SUB}/;

	#matlab -nodesktop -nosplash -r "try; crunch_preprocess_motorimagery; catch; end; quit"

	matlab -nodesktop -nosplash -r "try; crunch_preprocess_nback; catch; end; quit"

	rm Ugrant_defaults.m
done
#done
