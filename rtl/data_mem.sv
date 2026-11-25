// Data memory: 128 KB (0x00000 - 0x1FFFF), byte-addressed, little-endian.
// Reads are asynchronous (combinational), writes happen on the rising clock edge.
// funct3 (straight from the load/store instruction) picks the access size:
//   000 lb / sb   (byte, loads sign-extend)
//   001 lh / sh   (half-word, loads sign-extend)
//   010 lw / sw   (word)
//   100 lbu       (byte, zero-extend)
//   101 lhu       (half-word, zero-extend)
module data_mem #(
    parameter ADDR_WIDTH = 17,          // 2^17 bytes = 0x20000 = 128 KB
    parameter DATA_WIDTH = 32
) (
    input  logic                  clk,
    // only A[16:0] is used (128 KB), so stop Verilator warning about the top bits
    // verilator lint_off UNUSEDSIGNAL
    input  logic [DATA_WIDTH-1:0] A,      // address (from the ALU)
    // verilator lint_on UNUSEDSIGNAL
    input  logic [DATA_WIDTH-1:0] WD,     // value to store (rs2)
    input  logic                  WE,     // 1 = write on this clock edge (MemWrite)
    input  logic [2:0]            funct3, // access size: byte / half / word
    output logic [DATA_WIDTH-1:0] RD      // loaded value, top bits already filled in
);

    logic [7:0] mem [0:2**ADDR_WIDTH-1];

    // The reference programs expect their data (e.g. gaussian.mem) at 0x10000
    initial begin
        $readmemh("data.hex", mem, 'h10000);
    end

    // Addresses of the 4 bytes of the access (wrap within the 128 KB space)
    logic [ADDR_WIDTH-1:0] addr0, addr1, addr2, addr3;
    assign addr0 = A[ADDR_WIDTH-1:0];
    assign addr1 = addr0 + 1;
    assign addr2 = addr0 + 2;
    assign addr3 = addr0 + 3;

    // Loads: little-endian, so the byte at the lowest address is the least significant
    always_comb begin
        case (funct3)
            3'b000:  RD = {{24{mem[addr0][7]}}, mem[addr0]};                       // lb
            3'b001:  RD = {{16{mem[addr1][7]}}, mem[addr1], mem[addr0]};           // lh
            3'b100:  RD = {24'b0, mem[addr0]};                                     // lbu
            3'b101:  RD = {16'b0, mem[addr1], mem[addr0]};                         // lhu
            default: RD = {mem[addr3], mem[addr2], mem[addr1], mem[addr0]};        // lw
        endcase
    end

    // Stores: only write the bytes the instruction asks for
    always_ff @(posedge clk) begin
        if (WE) begin
            case (funct3[1:0])
                2'b00: mem[addr0] <= WD[7:0];                                      // sb
                2'b01: begin                                                       // sh
                    mem[addr0] <= WD[7:0];
                    mem[addr1] <= WD[15:8];
                end
                default: begin                                                     // sw
                    mem[addr0] <= WD[7:0];
                    mem[addr1] <= WD[15:8];
                    mem[addr2] <= WD[23:16];
                    mem[addr3] <= WD[31:24];
                end
            endcase
        end
    end

endmodule
