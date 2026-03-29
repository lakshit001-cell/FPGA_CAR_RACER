module lfsr #(parameter SEED = 8'h48)(
    input wire clk,
    input wire rst,
    input wire en,          // new
    output reg [7:0] dout
);
    wire feedback = dout[7] ^ dout[5] ^ dout[4] ^ dout[3];

    always @(posedge clk or posedge rst) begin
        if (rst)
            dout <= SEED;
        else if (en)
            dout <= {dout[6:0], feedback};
    end
endmodule
