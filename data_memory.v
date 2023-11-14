// 32bit word data memory
module ram (address,data_in,data_out,clk,we);

parameter length = 256;
parameter width = 32;

input clk,we;
input [width-1:0]address;
input [width-1:0]data_in;

output [width-1:0]data_out;

reg [width-1:0] mem [length-1:0];

wire [$clog2(length)-1:0]trunc_add;

function [$clog2(length)-1:0] address_trunc;
input [width-1:0]add;

address_trunc = add;
endfunction

assign trunc_add = address_trunc (address);
assign data_out = mem [trunc_add];

always@(posedge clk)
begin
	if (we)
	begin
		mem [trunc_add] = data_in;
	end
	else
	begin
		mem [trunc_add] = mem [trunc_add];
	end
end
endmodule