`timescale 1ns / 1ps

module traffic_light_controller_fsm (
    input wire clk,        // Clock signal
    input wire rst_n,      // Active-low reset
    input wire sensor,     // Sensor input
    output reg [1:0] highway_light,  // Highway traffic light
    output reg [1:0] farm_light      // Farm road traffic light
);

    typedef enum logic [1:0] {
        HGRE_FRED = 2'b00, // Highway green, farm red
        HYEL_FRED = 2'b01, // Highway yellow, farm red
        HRED_FGRE = 2'b10, // Highway red, farm green
        HRED_FYEL = 2'b11  // Highway red, farm yellow
    } state_t;

    state_t state, next_state;
    reg [4:0] timer; // Timer for 20 clock cycles

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state <= HGRE_FRED;      // Reset to initial state
            timer <= 0;
        end else begin
            if (timer > 0) begin
                timer <= timer - 1;  // Decrement timer
            end else begin
                state <= next_state; // Move to next state
                timer <= 20;         // Set delay for 20 clock cycles
            end
        end
    end

    always @(*) begin
        highway_light = 2'b11; // Default Red
        farm_light = 2'b11;    // Default Red
        next_state = state;    // Default to current state

        case (state)
            HGRE_FRED: begin
                highway_light = 2'b00; // Green
                if (sensor) next_state = HYEL_FRED; // Transition to yellow
            end

            HYEL_FRED: begin
                highway_light = 2'b01; // Yellow
                if (timer == 0) next_state = HRED_FGRE; // Transition to red
            end

            HRED_FGRE: begin
                farm_light = 2'b00;    // Green
                if (!sensor) next_state = HRED_FYEL; // Transition to yellow
            end

            HRED_FYEL: begin
                farm_light = 2'b01;    // Yellow
                if (timer == 0) next_state = HGRE_FRED; // Transition to green
            end
        endcase
    end

endmodule
