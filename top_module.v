module top_module (clk,reset_F,reset_D,reset_E,reset_M,reset_W,pc_sel
					,en_F,en_D,instr,read_data,pc_out,write_en
					,write_data,alu_result);

input clk,reset_F,reset_D,reset_E,reset_M,reset_W,pc_sel,en_F,en_D;
input [31:0] instr,read_data;

output [31:0] pc_out,write_data,alu_result;
output write_en;

//control_unit (instr,zero,result_sel,mem_write,alu_sel,imm_sel,reg_write
//				,alu_control,jalr_sel,bne_beq_sel);
wire alu_sel,reg_write,jalr_sel,bne_beq_sel,jump,branch,mem_write;
wire [1:0] result_sel,imm_sel;
wire [2:0] alu_control;
wire [31:0] instrD;
control_unit c1(.instr(instrD),
				.result_sel(result_sel),
				.mem_write(mem_write),
				.alu_sel(alu_sel),
				.imm_sel(imm_sel),
				.reg_write(reg_write),
				.alu_control(alu_control),
				.jalr_sel(jalr_sel),
				.bne_beq_sel(bne_beq_sel),
				.jump(jump),
				.branch(branch));

//datapath (instr,instrD,read_data,clk,reset_F,reset_D,reset_E,reset_M
//			,reset_W,pc_sel,en_F,en_D,reg_write,alu_sel,alu_control,result_sel
//			,imm_sel,zero,pc_out,alu_result_out,write_dataM,jalr_sel,bne_beq_sel
//  		,jump,branch,mem_write,mem_writeM);
datapath d1(.instr(instr),
			.instrD(instrD),
			.read_data(read_data),
			.clk(clk),
			.reset_F(reset_F),
			.reset_D(reset_D),
			.reset_E(reset_E),
			.reset_M(reset_M),
			.reset_W(reset_W),
			.pc_sel(pc_sel),
			.en_F(en_F),
			.en_D(en_D),
			.reg_write(reg_write),
			.alu_sel(alu_sel),
			.alu_control(alu_control),
			.result_sel(result_sel),
			.imm_sel(imm_sel),
			.pc_out(pc_out),
			.alu_result_out(alu_result),
			.write_dataM(write_data),
			.jalr_sel(jalr_sel),
			.bne_beq_sel(bne_beq_sel),
			.jump(jump),
			.branch(branch),
			.mem_write(mem_write),
			.mem_writeM(write_en));
endmodule


