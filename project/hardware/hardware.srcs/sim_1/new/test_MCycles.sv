`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: NUS
// Engineer: Shahzor Ahmad, Rajesh C Panicker
// 
// Create Date: 27.09.2016 16:55:23
// Design Name: 
// Module Name: test_MCycle
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////
/* 
----------------------------------------------------------------------------------
--	(c) Shahzor Ahmad, Rajesh C Panicker
--	License terms :
--	You are free to use this code as long as you
--		(i) DO NOT post it on any public repository;
--		(ii) use it only for educational purposes;
--		(iii) accept the responsibility to ensure that your implementation does not violate any intellectual property of ARM Holdings or other entities.
--		(iv) accept that the program is provided "as is" without warranty of any kind or assurance regarding its suitability for any particular purpose;
--		(v) send an email to rajesh.panicker@ieee.org briefly mentioning its use (except when used for the course CG3207 at the National University of Singapore);
--		(vi) retain this notice in this file or any files derived from this.
----------------------------------------------------------------------------------
*/

module test_MCycle(

    );
    
    // DECLARE INPUT SIGNALs
    reg CLK = 0 ;
    reg RESET = 0 ;
    reg Start = 0 ;
    reg [1:0] MCycleOp = 0 ;
    reg [3:0] Operand1 = 0 ;
    reg [3:0] Operand2 = 0 ;

    // DECLARE OUTPUT SIGNALs
    wire [3:0] Result1 ;
    wire [3:0] Result2 ;
    wire Busy ;
    
    // INSTANTIATE DEVICE/UNIT UNDER TEST (DUT/UUT)
    MCycle #(
        .width(4)
    ) dut ( 
        .CLK(CLK), 
        .RESET(RESET), 
        .Start(Start), 
        .MCycleOp(MCycleOp), 
        .Operand1(Operand1), 
        .Operand2(Operand2), 
        .MCycle_Result1(Result1), 
        .MCycle_Result2(Result2), 
        .Busy(Busy)
    );
    
    // STIMULI
    initial begin
        #10 ; // Hold reset state for 100ns.    
        Start = 1'b0;

        
        /* SIGNED MULTIPLICATION */
        MCycleOp = 2'b00;

        // -1 * -1 = 1
        Operand1 = 4'b1111; // -1
        Operand2 = 4'b1111; // -1
        Start = 1'b1;          

        wait(Busy);
        wait(~Busy);
        assert(Result1 == 4'b0001 && Result2 == 4'b0000) 
                else $error("SM: -1 * -1; R1: %b; R2: %b", Result1, Result2);

        #10;
        Start = 1'b0;
        #10;
        
        // -2 * -1 = 2
        Operand1 = 4'b1110 ; // -2
        Operand2 = 4'b1111 ; // -1
        Start = 1'b1;
        
        wait(Busy) ; 
        wait(~Busy) ;
        assert(Result1 == 4'b0010 && Result2 == 4'b0000)
                else $error("SM: -2 * -1; R1: %b; R2: %b", Result1, Result2);

        #10 ;
        Start = 1'b0 ;
        #10 ;

        // -2 * 5 = -10
        Operand1 = 4'b1110 ; // -2
        Operand2 = 4'b0101 ; // 5
        Start = 1'b1;
        
        wait(Busy) ; 
        wait(~Busy) ;
        assert(Result1 == 4'b0110 && Result2 == 4'b1111)
                else $error("SM: -2 * 5; R1: %b; R2: %b", Result1, Result2);


        #10 ;
        Start = 1'b0 ;
        #10 ;

        // 2 * -3 = -6
        Operand1 = 4'b0010 ; // 2
        Operand2 = 4'b1101 ; // -3
        Start = 1'b1;
        
        wait(Busy) ; 
        wait(~Busy) ;
        assert(Result1 == 4'b1010 && Result2 == 4'b1111)
                else $error("SM: 2 * -3; R1: %b; R2: %b", Result1, Result2);

        #10 ;
        Start = 1'b0 ;
        #10 ;


        /* UNSIGNED MULTIPLICATION */
        MCycleOp = 2'b01 ;

        // 15 * 15 = 225
        Operand1 = 4'b1111 ; // 15
        Operand2 = 4'b1111 ; // 15
        Start = 1'b1 ;

        wait(Busy) ; 
        wait(~Busy) ; 
        assert(Result1 == 4'b0001 && Result2 == 4'b1110)
                else $error("USM: 15 * 15; R1: %b; R2: %b", Result1, Result2);

        #10 ;
        Start = 1'b0 ;
        #10 ;

        // 14 * 15 = 210
        Operand1 = 4'b1110 ; // 14
        Operand2 = 4'b1111 ; // 15
        Start = 1'b1 ;

        wait(Busy) ; 
        wait(~Busy) ; 
        assert(Result1 == 4'b0010 && Result2 == 4'b1101)
                else $error("USM: 14 * 15; R1: %b; R2: %b", Result1, Result2);

        #10;
        Start = 1'b0 ;
        #10

        // 6 * 7 = 42
        Operand1 = 4'b0110 ; // 6
        Operand2 = 4'b0111 ; // 7
        Start = 1'b1 ;

        wait(Busy) ; 
        wait(~Busy) ; 
        assert(Result1 == 4'b1010 && Result2 == 4'b0010)
                else $error("USM: 6 * 7; R1: %b; R2: %b", Result1, Result2);

        #10;
        Start = 1'b0 ;
        #10

        // 2 * 0 = 0
        Operand1 = 4'b0010 ; // 2
        Operand2 = 4'b0000 ; // 0
        Start = 1'b1 ;

        wait(Busy) ; 
        wait(~Busy) ; 
        assert(Result1 == 4'b0000 && Result2 == 4'b0000)
                else $error("USM: 2 * 0; R1: %b; R2: %b", Result1, Result2);

        #10;
        Start = 1'b0 ;
        #10


        /* SIGNED DIVISION */
        MCycleOp = 2'b10;

        // -6 / 2 = -3
        Operand1 = 4'b1010; // -6
        Operand2 = 4'b0010; // 2
        Start = 1'b1;

        wait(Busy);
        wait(~Busy);
        assert(Result1 == 4'b1101 && Result2 == 4'b0000)
                else $error("SD: -6 / 2; R1: %b; R2: %b", Result1, Result2);

        #10;
        Start = 1'b0;
        #10;

        // -7/-2 = 3 (+1 rem)
        Operand1 = 4'b1001; // -7
        Operand2 = 4'b1110; // -2
        Start = 1'b1 ;

        wait(Busy);
        wait(~Busy);
        assert(Result1 == 4'b0011 && Result2 == 4'b0001)
                else $error("SD: -7 / -2; R1: %b; R2: %b", Result1, Result2);

        #10;
        Start = 1'b0;
        #10;

        // 5 / 3 = 1 (+2 rem)
        Operand1 = 4'b0101; // 5
        Operand2 = 4'b0011; // 3
        Start = 1'b1 ;

        wait(Busy);
        wait(~Busy);
        assert(Result1 == 4'b0001 && Result2 == 4'b0010)
                else $error("SD: 5 / 3; R1: %b; R2: %b", Result1, Result2);

        #10;
        Start = 1'b0;
        #10;

        // 0 / -3 = 0 (0 rem)
        Operand1 = 4'b0000; // 0
        Operand2 = 4'b1101; // -3
        Start = 1'b1 ;

        wait(Busy);
        wait(~Busy);
        assert(Result1 == 4'b0000 && Result2 == 4'b0000)
                else $error("SD: 0 / -3; R1: %b; R2: %b", Result1, Result2);

        #10;
        Start = 1'b0;
        #10;

        /* UNSIGNED DIVISION */
        MCycleOp = 2'b11;

        // 15 / 4 = 3 (+3 rem)
        Operand1 = 4'b1111; // 15
        Operand2 = 4'b0100; // 4
        Start = 1'b1;

        wait(Busy);
        wait(~Busy);
        assert(Result1 == 4'b0011 && Result2 == 4'b0011)
                else $error("USD: 15 / 4; R1: %b; R2: %b", Result1, Result2);

        #10;
        Start = 1'b0;
        #10;

        // 7 / 8 = 0 (+7 rem)
        Operand1 = 4'b0111; // 7
        Operand2 = 4'b1000; // 8
        Start = 1'b1;

        wait(Busy);
        wait(~Busy);
        assert(Result1 == 4'b0000 && Result2 == 4'b0111)
                else $error("USD: 7 / 8; R1: %b; R2: %b", Result1, Result2);
        
        #10;
        Start = 1'b0;
        #10;

        // 0 / 8 = 0 (0 rem)
        Operand1 = 4'b0000; // 7
        Operand2 = 4'b1000; // 8
        Start = 1'b1;

        wait(Busy);
        wait(~Busy);
        assert(Result1 == 4'b0000 && Result2 == 4'b0000)
                else $error("USD: 0 / 8; R1: %b; R2: %b", Result1, Result2);

        #10;
        Start = 1'b0;
    end
     
    // GENERATE CLOCK       
    always begin 
        #5 CLK = ~CLK ; 
        // invert CLK every 5 time units 
    end
    
endmodule















