// ====================================================================
//                         VECTOR-06C FPGA REPLICA
//
// 				  Copyright (C) 2007-2009 Viacheslav Slavinsky
//
// This core is distributed under modified BSD license. 
// For complete licensing information see LICENSE.TXT.
// -------------------------------------------------------------------- 
//
// An open implementation of Vector-06C home computer
//
// Author: Viacheslav Slavinsky, http://sensi.org/~svo
//
// Modified by Ivan Gorodetsky
// 
// Design File: clockster.v
//
// Vector-06C clock generator.
//
// --------------------------------------------------------------------

`default_nettype none

module clockster(clk, clk50, clk24, clk18, ce12, ce6, ce6x, ce3, video_slice, pipe_ab, ce1m5, clkpalFSC,clk60);
input  [1:0] 	clk;
input			clk50;
output clk24;
output clk18;
output ce12 = qce12;
output ce6 = qce6;
output ce6x = qce6x;
output ce3 = qce3;
output video_slice = qvideo_slice;
output pipe_ab = qpipe_ab;
output ce1m5 = qce1m5;
output clkpalFSC;
output clk60;

reg[5:0] ctr;
reg[4:0] initctr;

reg qce12, qce6, qce6x, qce3, qce3v, qvideo_slice, qpipe_ab, qce1m5;

wire lock;

wire clk300;
wire clk100;

mclk24mhz vector_xtal(clk50, clk24, clk300, clk60, lock);

// Derive clock for PAL subcarrier: 4x 4.43361875
`define PHACC_WIDTH 32
`define PHACC_DELTA 253896634 
`define PHACC_DELTA 507793268

reg [`PHACC_WIDTH-1:0] pal_phase;
wire [`PHACC_WIDTH-1:0] pal_phase_next;
assign pal_phase_next = pal_phase + `PHACC_DELTA;
reg palclkreg;

always @(posedge clk300) begin
	pal_phase <= pal_phase_next;
end

ayclkdrv clkbufpalfsc(pal_phase[`PHACC_WIDTH-1], clkpalFSC);

`define COPHACC_DELTA 131941395 //18.432 MHz
reg [30:0] cophacc;
wire [30:0] cophacc_next = cophacc + `COPHACC_DELTA;
always @(posedge clk300) cophacc <= cophacc_next;
assign clk18 = cophacc[30];

reg[15:0] clo=1'b1;
reg clk4;
always @(posedge clk24) begin
	if (initctr != 3) begin
		initctr <= initctr + 1'b1;
	end // latch
	else begin
		qpipe_ab <= ctr[5]; 				// pipe a/b 2x slower
		qce12 <= ctr[0]; 					// pixel push @12mhz
		qce6 <= ctr[1] & ctr[0];			// pixel push @6mhz
		qce6x <= ctr[1] & ~ctr[0];          // pre-pixel push @6mhz

		qce3 <= ctr[2] & ctr[1] & !ctr[0]; //00100000 - svofski

		qvideo_slice <= !ctr[2];
		qce1m5 <= !ctr[3] & ctr[2] & ctr[1] & !ctr[0];
		ctr <= ctr + 1'b1;
		clo<={clo[6:0],clo[7]};
		clk4<=clo[0];
	end
end
endmodule
