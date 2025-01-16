module traffic_light_controller (
    input wire clk,        // clock signal (50 MHz)
    input wire rst_n,      // active-low reset
    input wire sensor,     // sensor input
    output reg [2:0] highway_light,  // Highway traffic light
    output reg [2:0] farm_light      // Farm road traffic light
);

    // State encoding using parameters
    localparam [1:0] 
        HGRE_FRED = 2'b00, // Highway green, farm red
        HYEL_FRED = 2'b01, // Highway yellow, farm red
        HRED_FGRE = 2'b10, // Highway red, farm green
        HRED_FYEL = 2'b11; // Highway red, farm yellow

    reg [1:0] state, next_state;  // Current and next states
    localparam integer YELLOW_TIME = 150_000_000;  // 3 seconds at 50 MHz
    reg [27:0] timer;  // Timer for yellow light duration

    // State transition and timer management
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state <= HGRE_FRED;  // Reset to initial state
            timer <= 0;
        end else begin
            if (timer > 0) begin
                timer <= timer - 1;  // Decrement timer
            end else begin
                state <= next_state;  // Transition to next state
                if (next_state == HYEL_FRED || next_state == HRED_FYEL) begin
                    timer <= YELLOW_TIME;  // Load timer for yellow states
                end else begin
                    timer <= 0;  // Reset timer for non-yellow states
                end
            end
        end
    end

    // Next state logic and light control
    always @(*) begin
        // Default outputs
        highway_light = 3'b100; // Default to Red
        farm_light = 3'b100;    // Default to Red
        next_state = state;     // Default next state is current state

        case (state)
            HGRE_FRED: begin
                highway_light = 3'b001; // Green
                farm_light = 3'b100;    // Red
                if (sensor) begin
                    next_state = HYEL_FRED;  // Transition to highway yellow
                end
            end

            HYEL_FRED: begin
                highway_light = 3'b010; // Yellow
                farm_light = 3'b100;    // Red
                if (timer == 0) begin
                    next_state = HRED_FGRE;  // Transition to highway red, farm green
                end
            end

            HRED_FGRE: begin
                highway_light = 3'b100; // Red
                farm_light = 3'b001;    // Green
                if (!sensor) begin
                    next_state = HRED_FYEL;  // Transition to farm yellow
                end
            end

            HRED_FYEL: begin
                highway_light = 3'b100; // Red
                farm_light = 3'b010;    // Yellow
                if (timer == 0) begin
                    next_state = HGRE_FRED;  // Transition to highway green
                end
            end

            default: begin
                // Safe default state in case of invalid state
                next_state = HGRE_FRED;
            end
        endcase
    end

endmodule
