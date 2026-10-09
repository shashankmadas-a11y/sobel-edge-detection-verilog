`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01.10.2026 20:32:15
// Design Name: 
// Module Name: sobel_mac
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


module sobel_mac (
    input  wire       clk,
    input  wire       reset_n,
    input  wire       in_valid,
    input  wire [7:0] p00, input wire [7:0] p01, input wire [7:0] p02,
    input  wire [7:0] p10, input wire [7:0] p11, input wire [7:0] p12,
    input  wire [7:0] p20, input wire [7:0] p21, input wire [7:0] p22,
    output reg  [7:0] pixel_out,
    output reg        out_valid
);
    wire [10:0] gx_pos = p02 + (p12 << 1) + p22;
    wire [10:0] gx_neg = p00 + (p10 << 1) + p20;
    wire [10:0] gy_pos = p00 + (p01 << 1) + p02;
    wire [10:0] gy_neg = p20 + (p21 << 1) + p22;

    wire signed [11:0] gx = $signed({1'b0, gx_pos}) - $signed({1'b0, gx_neg});
    wire signed [11:0] gy = $signed({1'b0, gy_pos}) - $signed({1'b0, gy_neg});

    wire [11:0] abs_gx = (gx < 0) ? -gx : gx;
    wire [11:0] abs_gy = (gy < 0) ? -gy : gy;
    wire [11:0] magnitude = abs_gx + abs_gy;

    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            pixel_out <= 8'd0;
            out_valid <= 1'b0;
        end else begin
            out_valid <= in_valid;
            if (in_valid) begin
                if (magnitude > 12'd255)
                    pixel_out <= 8'd255;
                else
                    pixel_out <= magnitude[7:0];
            end else begin
                pixel_out <= 8'd0;
            end
        end
    end
endmodule
