# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

subjects=(CrunchPilot03)
data_folder_to_analyze=(05_MotorImagery)
file_to_compare_1='pEPI_unwarpedRealigned_slicetimed_fMRI01_Run1.nii'
file_to_compare_2='P_unwarpedRealigned_slicetimed_fMRI01_Run1.nii'
#volume=1
export MATLABPATH=/ufrc/rachaelseidler/tfettrow/Crunch_Code/Matlab_Scripts/helper
		
cd /ufrc/rachaelseidler/share/FromExternal/Research_Projects_UF/CRUNCH/Pilot_Study_Data/$subjects/Processed/MRI_files/$data_folder_to_analyze
ml fsl
fslmaths $file_to_compare_1 -sub $file_to_compare_2 imdiff_EPIcheck

gunzip *.nii.gz*
