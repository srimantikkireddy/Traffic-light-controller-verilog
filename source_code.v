`timescale 1ns / 1ps

module traffic_light_controller_fsm (
    input wire clk,        
    input wire rst_n,      // Active-low reset
    input wire sensor,    
    output reg [1:0] highway_light,  
    output reg [1:0] farm_light     
);

    typedef enum logic [1:0] {
        HGRE_FRED = 2'b00, // Highway green, farm red
        HYEL_FRED = 2'b01, // Highway yellow, farm red
        HRED_FGRE = 2'b10, // Highway red, farm green
        HRED_FYEL = 2'b11  // Highway red, farm yellow
    } state_t;

    state_t state = HGRE_FRED, next_state;
    reg [4:0] timer; 

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state <= HGRE_FRED;      
            timer <= 0;
        end else begin
            if (timer > 0) begin
                timer <= timer - 1;  // Decrement timer
            end else begin
                state <= next_state; 
                timer <= 20;         // Set delay for 20 clock cycles
            end
        end
    end

    always @(*) begin
        highway_light = 2'b10; 
        farm_light = 2'b10;    
        next_state = state;    

        case (state)
            HGRE_FRED: begin
                highway_light = 2'b00; // Green
                if (sensor) next_state = HYEL_FRED; 
            end

            HYEL_FRED: begin
                highway_light = 2'b01; // Yellow
                if (timer == 0) next_state = HRED_FGRE; 
            end

            HRED_FGRE: begin
                farm_light = 2'b00;    // Green
                highway_light = 2'b10; // Red
                if (!sensor) next_state = HRED_FYEL; 
            end

            HRED_FYEL: begin
                farm_light = 2'b01;    // Yellow
                if (timer == 0) next_state = HGRE_FRED; 
            end
        endcase
    end

endmodule
