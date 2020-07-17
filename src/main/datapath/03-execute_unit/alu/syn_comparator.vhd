# setup
set src_root "~/giovanni/DLX/"
set design_dir ""

set files [list utilities.vhd pipo_rot_reg.vhd pisiso_shift_reg.vhd addr_trans.vhd registerfile.vhd]
lappend files [list  windowed_rf_ctrl.vhd windowed_rf_dp.vhd windowed_rf.vhd]
set tl_entity "windowed_rf"

foreach f $files {
	set full_name $root$f
	puts "Analyzing $full_name"
	analyze -library WORK -format vhdl $full_name
}

elaborate $tl_entity -library WORK

# unconstrained synthesis
compile

# define clock
set Period 0.50
create_clock -name "CLK" -period $Period {"CLK"}

