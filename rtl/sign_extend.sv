module Sign_Extend #(
    parameter WIDTH = 32
) (
    input  logic [WIDTH-1:0] instr,
    input  logic [2:0]ImmSrc,
    output logic [WIDTH-1:0] ImmOp

);
always_comb begin
    case(ImmSrc)                                  // I-type = 000, S-type = 001, B-type = 010, U-type = 011, J-type = 100, R-type = 101
        3'b000: begin          // I-type
            ImmOp = {{20{instr[31]}}, instr[31:20]};
        end
        3'b010:  begin         //B-type
            ImmOp = {{19{instr[31]}},instr[31],instr[7],instr[30:25],instr[11:8],1'b0};            
        end
        3'b001: begin          //S-type
            ImmOp = {{20{instr[31]}},instr[31:25],instr[11:7]};
        end
        3'b011: begin          //U-type
            ImmOp = {instr[31:12], 12'b0};
        end
        3'b100: begin          //J-type
            ImmOp = {{11{instr[31]}},instr[31],instr[19:12],instr[20],instr[30:21],1'b0};
        end
        default: ImmOp = 32'b0;

    endcase
end

endmodule