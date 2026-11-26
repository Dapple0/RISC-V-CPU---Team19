
module control_unit #(
    parameter WIDTH = 32
) (
    input  logic [WIDTH-1:0] instr,
    input logic EQ,
    output logic RegWrite,
    output logic [2:0]ALUctrl,
    output logic ALUsrc,
    output logic [2:0]ImmSrc,
    output logic PCsrc,
    output logic MemWrite,
    output logic [1:0]ResultSrc
);
logic [6:0] opcode;
logic [2:0] funct3;
logic [6:0] funct7;
assign opcode = instr[6:0];
assign funct3 = instr[14:12];
assign funct7 = instr[31:25];

always_comb begin              // Immsrc: I-type = 000, S-type = 001, B-type = 010, U-type = 011, J-type = 100,
    case (opcode)              // Aluctrl: ADD = 000, SUB = 001, XOR = 010, AND = 011, SLL = 100, SRL = 101
    7'b0010011: case(funct3)
                3'b000: begin           //addi
                RegWrite = 1'b1;
                ALUctrl =3'b000;
                ALUsrc =1'b1;
                ImmSrc= 3'b000;
                PCsrc = 1'b0;
                MemWrite = 1'b0;
                ResultSrc = 2'b00;
                end
                3'b111:  begin      // andi
                RegWrite = 1'b1;
                ALUctrl =3'b011;
                ALUsrc =1'b1;
                ImmSrc= 3'b000;
                PCsrc = 1'b0;
                MemWrite = 1'b0;
                ResultSrc = 2'b00;
                end
                3'b101:  begin      // srli
                RegWrite = 1'b1;
                ALUctrl =3'b101;
                ALUsrc =1'b1;
                ImmSrc= 3'b000;
                PCsrc = 1'b0;
                MemWrite = 1'b0;
                ResultSrc = 2'b00;
                end
                3'b001:  begin      // slli
                RegWrite = 1'b1;
                ALUctrl =3'b100;
                ALUsrc =1'b1;
                ImmSrc= 3'b000;
                PCsrc = 1'b0;
                MemWrite = 1'b0;
                ResultSrc = 2'b00;
                end
                default:begin
                RegWrite = 1'b0;
                ALUctrl =3'b000;
                ALUsrc =1'b0;
                ImmSrc= 3'b000;
                PCsrc = 1'b0;
                MemWrite = 1'b0;
                ResultSrc = 2'b00;
                end

    endcase
    7'b1100011: case(funct3)       //bne
                3'b001: begin
                RegWrite = 1'b0;
                ALUctrl =3'b001;
                ALUsrc =1'b0;
                ImmSrc= 3'b010;
                PCsrc = !EQ;
                MemWrite = 1'b0;
                ResultSrc = 2'b00;
                end
                3'b000: begin                //beq
                RegWrite = 1'b0;
                ALUctrl =3'b001;
                ALUsrc =1'b0;
                ImmSrc= 3'b010;
                PCsrc = EQ;
                MemWrite = 1'b0;
                ResultSrc = 2'b00;
                end
                default: begin
                RegWrite  = 1'b0;
                ALUctrl   = 3'b000;
                ALUsrc    = 1'b0;
                ImmSrc    = 3'b000;
                PCsrc     = 1'b0;
                MemWrite  = 1'b0;
                ResultSrc = 2'b00;
                end

    endcase

    7'b0110011: case(funct3)
                3'b000: begin      //add
                RegWrite = 1'b1;
                ALUctrl =3'b000;
                ALUsrc =1'b0;
                ImmSrc= 3'b000;
                PCsrc = 1'b0;
                MemWrite = 1'b0;
                ResultSrc = 2'b00;
                end
                3'b100: begin      // xor
                RegWrite = 1'b1;
                ALUctrl =3'b010;
                ALUsrc =1'b0;
                ImmSrc= 3'b000;
                PCsrc = 1'b0;
                MemWrite = 1'b0;
                ResultSrc = 2'b00;
                end
                default:begin
                RegWrite = 1'b0;
                ALUctrl =3'b000;
                ALUsrc =1'b0;
                ImmSrc= 3'b000;
                PCsrc = 1'b0;
                MemWrite = 1'b0;
                ResultSrc = 2'b00;
                end
    endcase
    7'b0110111 :  begin      //lui
    RegWrite = 1'b1;
    ALUctrl =3'b000;
    ALUsrc =1'b0;
    ImmSrc= 3'b011;
    PCsrc = 1'b0;
    MemWrite = 1'b0;
    ResultSrc = 2'b11;
    end
    7'b0000011:  begin      //lbu
    RegWrite = 1'b1;
    ALUctrl =3'b000;
    ALUsrc =1'b1;
    ImmSrc= 3'b000;
    PCsrc = 1'b0;
    MemWrite = 1'b0;
    ResultSrc = 2'b01;
    end
    7'b0100011:  begin      //sb
    RegWrite = 1'b0;
    ALUctrl =3'b000;
    ALUsrc =1'b1;
    ImmSrc= 3'b001;
    PCsrc = 1'b0;
    MemWrite = 1'b1;
    ResultSrc = 2'b00;
    end
    7'b1101111:  begin      //jal
    RegWrite = 1'b1;
    ALUctrl =3'b000;
    ALUsrc =1'b1;
    ImmSrc= 3'b100;
    PCsrc = 1'b1;
    MemWrite = 1'b0;
    ResultSrc = 2'b10;
    end
    7'b1100111:  begin      // jalr
    RegWrite = 1'b1;
    ALUctrl =3'b000;
    ALUsrc =1'b1;
    ImmSrc= 3'b000;
    PCsrc = 1'b1;
    MemWrite = 1'b0;
    ResultSrc = 2'b10;
    end
    default:begin
    RegWrite = 1'b0;
    ALUctrl =3'b000;
    ALUsrc =1'b0;
    ImmSrc= 3'b000;
    PCsrc = 1'b0;
    MemWrite = 1'b0;
    ResultSrc = 2'b00;
    end

    endcase
end
endmodule
