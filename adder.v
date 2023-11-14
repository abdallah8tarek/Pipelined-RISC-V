module full_adder_behave (f_sum,a,b);
	
	output reg [31:0] f_sum;
	input [31:0] a,b;
		
	always @ (*)
		f_sum = a + b ;
endmodule