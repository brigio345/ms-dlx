onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -format Logic /tb_dlx/dut/datapath_0/i_clk
add wave -noupdate -color Blue -format Logic /tb_dlx/dut/datapath_0/fetch_unit_0/i_taken
add wave -noupdate -color Blue -format Literal -radix unsigned /tb_dlx/dut/datapath_0/fetch_unit_0/o_pc
add wave -noupdate -color Blue -format Literal -radix hexadecimal /tb_dlx/dut/datapath_0/fetch_unit_0/o_ir
add wave -noupdate -color {Forest Green} -format Literal -radix hexadecimal /tb_dlx/dut/datapath_0/decode_unit_0/o_opcode
add wave -noupdate -color {Forest Green} -format Literal -radix hexadecimal /tb_dlx/dut/datapath_0/decode_unit_0/o_func
add wave -noupdate -color {Forest Green} -format Literal /tb_dlx/dut/datapath_0/decode_unit_0/i_sel_a
add wave -noupdate -color {Forest Green} -format Literal /tb_dlx/dut/datapath_0/decode_unit_0/i_sel_b
add wave -noupdate -color {Forest Green} -format Literal -radix unsigned /tb_dlx/dut/datapath_0/decode_unit_0/o_rd1_addr
add wave -noupdate -color {Forest Green} -format Literal -radix unsigned /tb_dlx/dut/datapath_0/decode_unit_0/o_rd2_addr
add wave -noupdate -color {Forest Green} -format Literal -radix unsigned /tb_dlx/dut/datapath_0/decode_unit_0/o_dst
add wave -noupdate -color {Forest Green} -format Literal -radix decimal /tb_dlx/dut/datapath_0/decode_unit_0/o_a
add wave -noupdate -color {Forest Green} -format Literal -radix decimal /tb_dlx/dut/datapath_0/decode_unit_0/o_b
add wave -noupdate -color {Forest Green} -format Literal -radix decimal /tb_dlx/dut/datapath_0/decode_unit_0/o_imm
add wave -noupdate -color {Forest Green} -format Literal -radix unsigned /tb_dlx/dut/datapath_0/decode_unit_0/o_target
add wave -noupdate -color {Forest Green} -format Literal -radix decimal /tb_dlx/dut/datapath_0/decode_unit_0/off_ext
add wave -noupdate -color Red -format Literal /tb_dlx/dut/datapath_0/execute_unit_0/i_aluop
add wave -noupdate -color Red -format Literal -radix decimal /tb_dlx/dut/datapath_0/execute_unit_0/a
add wave -noupdate -color Red -format Literal -radix decimal /tb_dlx/dut/datapath_0/execute_unit_0/op2
add wave -noupdate -color Red -format Literal -radix decimal /tb_dlx/dut/datapath_0/execute_unit_0/o_aluout
add wave -noupdate -color Magenta -format Literal /tb_dlx/dut/datapath_0/memory_unit_0/o_rd
add wave -noupdate -color Magenta -format Literal /tb_dlx/dut/datapath_0/memory_unit_0/o_wr
add wave -noupdate -color Magenta -format Literal -radix unsigned /tb_dlx/dut/datapath_0/memory_unit_0/o_addr
add wave -noupdate -color Magenta -format Literal -radix decimal /tb_dlx/dut/datapath_0/memory_unit_0/o_loaded
add wave -noupdate -color Orange -format Literal -radix unsigned /tb_dlx/dut/datapath_0/write_unit_0/o_wr_addr
add wave -noupdate -color Orange -format Literal -radix hexadecimal /tb_dlx/dut/datapath_0/write_unit_0/o_wr_data
add wave -noupdate -color Orange -format Logic /tb_dlx/dut/datapath_0/write_unit_0/o_wr
add wave -noupdate -format Literal -radix decimal /tb_dlx/dut/datapath_0/register_file_0/registers
add wave -noupdate -format Literal -radix hexadecimal /tb_dlx/data_mem_0/mem
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{IF} {1 ns} 0} {{ID} {3 ns} 0} {{EX} {5 ns} 0} {{MEM} {7 ns} 0} {{WB} {9 ns} 0}
configure wave -namecolwidth 359
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ns
update
WaveRestoreZoom {0 ns} {12 ns}
