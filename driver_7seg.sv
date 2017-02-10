module driver_7seg (
	input [3:0] binary,
	output [6:0] leds
);

	// leds is 6543210 as follows:
	//
	//     0
	//    ---
	// 5 |   | 1
	//    --- <----- 6
	// 4 |   | 2
	//    ---
	//     3
	//
	// a 0 means light is ON, 1 means light is OFF
	// (cathode is attached to FPGA, anode has +3.3V, so a 0 results in a voltage difference and turns the LED on)

	assign leds =
		binary == 4'h0 ? 7'b1000000 :
		binary == 4'h1 ? 7'b1111001 :
		binary == 4'h2 ? 7'b0100100 :
		binary == 4'h3 ? 7'b0110000 :
		binary == 4'h4 ? 7'b0011001 :
		binary == 4'h5 ? 7'b0010010 :
		binary == 4'h6 ? 7'b0000010 :
		binary == 4'h7 ? 7'b1111000 :
		binary == 4'h8 ? 7'b0000000 :
		binary == 4'h9 ? 7'b0010000 :
		binary == 4'hA ? 7'b0001000 :
		binary == 4'hB ? 7'b0000011 :
		binary == 4'hC ? 7'b1000110 :
		binary == 4'hD ? 7'b0100001 :
		binary == 4'hE ? 7'b0000110 :
		                 7'b0001110;

endmodule
