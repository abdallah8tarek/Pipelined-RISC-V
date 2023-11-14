module top_tb ();

localparam t = 20;

reg clk,reset_F,reset_D,reset_E,reset_M,reset_W,pc_sel,en_F,en_D;
wire write_en;
wire [31:0] instr,pc_out,write_data;
wire [31:0] alu_result;
wire [31:0] read_data;
reg [31:0] address;

//top_module (clk,reset_F,reset_D,reset_E,reset_M,reset_W,pc_sel,en_F,en_D,
//			  instr,read_data,pc_out,write_en,write_data,alu_result);
top_module t1(.clk(clk),
			  .reset_F(reset_F),
			  .reset_D(reset_D),
			  .reset_E(reset_E),
			  .reset_M(reset_M),
			  .reset_W(reset_W),
			  .pc_sel(pc_sel),
			  .en_F(en_F),
			  .en_D(en_D),
			  .instr(instr),
			  .read_data(read_data),
			  .pc_out(pc_out),
			  .write_en(write_en),
			  .write_data(write_data),
			  .alu_result(alu_result));

//instruction_memory (address,data_out,clk);
instruction_memory instruct(.address (pc_out),
					  .data_out (instr),
					  .clk (clk));
				
assign address = alu_result;				

ram data_mem(.address(address),
			 .data_in(write_data),
			 .data_out(read_data),
			 .clk(clk),
			 .we(write_en));

initial 
begin
	clk = 0;
	forever #(t/2) clk = ~clk;
end

initial 
begin
	reset_F = 1'b1;
	reset_D = 1'b1;
	reset_E = 1'b1;
	reset_M = 1'b1;
	reset_W = 1'b1;
	pc_sel = 1'b0;
	{en_F, en_D} = {2{1'b0}};
	#t
	reset_F = 1'b0;    	//to free the Featch reset
	reset_D = 1'b0;		//to free the Decode reset
	#t
	reset_E = 1'b0;#t	//to free the Execute reset
	reset_M = 1'b0;#t 	//to free the Memory reset
	reset_W = 1'b0;		//to free the Write_back reset
	pc_sel = 1'b1;		//to free pc_sel
	{en_F, en_D} = {2{1'b1}};	//to free the Featch and Decode enable
	#t

	#(t*50)    ///wait for the program to finish
	
	address = 32'h60;#t
	if (read_data == 32'h7)
	begin
		$display ("success in add 0x60");
		address = 32'h84;#t
		if (read_data == 32'h19)
		begin 
			$display ("success in add 0x64");
			address = 32'h2;#t
			if (read_data == 32'h7)
			begin
				$display ("success in add 0x2");
				address = 32'hf;#t
				if (read_data != 32'h44)
				begin
					$display ("success jalr jumping");
					address = 32'h14;#t
					if (read_data == 32'h88)
						begin
							$display ("success in add 0x14");
							address = 32'h1e;#t
							if (read_data == 32'hc)
							begin
								$display ("success in add 0x1e");
								address = 32'h1f;#t
								if (read_data == 32'hc)
								begin
									$display ("success in add 0x1f");
									address = 32'h1a;#t
									if (read_data == 32'h7)
									begin
										$display ("success in add 0x1a");
										address = 32'h1b;#t
										if (read_data == 32'h7)
											$display ("success in add 0x1b");
										else
											$display ("failure in add 0x1b");
									end
									else
										$display ("failure in add 0x1a");
								end
								else
									$display ("failure in add 0x1f");
							end
							else
								$display ("failure in add 0x1e");
						end
						else 
							$display ("failure in add 0x64");
					end
					else 
						$display ("failure jalr jumping");
				end
				else
					$display ("failure in add 0x2");
			end
			else
				$display ("failure in add 0x64");
		end
		else
			$display ("failure in 0x60");
	$stop;
end

endmodule