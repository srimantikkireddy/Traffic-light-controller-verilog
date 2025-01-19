`timescale 1ns / 1ps

module traffic_light_controller_tb;

    localparam integer CLOCK_PERIOD = 20;

    reg clk, rst_n, sensor;
    wire [1:0] highway_light, farm_light;

    traffic_light_controller_fsm uut (
        .clk(clk),
        .rst_n(rst_n),
        .sensor(sensor),
        .highway_light(highway_light),
        .farm_light(farm_light)
    );

    always #(CLOCK_PERIOD / 2) clk = ~clk;

    initial begin
        clk = 0;
        rst_n = 0;
        sensor = 0;

        #(CLOCK_PERIOD * 2);
        rst_n = 1;

        #(CLOCK_PERIOD * 20);
        sensor = 1;

        #(CLOCK_PERIOD * 40);
        sensor = 0;

        #(CLOCK_PERIOD * 45);
        $finish;
    end

    initial begin
        $monitor("Time: %0t ns | Highway Light: %b | Farm Light: %b | Sensor: %b", $time, highway_light, farm_light, sensor);
    end
  
endmodule
