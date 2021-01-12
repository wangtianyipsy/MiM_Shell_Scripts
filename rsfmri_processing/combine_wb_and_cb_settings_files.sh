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

# this script requires arguments ... call from the batch_fmri.batch

# example >> combine_wb_and_cb_settings_files $Matlab_dir conn_wu120_all_wb conn_wu120_all_cb
# combine_wb_and_cb_settings_files.sh $Matlab_dir ROI_settings_conn_wu120_all_wb.txt ROI_settings_conn_wu120_all_cb.txt

argument_counter=0
for this_argument in "$@"; do
	if	[[ $argument_counter == 0 ]]; then
		Matlab_dir=$this_argument
	elif [[ $argument_counter == 1 ]]; then
		conn_project1=$this_argument
	elif [[ $argument_counter == 2 ]]; then
		conn_project2=$this_argument
	fi
	(( argument_counter++ ))
done

export MATLABPATH=${Matlab_dir}/helper

#for SUB in ${subjects[@]}; do
Study_dir=/blue/rachaelseidler/share/FromExternal/Research_Projects_UF/CRUNCH/MiM_Data
cd $Study_dir

ml fsl
node_index=0

# TO DO: this is currently hard coded for wu120 data.. make it more dynamic
outfile=ROI_settings_conn_wu120_all_wb_cb.txt
if  [ -e $outfile ]; then
	rm $outfile
fi

conn_project1_data=$(cat ${conn_project1})
conn_project2_data=$(cat ${conn_project2})

# outfile_data=$(cat $outfile)
# new_row=$this_node_data
# existing_section=$outfile_data
		
echo -e "$conn_project1_data\n$conn_project2_data" >> "$outfile"
