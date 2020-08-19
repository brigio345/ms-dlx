proc synthesize {dir top_entity} {
	analyze_all $dir

	elaborate $top_entity -library WORK

	ungroup -all -flatten

	compile -map_effort high
}

proc analyze_all {dir} {
	set components [lsort -decreasing [glob -nocomplain -type d $dir/*]]

	foreach component $components {
		analyze_all $component
	}

	set src_files [lsort -decreasing [glob -nocomplain $dir/*.vhd]]
	foreach src_file $src_files {
		puts "Analyzing $src_file..."
		analyze -library WORK -format vhdl $src_file
	}
}

