module counter(clk, din, ena, oflag);
input clk;
input [5:0] din;
input ena;
output reg oflag;
reg [5:0] cnt;

wire run_cnt;

assign run_cnt = (cnt!=0)?1'b1: 1'b0;

always@(posedge clk) begin
    // if(run_cnt) begin
    //     //udpate cnt
    //     cnt <= cnt-1;
    // end
    // else if(ena) begin
    //     // initialize the new din
    //     cnt <= din;
    // end
    if(ena) begin
        cnt <= din;
        
    end
    else if(run_cnt) begin
        // initialize the new din
        cnt <= cnt-1;
    end
end

always@(posedge clk)begin
    if(cnt == 1) begin
        oflag <= 1'b1;
    end
    else begin
        oflag <= 1'b0;
    end
end

// Dummy
// always@(*) begin
// a = b + c;
// d = a + h;   // b + c + h 
//end
endmodule