module alu #(
    parameter WIDTH = 32
) (
    input logic              ALUctrl,   
    input logic [WIDTH-1:0]  ALUop1,
    input logic [WIDTH-1:0]  ALUop2,
    output logic             EQ,
    output logic [WIDTH-1:0] ALUout
); 

    assign ALUout = ALUctrl ? (ALUop1 - ALUop2) : (ALUop1 + ALUop2);
    assign EQ = (ALUop1 == ALUop2);

endmodule
