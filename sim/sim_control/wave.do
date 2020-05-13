onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /tb_gameController/CLK
add wave -noupdate /tb_gameController/RST
add wave -noupdate -divider {New Divider}
add wave -noupdate /tb_gameController/castButton
add wave -noupdate /tb_gameController/reelButton
add wave -noupdate /tb_gameController/DUT/currentRand
add wave -noupdate -divider {New Divider}
add wave -noupdate /tb_gameController/blinkBit
add wave -noupdate -radix hexadecimal /tb_gameController/gameInfo
add wave -noupdate -radix unsigned /tb_gameController/DUT/State
add wave -noupdate -divider {New Divider}
add wave -noupdate /tb_gameController/DUT/fishTimerDone
add wave -noupdate -radix hexadecimal /tb_gameController/DUT/fullFishTimeDisp
add wave -noupdate /tb_gameController/DUT/reelTimerDone
add wave -noupdate -radix hexadecimal /tb_gameController/DUT/reelTimer/CurrentValue
add wave -noupdate -divider {New Divider}
add wave -noupdate /tb_gameController/DUT/resetLED
add wave -noupdate /tb_gameController/DUT/blinky/blinkThese
add wave -noupdate /tb_gameController/DUT/blinky/lightThese
add wave -noupdate /tb_gameController/DUT/currentLED
add wave -noupdate /tb_gameController/lightBar
add wave -noupdate /tb_gameController/DUT/blinky/timerDone
add wave -noupdate -divider {New Divider}
add wave -noupdate /tb_gameController/scoreDown
add wave -noupdate /tb_gameController/scoreUp
add wave -noupdate /tb_gameController/scoreRst
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 5} {6725678100 ns} 0}
quietly wave cursor active 1
configure wave -namecolwidth 588
configure wave -valuecolwidth 409
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
configure wave -timelineunits sec
update
WaveRestoreZoom {0 ns} {2078908800 ns}
