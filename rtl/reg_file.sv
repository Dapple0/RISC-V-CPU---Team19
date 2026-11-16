module reg_file #(
    parameter WIDTH = 32
) (
    input logic              clk,
    input logic [4:0]        AD1,
    input logic [4:0]        AD2,
    input logic [4:0]        AD3,
    input logic              WE3,
    input logic [WIDTH-1:0]  WD3,
    output logic [WIDTH-1:0] RD1,
    output logic [WIDTH-1:0] RD2,
    output logic [WIDTH-1:0]  a0

);
    
    logic [WIDTH-1:0] registers [31:0];
    
    // Register file based on Harris and Harris
    // Asynchronous reads. Register 0 is hardwired to 0 using '0, not sure if correct formatting would be to keep it as 32'd0)

    assign RD1 = (AD1 != 5'd0) ? registers[AD1] : '0;
    assign RD2 = (AD2 != 5'd0) ? registers[AD2] : '0;
    assign a0  =  registers[10];

    always_ff @(posedge clk) begin
        if (WE3)
           registers[AD3] <= WD3;
    end

endmodule
