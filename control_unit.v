module control_unit (instr,result_sel,mem_write,alu_sel,imm_sel,reg_write,alu_control,jalr_sel,bne_beq_sel,jump,branch);

localparam lw 	  = 7'b0000011;
localparam sw 	  = 7'b0100011;
localparam R_type = 7'b0110011;
localparam I_type = 7'b0010011;
localparam jal    = 7'b1101111;
localparam beq    = 7'b1100011;
localparam jalr   = 7'b1100111;

input [31:0] instr;

output reg_write,alu_sel,mem_write,jalr_sel,branch,jump;
output reg bne_beq_sel;
output reg [2:0] alu_control;
output [1:0] result_sel,imm_sel;

wire [6:0] op_code = instr [6:0];
wire [2:0] func3 = instr [14:12];
wire func7_5 = instr [30];
wire [1:0] alu_operation;
reg [11:0] op;
assign reg_write = op [11];
assign imm_sel = op [10:9];
assign alu_sel = op [8];
assign mem_write = op [7];
assign result_sel = op [6:5];
assign branch = op [4];
assign jump = op [3];
assign alu_operation = op [2:1];
assign jalr_sel = op [0];

always@(op_code)   //main decoder
begin
	case (op_code)
//				 reg_write  imm_sel  alu_sel   mem_write  result_sel   branch   jump   alu_operation   jalr_sel
	lw: op = 	 {1'b1,     2'b00,    1'b1,     1'b0,      2'b01,      1'b0,   1'b0,      2'b00,		1'b0};
	sw: op = 	 {1'b0,     2'b01,    1'b1,     1'b1,      2'b00,      1'b0,   1'b0,      2'b00,	    1'b0};
	beq: op =    {1'b0,     2'b10,    1'b0,     1'b0,      2'b00,      1'b1,   1'b0,      2'b01,		1'b0};
	jal: op = 	 {1'b1,     2'b11,    1'b0,     1'b0,      2'b10,      1'b0,   1'b1,      2'b00,		1'b0};
	I_type: op = {1'b1,     2'b00,    1'b1,     1'b0,      2'b00,      1'b0,   1'b0,      2'b10,		1'b0};
	R_type: op = {1'b1,     2'b00,    1'b0,     1'b0,      2'b00,      1'b0,   1'b0,      2'b10,		1'b0};
	jalr: op =   {1'b1,     2'b00,    1'b1,     1'b0,      2'b10,      1'b0,   1'b1,      2'b00,		1'b1};
	default : op = 0;
	endcase
end

always@(*)   //alu decoder
begin
	if (func3 == 3'b001)
		bne_beq_sel = 1'b0;
	else 
		bne_beq_sel = 1'b1;
	//alu_control = alu_control;
	if (alu_operation == 2'b0)
		alu_control = 3'b000;   //add //lw,sw
	else if (alu_operation == 2'b01)
		alu_control = 3'b001;   //sub  //beq
	else     //alu_operation = 2'b10     //R_type
	begin
		case (func3)
		3'b000: 
			begin 
				if ({op_code[5],func7_5} == 2'b11)
					alu_control = 3'b001;     ///sub
				else
					alu_control = 3'b000;     ///add
			end
		3'b010: alu_control = 3'b101;       //set less than ///slt
		3'b110: alu_control = 3'b011;       ///or
		3'b111: alu_control = 3'b010;       ///and
		default : 	alu_control = 3'b000;
		endcase
	end
end
endmodule
