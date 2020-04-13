#!/bin/bash
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>

#export MATLABPATH=/ufrc/rachaelseidler/grant.tays/Code/

Study_dir=/ufrc/rachaelseidler/share/FromExternal/Research_Projects_UF/CRUNCH/MiM_Data


Subjects=( 2008 )
this_functional_run_folder=( 06_Nback )

for this_subject in ${Subjects[@]}; do
	
	cd ${Study_dir}/ROIs_Networks

	ml fsl
	ml matlab

	shopt -s nullglob
	prefix_to_delete=(binary*)
	if [ -e "$prefix_to_delete" ]; then
		rm binary*
	fi

	for this_network in network*.nii; do
		echo binarizing $this_network
		
		fslmaths $this_network -bin binary_${this_network}
		gunzip *nii.gz

		cp binary_${this_network} ${Study_dir}/$this_subject/Processed/MRI_files/${this_functional_run_folder}/ANTS_Normalization
	done

	cd ${Study_dir}/$this_subject/Processed/MRI_files/${this_functional_run_folder}/ANTS_Normalization

	shopt -s nullglob
	prefix_to_delete=(dimMatch_*)
	if [ -e "$prefix_to_delete" ]; then
		rm dimMatch_*
		rm *.txt
	fi

	for this_binary_mask in binary_*.nii; do
		echo matching diminensions for $this_binary_mask
		flirt -in $this_binary_mask -ref MNI_2mm.nii -applyxfm -usesqform -out dimMatch_$this_binary_mask
		gunzip *nii.gz*		
	done

	for this_dimMatch_binary_mask in dimMatch_*.nii; do
		this_mask_file_corename=$(echo $this_dimMatch_binary_mask | cut -d. -f 1)
		fmri_run_index=1
		for this_functional_run in smoothed_*.nii; do
			echo Currently calculating average activation for $this_subject at ${this_dimMatch_binary_mask} in $this_functional_run
			
			fslsplit $this_functional_run
			gunzip *nii.gz*

			for this_volume_file in vol*; do		
				beta=0
				outfile=${this_mask_file_corename}_fmri${fmri_run_index}_betas.txt		
				beta=$(fslmeants -i $this_volume_file -m $this_dimMatch_binary_mask)
				echo -e "$beta" >> "$outfile"				​
			done
			rm vol*

			(( fmri_run_index ++ ))
		done
	done
done