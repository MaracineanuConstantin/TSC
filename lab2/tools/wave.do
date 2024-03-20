onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /top/test/WRITE_NUMBER
add wave -noupdate /top/test/READ_NUMBER
add wave -noupdate /top/test/WRITE_ORDER
add wave -noupdate /top/test/READ_ORDER
add wave -noupdate /top/test/clk
add wave -noupdate /top/test/load_en
add wave -noupdate /top/test/reset_n
add wave -noupdate /top/test/operand_a
add wave -noupdate /top/test/operand_b
add wave -noupdate /top/test/opcode
add wave -noupdate /top/test/write_pointer
add wave -noupdate /top/test/read_pointer
add wave -noupdate /top/test/instruction_word
add wave -noupdate /top/test/passed_tests
add wave -noupdate /top/test/failed_tests
add wave -noupdate /top/test/total_tests
add wave -noupdate /top/test/seed
add wave -noupdate /top/test/iw_reg_test
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {0 ns} 0}
quietly wave cursor active 0
configure wave -namecolwidth 150
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
WaveRestoreZoom {0 ns} {1088 ns}
