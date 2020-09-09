# analyze_dir:
# 	* Argument(s):
# 		- dir: name of the directory containing source code to be analyzed
# 		- src_format: format of source files to be compiled;
# 			it can be "vhdl" (default) or "verilog"
# 	* Result:
# 		analysis of all the source file recursively found in dir
# 	* Return:
# 		none
proc analyze_dir {dir {src_format "vhdl"}} {
	# recur on every subdirectory of $dir, in reverse alphanumerical order
	foreach sub_dir [lsort -decreasing [glob -nocomplain -type d $dir/*]] {
		analyze_dir $sub_dir
	}

	# analyze every file with the specified format in $dir
	foreach src_file [lsort -decreasing [glob -nocomplain $dir/*.vhd]] {
		analyze -library WORK -format $src_format $src_file
	}
}

# synthesize_dual_vth
#	* Argument(s):
#		- top_entity: name of top level entity to be synthesized
#		- time_constraint: maximum delay between inputs and outputs
#			and clock period
#		- lvt_lib: low threshold voltage library
#		- hvt_lib: high threshold voltage library
#	* Result:
#		Synthesize top_entity with dual V-th enabled
#		- post-synthesis netlist (written to $top_entity-YYMMDDHHmm-postsyn.v)
#		- sdc file (written to $top_entity.sdc)
#		- timing report (written to $top_entity-YYMMDDHHmm-timing.rpt)
#		- power report (written to $top_entity-YYMMDDHHmm-power.rpt)
#		- area report (written to $top_entity-YYMMDDHHmm-area.rpt)
#		- threshold voltage group report (written to $top_entity-YYMMDDHHmm-threshold.rpt)
#		- clock gating report (written to $top_entity-YYMMDDHHmm-gating.rpt)
#	* Return:
#		none
proc synthesize_dual_vth {{top_entity "dlx"} {time_constraint 2}
			{lvt_lib "CORE65LPLVT"} {hvt_lib "CORE65LPHVT"}} {
	elaborate $top_entity

	# setup dual-Vth
	set_attribute [find library $lvt_lib] default_threshold_voltage_group LVT -type string
	set_attribute [find library $hvt_lib] default_threshold_voltage_group HVT -type string

	# setup timing constraints
	create_clock -period $time_constraint I_CLK
	set_max_delay -from [all_inputs] -to [all_outputs] $time_constraint

	ungroup -all -flatten
	
	compile_ultra -gate_clock -retime

	# write outputs
	set name "$top_entity-[clock format [clock seconds] -format %Y%m%d%H%M]"

	write -format verilog -hierarchy -output "$name-postsyn.v"
	write_sdc "$name.sdc"
	report_timing > "$name-timing.rpt"
	report_power > "$name-power.rpt"
	report_area > "$name-area.rpt"
	report_threshold_voltage_group > "$name-threshold-rpt"
	report_clock_gating > "$name-gating.rpt"
}

# synthesize
#	* Argument(s):
#		- top_entity: name of top level entity to be synthesized
#		- time_constraint: maximum delay between inputs and outputs
#			and clock period
#		- wire_load_model: name of the wire load model
#	* Result:
#		Synthesize top_entity
#		- post-synthesis netlist (written to $top_entity-YYMMDDHHmm-postsyn.v)
#		- sdc file (written to $top_entity.sdc)
#		- timing report (written to $top_entity-YYMMDDHHmm-timing.rpt)
#		- power report (written to $top_entity-YYMMDDHHmm-power.rpt)
#		- area report (written to $top_entity-YYMMDDHHmm-area.rpt)
#		- clock gating report (written to $top_entity-YYMMDDHHmm-gating.rpt)
#	* Return:
#		none
proc synthesize {{top_entity "dlx"} {time_constraint 2} {wire_load_model "5K_hvratio_1_4"}} {
	elaborate $top_entity

	# setup timing constraints
	create_clock -period $time_constraint I_CLK
	set_max_delay -from [all_inputs] -to [all_outputs] $time_constraint

	# setup working conditions
	set_wire_load_model -name $wire_load_model

	ungroup -all -flatten
	
	compile_ultra -timing_high_effort_script -gate_clock -retime

	# write outputs
	set name "$top_entity-[clock format [clock seconds] -format %Y%m%d%H%M]"

	write -format verilog -hierarchy -output "$name-postsyn.v"
	write_sdc "$name.sdc"
	report_timing > "$name-timing.rpt"
	report_power > "$name-power.rpt"
	report_area > "$name-area.rpt"
	report_clock_gating > "$name-gating.rpt"
}

