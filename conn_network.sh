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


# Set the path for our custom matlab functions and scripts
Code_dir=/ufrc/rachaelseidler/tfettrow/Crunch_Code
	
export MATLABPATH=${Code_dir}/Matlab_Scripts/helper
	
Subject_dir=/ufrc/rachaelseidler/share/FromExternal/Research_Projects_UF/CRUNCH/MiM_Data

cd $Subject_dir

ml matlab
matlab -nodesktop -nosplash -r "try; conn_network_withinGroup_taskbased(1.5,'2002','2007','2008','2012','2013','2018','2020','2021','2022','2023','2025','2026'); catch; end; quit"

#matlab -nodesktop -nosplash -r "try; conn_seed_network('1002','1004'); catch; end; quit"