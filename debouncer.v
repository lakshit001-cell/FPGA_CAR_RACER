`timescale 1ns / 1ps

module debounce (
    input wire clk,       // System clock (100MHz)
    input wire btn_in,    // Raw button input
    output reg btn_out    // Debounced button output
);


    parameter COUNTER_MAX = 20'd1048575; 
    
    reg [19:0] counter = 0;
    reg last_state = 0;




    always @(posedge clk) begin
        if (btn_in != last_state) begin

            counter <= 0;
            last_state <= btn_in;
        end 
        else if (counter < COUNTER_MAX) begin
 
            counter <= counter + 1;
        end 
        else begin

            btn_out <= last_state;
        end
    end

endmodule
