module test_led_ram (
	input clk,
	
	output needWait_o,
	input addr_i,
	input re_i,
	input we_i,
	inout [15:0] data_io,
	
	output [6:0] hex_0,
	output [6:0] hex_1,
	output [6:0] hex_2,
	output [6:0] hex_3
);

	reg [15:0] currentData;
	
	assign data_io = re_i ? currentData : 16'hZ;
	assign needWait_o = 1'b0;
	
	always @(posedge clk) begin
		if(we_i) currentData <= data_io;
	end
	
	driver_7seg digit0 (
		.binary(currentData[3:0]),
		.leds(hex_0)
	);
	driver_7seg digit1 (
		.binary(currentData[7:4]),
		.leds(hex_1)
	);
	driver_7seg digit2 (
		.binary(currentData[11:8]),
		.leds(hex_2)
	);
	driver_7seg digit3 (
		.binary(currentData[15:12]),
		.leds(hex_3)
	);

endmodule
