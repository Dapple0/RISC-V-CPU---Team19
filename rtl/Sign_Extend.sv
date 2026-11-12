module Sign_Extend #(
    parameter WIDTH = 32
) (
    input  logic [WIDTH-1:0] instr,
    input  logic ImmSrc,
    output logic [WIDTH-1:0] ImmOp

);
always_comb begin
    case(ImmSrc)
        1'b0: begin          //addi
            ImmOp = {{20{instr[31]}}, instr[31:20]};
        end
        1'b1:  begin         //bne
            ImmOp = {{19{instr[31]}},instr[31],instr[7],instr[30:25],instr[11:8],1'b0};            
        end
    endcase
end

endmodule