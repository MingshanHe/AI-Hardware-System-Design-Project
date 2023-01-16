`timescale 1ns/1ps
module encoder4to2_tb;
reg din0, din1, din2, din3;
wire [2:0] dout;
encoder4to2 u_encoder4to2
(
.din0(din0),
.din1(din1),
.din2(din2),
.din3(din3),
.dout(dout)
);
initial begin

din0 = 0;
din1 = 0;
din2 = 0;
din3 = 0;
#5 	din0 = 1;
	din1 = 0;
	din2 = 0;
	din3 = 0;
#15 	din0 = 0;
	din1 = 1;
	din2 = 0;
	din3 = 0;
#5 	din0 = 0;
	din1 = 0;
	din2 = 1;
	din3 = 0;
#5 	din0 = 0;
	din1 = 0;
	din2 = 0;
	din3 = 0;
end
endmodule