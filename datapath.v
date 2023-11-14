module datapath (instr,instrD,read_data,clk,reset_F,reset_D,reset_E,reset_M,reset_W,pc_sel,en_F,en_D,reg_write,alu_sel,alu_control,result_sel,imm_sel,pc_out
				,alu_result_out,write_dataM,jalr_sel,bne_beq_sel,jump,branch,mem_write,mem_writeM);

input [31:0] instr;
input [31:0] read_data;
input clk,reset_F,reset_D,reset_E,reset_M,reset_W,pc_sel,en_F,en_D;

input reg_write,alu_sel,jalr_sel,bne_beq_sel,jump,branch,mem_write;
input [2:0] alu_control;
input [1:0] result_sel,imm_sel;

output mem_writeM;
output [31:0] pc_out;
output [31:0] alu_result_out;
output [31:0] write_dataM;
output [31:0] instrD;

wire [31:0] pcF;

wire [31:0] pcD,pc_plus4D,rd1,rd2,immexD;
wire [4:0] rs1D,rs2D,rdD;
assign rs1D = instrD [19:15];
assign rs2D = instrD [24:20];
assign rdD = instrD [11:7];

wire reg_writeE,alu_selE,jalr_selE,bne_beq_selE,mem_writeE,jumpE,branchE;
wire [2:0] alu_controlE;
wire [1:0] result_selE;
wire [31:0] pcE,pc_plus4E,rd1E,rd2E,immexE;
wire [4:0] rs1E,rs2E,rdE;
wire [31:0] write_dataE;

wire reg_writeM;
wire [1:0] result_selM;
wire [31:0] pc_plus4M,alu_resultM;
wire [4:0] rdM;

wire reg_writeW;
wire [1:0] result_selW;
wire [31:0] pc_plus4W,alu_resultW,read_dataW;
wire [4:0] rdW;

wire [1:0] forwardAE,forwardBE;
wire stallF,stallD,flushD,flushE;

wire [31:0] sourceB,sourceA;
wire zero,zero_flag;

//mux2 (mux_out,in0,in1,sel)
wire pc_sel_real;
wire [31:0] pc_next,pc_target,pc_plus4;
wire [31:0] pc_or_reg;    //for jalr selection
mux2 pc_mux(.mux_out (pc_next),
			.in0 (pc_plus4),
			.in1 (pc_or_reg),
			.sel (pc_sel_real));

//full_adder_behave (f_sum,a,b)
full_adder_behave add_plus_4(.f_sum (pc_plus4),
					         .a (32'd4),
							 .b (pcF));		 

//reg_file (a1,a2,a3,wd3,rd1,rd2,clk,we3)
wire [31:0] result;
reg_file reg_file1(.a1 (instrD[19:15]),
				   .a2 (instrD[24:20]),
				   .a3 (rdW),
				   .wd3 (result),
				   .rd1 (rd1),
				   .rd2 (rd2),
				   .clk (clk),
				   .we3 (reg_writeW));

//sign_extend (in,out,sel)
sign_extend extend(.in (instrD[31:7]),
				   .out (immexD),
				   .sel (imm_sel));

//mux3 (mux_out,in0,in1,in2,sel)
mux3 source_forwardingA(.mux_out (sourceA),
						.in0 (rd1E),
						.in1 (result),
						.in2 (alu_resultM),
						.sel (forwardAE));

//mux3 (mux_out,in0,in1,in2,sel)
mux3 source_forwardingB(.mux_out (write_dataE),
						.in0 (rd2E),
						.in1 (result),
						.in2 (alu_resultM),
						.sel (forwardBE));
				
//full_adder_behave (f_sum,a,b)
full_adder_behave add_imm(.f_sum (pc_target),
						  .a (immexE),
					      .b (pcE));						   			   

//mux2 (mux_out,in0,in1,sel)
mux2 reg_out_mux(.mux_out (sourceB),
				 .in0 (write_dataE),
				 .in1 (immexE),
				 .sel (alu_selE));

wire [31:0] alu_res;
//ALU (zero,ALUout,a,b,ALUControl)
ALU alu1(.zero (zero),
		 .ALUout (alu_res),
		 .a (sourceA),
		 .b (sourceB),
		 .ALUControl (alu_controlE));
assign zero_flag = bne_beq_selE ? zero : ~zero;
assign pc_sel_real = pc_sel ? (jumpE | (zero_flag & branchE)) : 1'b0;

//mux2 (mux_out,in0,in1,sel)
mux2 jalr_mux(.mux_out (pc_or_reg),
			  .in0 (pc_target),
			  .in1 (alu_res),
			  .sel (jalr_selE));

//mux3 (mux_out,in0,in1,in2,sel)
mux3 result_mux(.mux_out (result),
				.in0 (alu_resultW),
				.in1 (read_dataW),
				.in2 (pc_plus4W),
				.sel (result_selW));

wire en_F_real = en_F ? stallF : 1'b0;
//d_flip_flop #(parameter n = 32)(in,out,clk,reset,en);
d_flip_flop #(32) featch(.in(pc_next),
						 .out(pcF),
						 .clk(clk),
						 .reset(reset_F),
						 .en(en_F_real));

