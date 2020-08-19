proc simulate {dir tb_name} {
	compile_all $dir

	vsim $tb_name
	add wave -r *
	run 100 ns
}

proc compile_all {dir} {
	set components [lsort -decreasing [glob -nocomplain -type d $dir/*]]

	foreach component $components {
		compile_all $component
	}

	set src_files [lsort -decreasing [glob -nocomplain $dir/*.vhd]]
	foreach src_file $src_files {
		puts "Analyzing $src_file..."
		vcom $src_file
	}
}

