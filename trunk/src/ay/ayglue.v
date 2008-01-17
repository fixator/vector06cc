module ayglue(clk, ce, reset_n, address, data, wren, rden, q, sound);
input 			clk;
input			ce;
input			reset_n;
input [1:0] 	address;		// port 14 (00) = data; port 15 (01) = address
input [7:0]		data;
input			wren;
input			rden;
output reg[7:0]	q;

output[7:0]	sound;

wire [7:0] 	odata;
wire 		odataoe;

always @(posedge clk) if (odataoe) q <= odata;

YM2149 digeridoo(
  .I_DA(data),
  .O_DA(odata),
  .O_DA_OE_L(odataoe),

  .I_A9_L(0),
  .I_A8(1),
  .I_BDIR(wren), 
  .I_BC2(1),
  .I_BC1(address[0]),
  .I_SEL_L(1), // something /16?

  .O_AUDIO(sound),

  .ENA(ce),
  .RESET_L(reset_n),
  .CLK(clk),
  );


endmodule
