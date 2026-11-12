module pc #(
    parameter WIDTH = 32
) (
    input  logic             clk,
    input  logic             rst,
    input  logic             PCsrc,
    input  logic [WIDTH-1:0] ImmOp,
    output logic [WIDTH-1:0] PC
);

    logic [WIDTH-1:0] inc_PC;
    logic [WIDTH-1:0] branch_PC;
    logic [WIDTH-1:0] next_PC;

    assign inc_PC    = PC + 4;
    assign branch_PC = PC + ImmOp;

    mux #(.DATA_WIDTH(WIDTH)) pc_mux (
        .in0 (inc_PC),
        .in1 (branch_PC),
        .sel (PCsrc),
        .out (next_PC)
    );

    always_ff @(posedge clk) begin
        if (rst) PC <= '0;
        else     PC <= next_PC;
    end

endmodule
