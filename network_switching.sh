#!/bin/bash 


SUB=( GT_dummy )

for this_sub in ${SUB[@]}; do
mask_path=/ufrc/rachaelseidler/share/FromExternal/Research_Projects_UF/CRUNCH/MiM_Data/ROIs_Networks
MRI_path=/ufrc/rachaelseidler/share/FromExternal/Research_Projects_UF/CRUNCH/MiM_Data/${this_sub}/Processed/MRI_files/06_Nback/ANTS_Normalization

networks=( ${mask_path}/network* )
	### bring in a new network
export MATLABPATH=/ufrc/rachaelseidler/grant.tays/Code/

ml fsl
ml matlab

###temp method, copy network to the subject specific folder, adapt it there and copy it back as binary to network folder later
cd ${mask_path}




#for this_network in ${networks[@]}; do
### if ${this_network} == binary_*; do nothing?  Idk how this part will work out.

#	cp ${this_network} ${MRI_path}
#done


### TO DO: make it determine that if it has a binary mask to not do any of that.  


cd ${MRI_path}


### SPLITS RUNS INTO VOLUMES, GUNZIPS THEM SO THEY CAN COREGISTER
images_to_split=( smoothed_* )
	for this_image_to_split in ${images_to_split[@]}; do
		#echo ${this_image_to_split}
		#fslsplit  ${this_image_to_split} ${this_image_to_split}_vol
		#gunzip smoothed_*


####  MATLAB CODES TO COREGISTER MASK TO FILES, THEN TRASNFORM IT INTO BINARY
			#matlab -nodesktop -nosplash -r "try; mask_coreg_to_vol; catch; end; quit"
			### coregister and reslice mask to vol000
           # matlab -nodesktop -nosplash -r "try; imcalc_binary_mask_conv; catch; end; quit"
            ###imcalc it to a binary mask, save as binary_


		vol=( ${this_image_to_split}* )
		for this_network in ${networks[@]}; do
		echo ${this_network}
			for this_vol in ${vol[@]}; do 
			echo ${this_vol}


###actual beta extraction
	outfile=${this_sub}_${this_network}_network_Vals.txt
	##DMN Locations
	outfile2=DF_PCC_betas
	outfile3=DF_med_prefron_cor_betas

	###WM Locations
	outfile4=L_DLPFC_betas
	outfile5=parietal_post_central_gyrus
	
binary_network=( binary* )
for this_binary in ${binary_network[@]}; do		
		beta=0
		beta=$(fslmeants -i ${this_vol} -m ${mask_path}/binary_*.nii)
		echo -e "$beta" >> "$outfile"				​
done
		beta=0
		beta=$(fslmeants -i ${this_vol} -c 1 -61 38 --usemm)	
		echo -e "$beta" >> "$outfile2"

		beta=0
		beta=$(fslmeants -i ${this_vol} -c 1 55 -3 --usemm)	
		echo -e "$beta" >> "$outfile3"

		beta=0
		beta=$(fslmeants -i ${this_vol} -c -45 29 34 --usemm)	
		echo -e "$beta" >> "$outfile4"

		beta=0
		beta=$(fslmeants -i ${this_vol} -c -45 -12 60 --usemm)	
		echo -e "$beta" >> "$outfile5"

### temp method of copying binary network template back to network folder
#for this_binary in ${binary_network[@]}; do
	#cp ${this_binary} ${mask_path}
	#rm ${this_binary}
#done
			done
		done			
	done
done