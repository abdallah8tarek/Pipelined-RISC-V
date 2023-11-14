module ALU (zero,ALUout,a,b,ALUControl);
	
	output reg zero;
	output reg signed [31:0] ALUout;
	input [2:0] ALUControl;
	input [31:0] a,b;
	
	always @(*) 
	begin
		case (ALUControl)
		3'b010 : ALUout = a & b;   //bitwise and 
		3'b011 : ALUout = a | b;   //bitwise or
		3'b000 : ALUout = a + b;   //addition
		3'b001 : ALUout = a - b;   //subtraction
		3'b101 : ALUout = (a<b)? 1:0;   //compare
		//5 : ALUout = ~(a | b); 
		default : ALUout = 0;
		endcase
		
		if (ALUout == 0)
			zero = 1;
		else 
			zero = 0;
	end
endmodule