module regWrite_stage (
	input clk,
	input en,
	
	// incoming control signals
	input alu_signals ctrl_i,

	// register file
	output [3:0] rf_regDest,
	output [15:0] rf_dataIn,
	output rf_we,
	output rf_hb,
	output rf_lb,
	
	// pc
	output setPC_o,
	output [15:0] setPCValue_o
);

	assign rf_we = en & |ctrl_i.reg_write;
	assign rf_hb = en & ctrl_i.reg_write[1];
	assign rf_lb = en & ctrl_i.reg_write[0];
	assign rf_regDest = ctrl_i.reg_dest;
	assign rf_dataIn = ctrl_i.data_out;
	
	assign setPC_o = en & ctrl_i.setPC;
	assign setPCValue_o = ctrl_i.data_out;
endmodule
