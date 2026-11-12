module Instruction_mem #(
    parameter WIDTH = 32
) (
    input  logic [WIDTH-1:0] PC,
    output  logic [WIDTH-1:0] instr
);

logic [7:0] mem [0:1023];

initial begin
    $readmemh("program.hex", mem);
end

assign instr = {mem[PC + 3],mem[PC + 2],mem[PC + 1],mem[PC]};//Clarify if there is a better way to do this? Maybe readmemh but 4bytes at a time


endmodule