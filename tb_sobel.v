`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01.10.2026 20:34:13
// Design Name: 
// Module Name: tb_sobel
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



`timescale 1ns/1ps

module tb_sobel;
    reg clk;
    reg reset_n;
    reg [7:0] pixel_in;
    reg pixel_in_valid;
    
    wire [7:0] pixel_out;
    wire pixel_out_valid;

    // 256 x 256 = 65536 pixels
    reg [7:0] image_mem [0:65535];
    integer i, out_file;

    sobel_engine #(.IMG_WIDTH(256), .IMG_HEIGHT(256)) dut (
        .clk(clk), .reset_n(reset_n),
        .pixel_in(pixel_in), .pixel_in_valid(pixel_in_valid),
        .pixel_out(pixel_out), .pixel_out_valid(pixel_out_valid)
    );

    always #5 clk = ~clk;

    initial begin
        clk = 0;
        reset_n = 0;
        pixel_in = 0;
        pixel_in_valid = 0;

        $readmemh("input.hex", image_mem);
        out_file = $fopen("output.hex", "w");

        #20;
        reset_n = 1;
        #10;

        for (i = 0; i < 65536; i = i + 1) begin
            @(posedge clk);
            pixel_in <= image_mem[i];
            pixel_in_valid <= 1'b1;
        end

        @(posedge clk);
        pixel_in_valid <= 1'b0;

        #10000; // Increased delay to ensure line buffers flush completely
        $fclose(out_file);
        $display("Simulation Complete. Check output.hex");
        $finish;
    end

    always @(posedge clk) begin
        if (pixel_out_valid) begin
            $fdisplay(out_file, "%02h", pixel_out);
        end
    end
endmodule
