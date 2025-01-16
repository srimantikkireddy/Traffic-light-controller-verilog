`timescale 1ns / 1ps

module traffic_light_controller_tb;

    localparam integer CLOCK_PERIOD = 20; // Clock period in ns (50 MHz)
    localparam integer SIMULATION_TIME = 500_000_000; // Total simulation time in ns

    reg clk, rst_n, sensor;
    wire [2:0] highway_light, farm_light;

    // Instantiate the Unit Under Test (UUT)
    traffic_light_controller uut (
        .clk(clk),
        .rst_n(rst_n),
        .sensor(sensor),
        .highway_light(highway_light),
        .farm_light(farm_light)
    );

    // Clock Generation
    always #(CLOCK_PERIOD / 2) clk = ~clk;

    // Test Sequence
    initial begin
        // Initialize signals
        clk = 0;
        rst_n = 0;
        sensor = 0;

        // Apply reset
        #(CLOCK_PERIOD * 5);
        rst_n = 1;

        // Simulate vehicle detection
        #(CLOCK_PERIOD * 10);
        sensor = 1;

        // No vehicle detected after some time
        #(300_000_000);
        sensor = 0;

        // End simulation after total simulation time
        #(SIMULATION_TIME - (CLOCK_PERIOD * 5 + CLOCK_PERIOD * 10 + 300_000_000));
        $finish;
    end

    // Monitor Outputs
    initial begin
        $monitor("Time: %0t ns | Highway Light: %b | Farm Light: %b | Sensor: %b", $time, highway_light, farm_light, sensor);
    end

    // Waveform Generation for Debugging
    initial begin
        $dumpfile("traffic_light_controller_tb.vcd"); // Dumpfile name
        $dumpvars(0, traffic_light_controller_tb);    // Dump all variables in this module
    end

endmodule
