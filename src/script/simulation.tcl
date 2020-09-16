set sim_root "."
set asm_root "../../assembly"

# simulate_dlx
# 	* Argument(s):
# 		- asm_file: assembly source code to be loaded to instruction
# 			memory
# 		- run_time: duration (in ns) of the simulation
# 	* Result:
# 		make the DLX run asm_file for run_time nanoseconds
# 	* Return:
# 		none
proc simulate_dlx {asm_file {run_time 100}} {
	global sim_root asm_root

	if {[file exists $asm_file] == 0} {
		puts "asm_file $asm_file not found. Exiting."
		return
	}

	# assemble asm code
	exec perl $asm_root/assembler/dlxasm.pl $asm_file
	exec $asm_root/assembler/conv2memory $asm_file.exe > $sim_root/test.asm.mem

	# cleanup temporary files
	exec rm $asm_file.exe $asm_file.exe.hdr

	# simulate assembled code
	vsim tb_dlx
	if {[file exists $asm_root/dlx.do]} {
		do $asm_root/dlx.do
	} else {
		add wave *
	}

	run $run_time ns
}

# compile_dir:
# 	* Argument(s):
# 		- dir: name of the directory containing source code to be compiled
# 		- file_extension: extension of source files to be compiled;
# 			it can be "vhd" (default) for VHDL code or
# 			"v" for Verilog code
# 	* Result:
# 		compilation of all the source file recursively found in dir
# 	* Return:
# 		none
proc compile_dir {dir {file_extension "vhd"}} {
	# recur on every subdirectory of $dir, in reverse alphanumerical order
	foreach subdir [lsort -decreasing [glob -nocomplain -type d $dir/*]] {
		compile_dir $subdir
	}

	# compile every file with the specified extension in $dir
	foreach src_file [glob -nocomplain $dir/*.$file_extension] {
		vcom -pedanticerrors -check_synthesis -bindAtCompile $src_file
	}
}

