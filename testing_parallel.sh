subjects=(CrunchPilot01_development1)

Code_dir=/ufrc/rachaelseidler/tfettrow/Crunch_Code


export MATLABPATH=${Code_dir}/Matlab_Scripts/helper


for SUB in ${subjects[@]}; do
	Subject_dir=/ufrc/rachaelseidler/share/FromExternal/Research_Projects_UF/CRUNCH/Pilot_Study_Data/${SUB}
	cd "${Subject_dir}"


	mkdir -p "temp"
	cp "${Code_dir}/Matlab_Scripts/scripts/houdini.m" "${Subject_dir}/temp"
	cd "temp"
	ml matlab
	mcc -R -singleCompThread -m houdini.m
			
	#./run_houdini.sh <mcr_directory> <argument_list>
done

