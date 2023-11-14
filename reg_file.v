module reg_file (a1,a2,a3,wd3,rd1,rd2,clk,we3);

input clk,we3;
input [4:0] a1,a2,a3;
input [31:0] wd3;
output [31:0] rd1,rd2;

reg [31:0] mem [31:0];

assign rd1 = mem [a1];
assign rd2 = mem [a2];
assign 	mem[0] = 32'd0;

always@(negedge clk)
	if (we3)
		mem [a3] <= wd3;
	else
		mem [a3] <= mem [a3];
endmodule