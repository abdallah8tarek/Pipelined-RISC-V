module instruction_memory (address,data_out,clk);

parameter length = 256;
parameter width = 32;

input clk;
input [31:0]address;
output [31:0]data_out;
reg [width-1:0] mem [length-1:0];

assign data_out = mem [address>>2];

//$readmemh("inst.mem", mem);
endmodule