wire reset_D_real = reset_D ? 1'b1 : flushD;
wire en_D_real = en_D ? stallD : 1'b0;
//d_flip_flop #(parameter n = 32)(in,out,clk,reset,en);
wire [95:0] decode_in = {instr,pcF,pc_plus4};
wire [95:0] decode_out;
assign {instrD,pcD,pc_plus4D} = decode_out;
d_flip_flop #(96) decode(.in(decode_in),
						 .out(decode_out),
						 .clk(clk),
						 .reset(reset_D_real),
						 .en(en_D_real));

//d_flip_flop #(parameter n = 32)(in,out,clk,reset,en);
wire reset_E_real = reset_E ? 1'b1 : flushE;
wire [186:0] excute_in = {reg_write,alu_sel,jalr_sel,bne_beq_sel,alu_control,result_sel,mem_write,rd1,rd2,pcD,rs1D,rs2D,rdD,immexD,pc_plus4D,jump,branch};
wire [186:0] excute_out;
assign {reg_writeE,alu_selE,jalr_selE,bne_beq_selE,alu_controlE,result_selE,mem_writeE,rd1E,rd2E,pcE,rs1E,rs2E,rdE,immexE,pc_plus4E,jumpE,branchE} = excute_out;
d_flip_flop #(187) excute(.in(excute_in),
						  .out(excute_out),
						  .clk(clk),
						  .reset(reset_E_real),
						  .en(1'b0));

//d_flip_flop #(parameter n = 32)(in,out,clk,reset,en);
wire [104:0] mem_in = {reg_writeE,result_selE,mem_writeE,alu_res,write_dataE,rdE,pc_plus4E};
wire [104:0] mem_out;
assign {reg_writeM,result_selM,mem_writeM,alu_resultM,write_dataM,rdM,pc_plus4M} = mem_out;
d_flip_flop #(105) memory(.in(mem_in),
						  .out(mem_out),
						  .clk(clk),
						  .reset(reset_M),
						  .en(1'b0));

//d_flip_flop #(parameter n = 32)(in,out,clk,reset,en);
wire [103:0] write_back_in = {reg_writeM,result_selM,alu_resultM,read_data,rdM,pc_plus4M};
wire [103:0] write_back_out;

assign {reg_writeW,result_selW,alu_resultW,read_dataW,rdW,pc_plus4W} = write_back_out;
d_flip_flop #(104) write_back(.in(write_back_in),
							  .out(write_back_out),
							  .clk(clk),
							  .reset(reset_W),
							  .en(1'b0));

//hazerd_unit (rs1D,rs2D,rdE,rs1E,rs2E,pc_sel,result_selE,rdM,reg_writeM,rdW,reg_writeW,forwardAE,forwardBE,stallF,stallD,flushD,flushE);
hazerd_unit u0(.rs1D(rs1D),
			   .rs2D(rs2D),
			   .rdE(rdE),
			   .rs1E(rs1E),
			   .rs2E(rs2E),
			   .pc_sel(pc_sel_real),
			   .result_selE(result_selE[0]),
			   .rdM(rdM),
			   .reg_writeM(reg_writeM),
			   .rdW(rdW),
			   .reg_writeW(reg_writeW),
			   .forwardAE(forwardAE),
			   .forwardBE(forwardBE),
			   .stallF(stallF),
			   .stallD(stallD),
			   .flushD(flushD),
			   .flushE(flushE));

//output assignment
assign pc_out = pcF;
assign alu_result_out = alu_resultM;


endmodule