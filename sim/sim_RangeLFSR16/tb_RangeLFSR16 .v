//ECE 5440
//Jon Genty
//tb_RangeLFSR16
//This module is used to test the RangeLFSR16 module

`timescale 1ns/1ns

module tb_RangeLFSR16();
	reg Restart,Run,CLK,RST;
	reg [15:0] offset,limit;
	wire [15:0] out;

	RangeLFSR16 DUT_RangeLFSR16(Restart,Run,offset,limit,out,CLK,RST);
	
	initial
		begin
		CLK<=0;
		RST<=0;
		Restart<=1;
		Run<=0;
		offset<=20;
		limit<=25;
		end

	always
		begin
		#10 CLK<=0;
		#10 CLK<=1;
		end

	initial
		begin
		#15
		RST<=1;
		#20
		Restart<=0;
		#45
		Run<=1;
		end
endmodule
	