`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/11/2026 11:54:16 AM
// Design Name: 
// Module Name: TimingGenerator_tb
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


module TimingGenerator_tb();


reg Clk ; 
reg nRst ; 
wire vSync ; 
wire hSync; 
wire de ; 
wire integer x ; 
wire integer y ; 


initial begin 

    nRst = 0 ; 
    #100 
    nRst = 1 ;
    
end 

initial begin 

    Clk = 0 ; 
    forever #6.7
    Clk = ~Clk ;

end 


TimingGenerator TimingGeneratorDUT (
.PxlCLk(Clk), 
.nRst(nRst) ,
    
.vSync(vSync) ,
.hSync(hSync) ,
.de(de) ,
.x(x),
.y(y)
   
    );
endmodule
