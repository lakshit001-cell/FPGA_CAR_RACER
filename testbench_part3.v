`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Module Name: part3_rival_car_tb
// Description: Testbench for Display_sprite Part 3.
//              Tests: START -> IDLE, rival car spawning, and rival car movement.
//////////////////////////////////////////////////////////////////////////////////

module part3_rival_car_tb;

    // --- Inputs ---
    reg clk;
    reg BTNL, BTNR, BTNC;

    // --- Outputs ---
    wire HS, VS;
    wire [11:0] vgaRGB;

    // --- Internal Wires to Monitor FSM & Rival Car ---
    wire [2:0]  fsm_state = uut.current_state;
    wire [9:0]  rival_pos_x = uut.rival_x;
    wire [9:0]  rival_pos_y = uut.rival_y;
    wire        rival_is_active = uut.rival_active;
    wire [7:0]  lfsr_val = uut.rival_lfsr_out;


    // --- Instantiate the Module Under Test ---
    Display_sprite uut (
        .clk(clk),
        .BTNL(BTNL),
        .BTNR(BTNR),
        .BTNC(BTNC),
        .HS(HS),
        .VS(VS),
        .vgaRGB(vgaRGB)
    );

    // --- Clock Generation (100MHz) ---
    parameter CLK_PERIOD = 10; // 10ns = 100MHz
    
    initial begin
        clk = 0;
        forever #(CLK_PERIOD / 2) clk = ~clk;
    end

    // --- Stimulus ---
    initial begin
        $display("T=%0t: --- Testbench Started ---", $time);
        BTNL = 0;
        BTNR = 0;
        BTNC = 0;
        
        #1000;
        $display("T=%0t: Initial state. FSM State: %b", $time, fsm_state);

        
        // 1. Press BTNC to start the game (START -> IDLE)
        $display("T=%0t: Pressing BTNC to start game", $time);
        BTNC = 1;
        #50_000_000; // Hold for 50ms
        BTNC = 0;
        #50_000_000; // Wait
        $display("T=%0t: Game running. FSM State: %b", $time, fsm_state);
        
        // 2. Wait for the game to run for many frames
        // A 640x480@60Hz frame is ~16.7ms.
        // Let's wait for 500ms (approx 30 frames)
        // This will allow the rival car to spawn and move several times.
        $display("T=%0t: Waiting 500ms for rival car to spawn and move...", $time);
        
        // We can monitor the rival car's state as it changes
        // This requires the simulation to run, as these signals
        // are on the pixel_clock domain.
        
        // Monitor the rival car's Y position
        // It should start at 0, then go to 150 (OFFSET_BG_Y), then 151, 152...
        $monitor("T=%0t: FSM=%b, Rival Active=%b, Rival Y=%d, Rival X=%d, LFSR=%h", 
                 $time, fsm_state, rival_is_active, rival_pos_y, rival_pos_x, lfsr_val);
        
        #500_000_000; // Wait 500ms

        // 3. Force a collision (Optional, but good to test)
        // This requires knowing the rival's position, which is hard in a 
        // simple testbench. For now, we'll just test the reset.
        
        // 4. Test Reset (COLLIDE -> START)
        $display("T=%0t: Forcing game to COLLIDE state", $time);
        // We can't easily force a rival collision, so let's force a 
        // wall collision just to get to the COLLIDE state.
        BTNL = 1;
        #600_000_000; // Hold long enough to hit the wall
        BTNL = 0;
        #50_000_000;
        $display("T=%0t: Game in COLLIDE state. FSM State: %b", $time, fsm_state);

        $display("T=%0t: Pressing BTNC to reset (COLLIDE -> START)", $time);
        BTNC = 1;
        #50_000_000;
        BTNC = 0;
        #50_000_000;
        $display("T=%0t: Game reset to START. FSM State: %b", $time, fsm_state);

                 
        $display("T=%0t: --- Test Complete ---", $time);
        $stop;
    end

endmodule