`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01.10.2026 20:33:06
// Design Name: 
// Module Name: sobel_engine
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


module sobel_engine #(
    parameter IMG_WIDTH  = 64,
    parameter IMG_HEIGHT = 64
)(
    input  wire       clk,
    input  wire       reset_n,
    input  wire [7:0] pixel_in,
    input  wire       pixel_in_valid,
    output reg  [7:0] pixel_out,
    output reg        pixel_out_valid
);
    wire [7:0] p00, p01, p02, p10, p11, p12, p20, p21, p22;
    wire [7:0] mac_pixel_out;
    wire       mac_out_valid;

    // 3x3 Window Generator
    conv_window_3x3 #(.IMG_WIDTH(IMG_WIDTH)) window_gen (
        .clk(clk), .reset_n(reset_n), .data_valid(pixel_in_valid), .pixel_in(pixel_in),
        .p00(p00), .p01(p01), .p02(p02), .p10(p10), .p11(p11), .p12(p12), .p20(p20), .p21(p21), .p22(p22)
    );

    // MAC Engine
    sobel_mac mac_unit (
        .clk(clk), .reset_n(reset_n), .in_valid(pixel_in_valid),
        .p00(p00), .p01(p01), .p02(p02), .p10(p10), .p11(p11), .p12(p12), .p20(p20), .p21(p21), .p22(p22),
        .pixel_out(mac_pixel_out), .out_valid(mac_out_valid)
    );

    // Pixel Position Counters
    reg [11:0] col_cnt, row_cnt;

    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            col_cnt <= 12'd0;
            row_cnt <= 12'd0;
        end else if (pixel_in_valid) begin
            if (col_cnt == IMG_WIDTH - 1) begin
                col_cnt <= 12'd0;
                if (row_cnt == IMG_HEIGHT - 1)
                    row_cnt <= 12'd0;
                else
                    row_cnt <= row_cnt + 1'b1;
            end else begin
                col_cnt <= col_cnt + 1'b1;
            end
        end
    end

    // Pipeline Delays (2 cycles to align with window_gen + mac_unit latency)
    reg [11:0] row_cnt_d1, row_cnt_d2;
    reg [11:0] col_cnt_d1, col_cnt_d2;

    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            row_cnt_d1 <= 12'd0; row_cnt_d2 <= 12'd0;
            col_cnt_d1 <= 12'd0; col_cnt_d2 <= 12'd0;
        end else if (pixel_in_valid) begin
            row_cnt_d1 <= row_cnt;
            row_cnt_d2 <= row_cnt_d1;
            col_cnt_d1 <= col_cnt;
            col_cnt_d2 <= col_cnt_d1;
        end
    end

    // Output Logic: Keeps output_valid active for all 4096 pixels, padding borders with 0
    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            pixel_out       <= 8'd0;
            pixel_out_valid <= 1'b0;
        end else begin
            pixel_out_valid <= mac_out_valid;
            if (row_cnt_d2 < 12'd2 || col_cnt_d2 < 12'd2 || row_cnt_d2 == IMG_HEIGHT-1 || col_cnt_d2 == IMG_WIDTH-1) begin
                pixel_out <= 8'd0; // Zero-padding on boundaries
            end else begin
                pixel_out <= mac_pixel_out;
            end
        end
    end
endmodule