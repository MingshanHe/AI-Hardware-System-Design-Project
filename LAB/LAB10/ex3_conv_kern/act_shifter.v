// Activation Shifter
module act_shifter(
    d_in,
    n_shift,
    d_out
    );

// Parameter declarations
    parameter DATA_BITS = 32;
    parameter SHIFT_W = 3;

// Port declarations
    input [DATA_BITS-1:0] d_in;
    input [SHIFT_W-1:0] n_shift;
    output [DATA_BITS-1:0] d_out;

// Internel port declarations
    reg [DATA_BITS-1:0] d_out_r;
//-------------------------------------------------
// Main body
//-------------------------------------------------
// NOTE: Use a barrel shifter for further optimization
    always @*
    begin
        case (n_shift)
            'd0: d_out_r = d_in;
            'd1: d_out_r = {{1{d_in[DATA_BITS-1]}}, d_in[DATA_BITS-1:1]};
            'd2: d_out_r = {{2{d_in[DATA_BITS-1]}}, d_in[DATA_BITS-1:2]};
            'd3: d_out_r = {{3{d_in[DATA_BITS-1]}}, d_in[DATA_BITS-1:3]};
            'd4: d_out_r = {{4{d_in[DATA_BITS-1]}}, d_in[DATA_BITS-1:4]};
            'd5: d_out_r = {{5{d_in[DATA_BITS-1]}}, d_in[DATA_BITS-1:5]};
            //'d6: d_out_r = /*Insert your code*/;
            //'d7: d_out_r = /*Insert your code*/;
            default: d_out_r = 'h0;
        endcase
    end

    assign d_out = d_out_r;

endmodule