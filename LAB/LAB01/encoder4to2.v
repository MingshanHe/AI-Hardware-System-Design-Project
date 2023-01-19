module encoder4to2(din0, din1, din2, din3, dout);
	input din0, din1, din2, din3;
	output reg[1:0] dout;
always@*
begin
	if(din0==1 && din1 == 0 && din2 == 0 && din3 == 0) begin
		dout = 2'b00;
	end
	else if(din0==0 && din1 == 1 && din2 == 0 && din3 == 0) begin
		dout = 2'b01;
	end
	else if(din0==0 && din1 == 0 && din2 == 1 && din3 == 0) begin
		dout = 2'b10;
	end
	else if(din0==0 && din1 == 0 && din2 == 0 && din3 == 1) begin
		dout = 2'b11;
	end
	else dout = 2'b00;
end
endmodule