module screensavervga (
    input  wire       CLOCK_50,
    input  wire [3:0] KEY,
    input  wire [9:0] SW,

    output wire [7:0] VGA_R,
    output wire [7:0] VGA_G,
    output wire [7:0] VGA_B,
    output wire       VGA_HS,
    output wire       VGA_VS,
    output wire       VGA_SYNC_N,
    output wire       VGA_BLANK_N,
    output wire       VGA_CLK
);

    // Clock divider to get 25 MHz from 50 MHz (VGA 640x480@60Hz needs ~25.175 MHz)
    reg clk_25m = 0;
    always @(posedge CLOCK_50) begin
        clk_25m <= ~clk_25m;
    end
    
    // Reset on KEY0 (active low)
    wire rst_n = KEY[0];
    
    wire [7:0] ui_in;
    wire [7:0] uo_out;
    wire [7:0] uio_in;
    wire [7:0] uio_out;
    wire [7:0] uio_oe;
    
    // Inputs mapping
    // SW[0] is 'tile'
    // SW[1] is 'color'
    assign ui_in = SW[7:0]; 
    assign uio_in = 8'd0;
    
    // Outputs mapping
    // As per info.yaml:
    // uo[0]: R1, uo[1]: G1, uo[2]: B1, uo[3]: VSync
    // uo[4]: R0, uo[5]: G0, uo[6]: B0, uo[7]: HSync
    wire R1 = uo_out[0];
    wire G1 = uo_out[1];
    wire B1 = uo_out[2];
    wire vsync = uo_out[3];
    wire R0 = uo_out[4];
    wire G0 = uo_out[5];
    wire B0 = uo_out[6];
    wire hsync = uo_out[7];
    
    // Map the 2-bit colors to the 8-bit DE1-SoC VGA DAC
    assign VGA_R = {R1, R0, 6'b000000};
    assign VGA_G = {G1, G0, 6'b000000};
    assign VGA_B = {B1, B0, 6'b000000};
    
    assign VGA_HS = hsync;
    assign VGA_VS = vsync;
    
    // VGA control signals
    assign VGA_SYNC_N = 1'b0;  // Tied to 0 for standard VGA
    assign VGA_BLANK_N = 1'b1; // Assume design drives RGB to 0 during blanking
    assign VGA_CLK = clk_25m;
    
    // TinyTapeout Top Module Instance
    tt_um_tinytapeout_dvd_screensaver tt_inst (
        .ui_in(ui_in),
        .uo_out(uo_out),
        .uio_in(uio_in),
        .uio_out(uio_out),
        .uio_oe(uio_oe),
        .ena(1'b1),
        .clk(clk_25m),
        .rst_n(rst_n)
    );

endmodule
