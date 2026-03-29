


module Display_sprite #(
        // Size of signal to store  horizontal and vertical pixel coordinate
        parameter pixel_counter_width = 10,
        parameter OFFSET_BG_X = 200,
        parameter OFFSET_BG_Y = 150
    )
    (
        input clk,
        input BTNL,
        input BTNR,
        input BTNC,
        
        output HS, VS,
        output [11:0] vgaRGB
    );
    
    // -- Parameters ---
    localparam bg1_width = 160;
    localparam bg1_height = 240;
    localparam main_car_width = 14;
    localparam main_car_height = 16;
    
    
    // --- Wires and Regs ---
    wire pixel_clock;
    wire [3:0] vgaRed, vgaGreen, vgaBlue;
    wire [pixel_counter_width-1:0] hor_pix, ver_pix;
    reg [11:0] output_color;
    reg [11:0] next_color;
    reg bg_on, car_on;
    
    reg [15:0] bg_rom_addr;
    wire [11:0] bg_color;
    
    reg [7:0] car_rom_addr;
    wire [11:0] car_color;
    
    // --- PART 3: Rival Car Wires/Regs ---
    reg rival_car_on;
    reg [7:0] rival_car_rom_addr;
    wire [11:0] rival_car_color;
    wire [7:0] rival_lfsr_out;
    
    reg rival_active = 0;
    reg [pixel_counter_width-1:0] rival_x, rival_y;
    reg [7:0] rival_frame_counter;
    
    localparam RIVAL_SPEED = 1; 
    localparam RIVAL_X_RANGE = 61; 
    localparam RIVAL_X_MIN = 44;   


    // --- FSM and Control Logic ---
    localparam START   = 3'b000;
    localparam IDLE    = 3'b001;
    localparam LEFT_CAR  = 3'b010;
    localparam RIGHT_CAR = 3'b011;
    localparam COLLIDE = 3'b100;
    
    localparam LEFT_BOUNDARY = 244;
    localparam RIGHT_BOUNDARY = 318;
    localparam CAR_X_START = 270;
    localparam CAR_Y_START = 300;
    localparam CAR_SPEED = 1; 

    reg [2:0] current_state;
    reg [2:0] next_state; 
    reg [pixel_counter_width-1:0] car_x;
    reg [pixel_counter_width-1:0] car_y;
    reg [pixel_counter_width-1:0] next_car_x, next_car_y;

    wire btnl_debounced, btnr_debounced, btnc_debounced;

    // FSM Tick (50Hz)
    reg [21:0] tick_counter;
    wire fsm_tick;
    
    always @(posedge clk) begin
        if(BTNC) begin
            current_state = START;
            car_x = CAR_X_START;
            car_y = CAR_Y_START ;
            rival_frame_counter = 0;
            tick_counter =0;
            v_scroll_reg  = 0;
            frame_counter =0;
        end
    end
    
    `ifdef SIM
        localparam TICK_MAX = 22'd100;  // much faster in simulation
        assign pixel_clock = clk;
    `else
        localparam TICK_MAX = 22'd2000000;
    `endif
    
    assign fsm_tick = (tick_counter == TICK_MAX);
    
    always @ (posedge clk) begin
        if (tick_counter == TICK_MAX) tick_counter <= 0;
        else tick_counter <= tick_counter + 1;
    end
    
    // --- Instantiate Modules ---
    debounce debouncer_l ( .clk(clk), .btn_in(BTNL), .btn_out(btnl_debounced) );
    debounce debouncer_r ( .clk(clk), .btn_in(BTNR), .btn_out(btnr_debounced) );
    debounce debouncer_c ( .clk(clk), .btn_in(BTNC), .btn_out(btnc_debounced) );

    VGA_driver #( .WIDTH(pixel_counter_width) ) display_driver (
        .clk(clk), .vgaRed(vgaRed), .vgaGreen(vgaGreen), .vgaBlue(vgaBlue),
        .HS(HS), .VS(VS), .vgaRGB(vgaRGB),
        .pixel_clock(pixel_clock),
        .hor_pix(hor_pix), .ver_pix(ver_pix)
    );
    
    bg_rom bg1_rom ( .clka(clk), .addra(bg_rom_addr), .douta(bg_color) );
    main_car_rom car1_rom ( .clka(clk), .addra(car_rom_addr), .douta(car_color) );
    
    // Using Kerberos SEED 8'h48
    lfsr #(.SEED(8'h48)) rival_prng (
        .clk(pixel_clock), 
        .rst(state_px_q2 == START || state_px_q2 == COLLIDE),
        .en(frame_end_tick && !rival_active),
        .dout(rival_lfsr_out)
    );
    
    rival_car_rom rival_rom (
        .clka(clk), 
        .addra(rival_car_rom_addr), 
        .douta(rival_car_color)
    );


    // --- FSM Sequential Logic (clk domain) ---
    always @ (posedge clk) begin
        if (fsm_tick) begin
            current_state <= next_state;
            car_x <= next_car_x;
            car_y <= next_car_y;
        end
    end
    
    // --- FSM Combinational Logic (clk domain) ---
    always @ (*) begin
        next_state = current_state;
        next_car_x = car_x;
        next_car_y = car_y;
        
        case (current_state)
            START: begin
                next_state = START;
                next_car_x = CAR_X_START;
                next_car_y = CAR_Y_START;
                if (BTNC) begin
                    next_state = IDLE;
                end
            end
            IDLE: begin
                if (rival_collision_detected) next_state = COLLIDE;
                else if (BTNR) next_state = RIGHT_CAR; 
                else if (BTNL) next_state = LEFT_CAR;
            end
            LEFT_CAR: begin
                if (rival_collision_detected) next_state = COLLIDE;
                else if (!BTNL) next_state = IDLE; 
                else if (car_x <= LEFT_BOUNDARY) next_state = COLLIDE; 
                else begin next_state = LEFT_CAR; next_car_x = car_x - CAR_SPEED; end 
            end
            RIGHT_CAR: begin
                if (rival_collision_detected) next_state = COLLIDE;
                else if (!BTNR) next_state = IDLE; 
                else if (car_x + main_car_width > RIGHT_BOUNDARY) next_state = COLLIDE; 
                else begin next_state = RIGHT_CAR; next_car_x = car_x + CAR_SPEED; end
            end
            COLLIDE: begin
                next_state = COLLIDE;
                if (BTNC) begin
                    next_state = START;
                    next_car_x = CAR_X_START;
                    next_car_y = CAR_Y_START;
                end
            end
            default: begin
                next_state = START;
            end
        endcase
    end
    
    // --- Background Scrolling Logic (pixel_clock domain) ---
    localparam HTOT = 800;
    localparam VTOT = 525;
    localparam SCROLL_SPEED = 1; 
    localparam SCROLL_PIXELS_PER_FRAME = 2;
    
    reg [pixel_counter_width-1:0] v_scroll_reg ;
    reg [7:0] frame_counter;
    wire frame_end_tick;
    assign frame_end_tick = (hor_pix == HTOT - 1) && (ver_pix == VTOT - 1);

    // CDC for FSM State (clk -> pixel_clock)
    reg [2:0] state_clk_q;
    reg [2:0] state_px_q1, state_px_q2;
    always @(posedge clk) begin state_clk_q <= current_state; end
    always @(posedge pixel_clock) begin state_px_q1 <= state_clk_q; state_px_q2 <= state_px_q1; end
    
    // **FIX**: Road scrolls UP (decrement v_scroll_reg)
    always @ (posedge pixel_clock) begin
        if (state_px_q2 == START || state_px_q2 == COLLIDE) begin
            frame_counter <= 0;
            v_scroll_reg <= 0;
        end
        else if (frame_end_tick) begin
            if (frame_counter == SCROLL_SPEED - 1) begin
                frame_counter <= 0;
                // Decrement for reverse scrolling
                if (v_scroll_reg >= bg1_height - SCROLL_PIXELS_PER_FRAME) begin
                    v_scroll_reg <= (v_scroll_reg + SCROLL_PIXELS_PER_FRAME) - bg1_height;
                end else begin
                    v_scroll_reg <= v_scroll_reg + SCROLL_PIXELS_PER_FRAME;
                end
            end else begin
                frame_counter <= frame_counter + 1;
            end
        end
    end
    
    
    // --- PART 3: Rival Car Logic (Spawning/Movement on pixel_clock) ---
    

    // Spawning/Movement logic
    always @ (posedge pixel_clock) begin
        if (state_px_q2 == START || state_px_q2 == COLLIDE) begin
            rival_active <= 0;
            rival_frame_counter <= 0;
        end
        else if (frame_end_tick) begin
            if (current_state == COLLIDE) begin
                rival_x <=rival_x;
                rival_y <= rival_y;
            end
            else begin
                if (!rival_active) begin // Spawn a new car
                    rival_active <= 1;
                    rival_frame_counter <= 0;
                    rival_y <= OFFSET_BG_Y; // Spawn at top
                    // **FIX**: Use the safely synchronized value
                    rival_x <= OFFSET_BG_X + ((rival_lfsr_out + v_scroll_reg) % RIVAL_X_RANGE) + RIVAL_X_MIN;           //changed rival_lfsr_out from lfsr_sy
                end
                else begin // Move the existing car
                    if (rival_frame_counter == RIVAL_SPEED - 1) begin
                        rival_frame_counter <= 0;
                        rival_y <= rival_y + 1; // Move 1 pixel down
                    end else begin
                        rival_frame_counter <= rival_frame_counter + 1;
                    end
                    
                    // Check if car reached bottom
                    if (rival_y >= OFFSET_BG_Y + bg1_height - main_car_height ) begin
                        rival_active <= 0;
                    end
                end
            end
        end
    end
    
    
    // --- PART 3: Collision Detection Logic ---
    
    // CDC for Main Car Position (clk -> pixel_clock)
    reg [pixel_counter_width-1:0] car_x_clk_q, car_y_clk_q;
    reg [pixel_counter_width-1:0] car_x_px_q1, car_y_px_q1, car_x_px_q2, car_y_px_q2;
    always @(posedge clk) begin {car_x_clk_q, car_y_clk_q} <= {car_x, car_y}; end
    always @(posedge pixel_clock) begin {car_x_px_q1, car_y_px_q1, car_x_px_q2, car_y_px_q2} <= {car_x_clk_q, car_y_clk_q, car_x_px_q1, car_y_px_q1}; end

    // CDC for Collision Flag (pixel_clock -> clk)
    reg collision_event_px = 0;
    reg col_px_q;
    reg col_clk_q1, col_clk_q2;
    wire rival_collision_detected = col_clk_q2;
    always @(posedge pixel_clock) begin col_px_q <= collision_event_px; end
    always @(posedge clk) begin {col_clk_q1, col_clk_q2} <= {col_px_q, col_clk_q1}; end

    // AABB Collision Check (pixel_clock domain)
    always @ (posedge pixel_clock) begin
        collision_event_px <= 0; // Default
        
        if (rival_active && state_px_q2 != START && state_px_q2 != COLLIDE) begin
            if ( (car_x_px_q2 < (rival_x + main_car_width)) && 
                 ((car_x_px_q2 + main_car_width) > rival_x) &&
                 (car_y_px_q2 < (rival_y + main_car_height)) && 
                 ((car_y_px_q2 + main_car_height) > rival_y) ) 
            begin
                collision_event_px <= 1;
            end
        end
    end
    

    // --- Drawing Logic (pixel_clock domain) ---
    
    always @ (posedge pixel_clock) begin : CAR_LOCATION
        if (hor_pix >= car_x && hor_pix < (car_x + main_car_width) && ver_pix >= car_y && ver_pix < (car_y + main_car_height)) begin
            car_rom_addr <= (hor_pix - car_x) + (ver_pix - car_y)*main_car_width;
            car_on <= 1;
        end else begin
            car_on <= 0;
        end
    end

    always @ (posedge pixel_clock) begin : RIVAL_LOCATION
        if (rival_active && hor_pix >= rival_x && hor_pix < (rival_x + main_car_width) && ver_pix >= rival_y && ver_pix < (rival_y + main_car_height)) begin
            rival_car_rom_addr <= (hor_pix - rival_x) + (ver_pix - rival_y)*main_car_width;
            rival_car_on <= 1;
        end else begin
        //CHANGE
            rival_car_on <= 0;
        end
    end
    
    // **FIX**: Road scrolls UP (subtract v_scroll_reg)
    always @ (posedge pixel_clock) begin : BG_LOCATION
        reg signed [pixel_counter_width:0] rom_y_signed; 
        reg [pixel_counter_width-1:0] rom_x;
        reg [pixel_counter_width-1:0] rom_y;
        
        if (hor_pix >= 0 + OFFSET_BG_X && hor_pix < bg1_width + OFFSET_BG_X && ver_pix >= 0 + OFFSET_BG_Y && ver_pix < bg1_height + OFFSET_BG_Y) begin
            bg_on <= 1;
            rom_x = hor_pix - OFFSET_BG_X;
            
            // Subtract offset for reverse scrolling
            rom_y_signed = (ver_pix - OFFSET_BG_Y) - v_scroll_reg;
            
            // Handle negative wraparound
            if (rom_y_signed < 0) begin
                rom_y = rom_y_signed + bg1_height;
            end else begin
                rom_y = rom_y_signed;
            end
            
            bg_rom_addr <= rom_x + rom_y * bg1_width;
        end else begin
            bg_on <= 0;
        end
    end
    
    always @ (*) begin : MUX_VGA_OUTPUT
        next_color = 12'b0; // Default black
        
        if (bg_on) begin
            next_color = bg_color;
        end
        
        if (rival_car_on && rival_car_color != 12'b101000001010) begin
            next_color = rival_car_color;
        end
        
        if (car_on && car_color != 12'b101000001010) begin
            next_color = car_color;
        end
    end
    
    always @ (posedge pixel_clock) begin
        output_color <= next_color;
    end
    
    assign vgaRed = output_color[11:8];
    assign vgaGreen = output_color[7:4];
    assign vgaBlue = output_color[3:0];
    
endmodule