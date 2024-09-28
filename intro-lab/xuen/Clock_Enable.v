//////////////////////////////////////////////////////////////////////////////////
// This module is to generate an enable signal for different display frequency based on pushbuttons
// Fill in the blank to complete this module 
// (c) Gu Jing, ECE, NUS
//////////////////////////////////////////////////////////////////////////////////

module Clock_Enable(
	input clk,			// fundamental clock 100 MHz
	input btnU,			// button BTNU for 4Hz speed
	input btnC,			// button BTNC for pause
	output reg enable);	// output signal used to enable the reading of next memory data

// define reg threshold to allow 4hz or 1hz frequency

reg [25:0] threshold; //26 bit cos need 26 bit counter

// define reg counter to be able to count to certain threshold value

reg [25:0] counter; //26 bit cos need 26 bit counter

initial
begin
	counter <= 0;
	enable <= 0;
end
	
	
// complete this always block by determining the enable output by counter, threshold and buttons 
always @(posedge clk)
begin
    // count speed depends on btnU
    // use non-blocking assignment inside always block
    // as the variables are updated togehter at the end of the time step
    // using 2^24 and 2^26 
    // 4Hz (0.250s) 1Hz (1s) 
    threshold <= (btnU) ? 26'h0fffffe : 26'h3fffffe;
    
    // threshold for sims
    // 16Hz and 4Hz
    //threshold <= (btnU) ? 26'h03fffff : 26'h0fffffe;
    
    if (btnC) 
        enable <= 1'b0;
	else
    begin
	   counter <= counter + 1;
	   if (counter > threshold)
	   begin
	       enable <= 1'b1;
	       counter <= 1'b0;
	   end
	   else
	       enable <= 1'b0;
	end
	
end
	
endmodule
