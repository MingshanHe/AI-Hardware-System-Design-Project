`timescale 1ns/1ps

// `define CLOCK_PERIOD 10 //100Mhz
`define CLOCK_PERIOD 20 // 50Mhz
module counter_tb;

reg clk;
reg [5:0] din;
reg ena;
wire oflag;

counter
u_counter(.clk(clk),
        .din(din),
        .ena(ena),
        .oflag(oflag));

initial begin
    clk = 0;
    forever #(`CLOCK_PERIOD/2) clk = ~clk;
end

initial begin
    din = 6'd0;
    ena = 1'd0;

    #(`CLOCK_PERIOD * 5) @(posedge clk)
                        din = 6'd8;
                        ena = 1'd1;
    #(`CLOCK_PERIOD) @(posedge clk)
                        ena = 1'd0;

    #(`CLOCK_PERIOD * 16) @(posedge clk)
                        din = 6'd16;
                        ena = 1'd1;
    #(`CLOCK_PERIOD) @(posedge clk)
                        ena = 1'd0;

end
endmodule