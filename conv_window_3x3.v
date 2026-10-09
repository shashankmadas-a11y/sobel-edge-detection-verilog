`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01.10.2026 20:31:11
// Design Name: 
// Module Name: conv_window_3x3
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


module conv_window_3x3 #(
    parameter IMG_WIDTH = 64
)(
    input  wire       clk,
    input  wire       reset_n,
    input  wire       data_valid,
    input  wire [7:0] pixel_in,

    output reg [7:0] p00, output reg [7:0] p01, output reg [7:0] p02,
    output reg [7:0] p10, output reg [7:0] p11, output reg [7:0] p12,
    output reg [7:0] p20, output reg [7:0] p21, output reg [7:0] p22
);
    wire [7:0] lb0_out;
    wire [7:0] lb1_out;

    line_buffer #(.IMG_WIDTH(IMG_WIDTH)) lb0 (
        .clk(clk), .reset_n(reset_n), .data_valid(data_valid),
        .data_in(pixel_in), .data_out(lb0_out)
    );

    line_buffer #(.IMG_WIDTH(IMG_WIDTH)) lb1 (
        .clk(clk), .reset_n(reset_n), .data_valid(data_valid),
        .data_in(lb0_out), .data_out(lb1_out)
    );

    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            p00 <= 8'd0; p01 <= 8'd0; p02 <= 8'd0;
            p10 <= 8'd0; p11 <= 8'd0; p12 <= 8'd0;
            p20 <= 8'd0; p21 <= 8'd0; p22 <= 8'd0;
        end else if (data_valid) begin
            p02 <= lb1_out; p01 <= p02; p00 <= p01;
            p12 <= lb0_out; p11 <= p12; p10 <= p11;
            p22 <= pixel_in; p21 <= p22; p20 <= p21;
        end
    end
endmodule
