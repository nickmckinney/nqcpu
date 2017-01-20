module regWrite_stage (
	input clk,
	input en,
	
	// incoming control signals
	input [21:0] ctrl_i,

	// register file
	output [2:0] rf_regDest,
	output [15:0] rf_dataIn,
	output rf_we,
	output rf_hb,
	output rf_lb,
	
	// pc
	output setPC_o,
	output [15:0] setPCValue_o
);

	wire [15:0] data_out_i;  // to write out to memory
	wire [1:0] reg_write_i;  // {write data_out to high byte, write data_out to low byte}
	wire [2:0] reg_dest_i;   // which register to write to
	wire setPC_i;            // write data_out to PC

	assign {
		data_out_i,
		reg_write_i,
		reg_dest_i,
		setPC_i} = ctrl_i;

	assign rf_we = en & |reg_write_i;
	assign rf_hb = en & reg_write_i[1];
	assign rf_lb = en & reg_write_i[0];
	assign rf_regDest = reg_dest_i;
	assign rf_dataIn = data_out_i;
	
	assign setPC_o = en & setPC_i;
	assign setPCValue_o = data_out_i;
endmodule
