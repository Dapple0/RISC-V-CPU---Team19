module Control_Unit #(
    parameter WIDTH = 32
) (
    input  logic [WIDTH-1:0] instr,
    input logic EQ,
    output logic RegWrite,
    output logic ALUctrl,
    output logic ALUsrc,
    output logic ImmSrc,
    output logic PCsrc

);
logic [6:0] opcode;
assign opcode = instr[6:0];

always_comb begin
    case (opcode)
    7'b0010011: begin  //addi
    RegWrite = 1'b1;
    ALUctrl =1'b0;
    ALUsrc =1'b1;
    ImmSrc= 1'b0;
    PCsrc = 1'b0;
    end
    7'b1100011:  begin      //bne
    RegWrite = 1'b0; 
    ALUctrl =1'b1;
    ALUsrc =1'b0;
    ImmSrc= 1'b1;
    PCsrc = !EQ;
    end
    default:begin
    RegWrite = 1'b0;
    ALUctrl =1'b0;
    ALUsrc =1'b0;
    ImmSrc= 1'b0;
    PCsrc = 1'b0;
    end

    endcase
end
endmodule