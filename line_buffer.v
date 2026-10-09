`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01.10.2026 20:29:49
// Design Name: 
// Module Name: line_buffer
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module line_buffer #(
    parameter IMG_WIDTH = 64
)(
    input  wire       clk,
    input  wire       reset_n,
    input  wire       data_valid,
    input  wire [7:0] data_in,
    output wire [7:0] data_out
);
    reg [7:0] shift_reg [0:IMG_WIDTH-1];
    integer i;

    assign data_out = shift_reg[IMG_WIDTH-1];

    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            for (i = 0; i < IMG_WIDTH; i = i + 1)
                shift_reg[i] <= 8'd0;
        end else if (data_valid) begin
            shift_reg[0] <= data_in;
            for (i = 1; i < IMG_WIDTH; i = i + 1)
                shift_reg[i] <= shift_reg[i-1];
        end
    end
endmodule
