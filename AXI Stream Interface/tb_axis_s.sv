//////////////////////////TB Code:

`timescale 1ns / 1ps
     
module axis_s_tb;
     
    // Parameters
    localparam CLK_PERIOD = 10; // Clock period in ns
        
    // Signals
    logic s_axis_aclk = 0;
    logic s_axis_aresetn;
    logic s_axis_tvalid;
    logic [7:0] s_axis_tdata;
    logic s_axis_tlast;
    logic s_axis_tready;
    reg [7:0] dout;
     
    // Instantiate the axis_s module
    axis_s uut (
        .s_axis_aclk(s_axis_aclk),
        .s_axis_aresetn(s_axis_aresetn),
        .s_axis_tready(s_axis_tready),
        .s_axis_tvalid(s_axis_tvalid),
        .s_axis_tdata(s_axis_tdata),
        .s_axis_tlast(s_axis_tlast),
        .dout(dout)
    );
     
    // Clock generation
    always #10 s_axis_aclk = ~s_axis_aclk;
     
    // Stimulus generation
    initial begin
        // Initialize inputs
        s_axis_tvalid = 0;
        s_axis_tdata = 8'h00;
        s_axis_tlast = 0;
        s_axis_aresetn = 0;
        repeat(5)@(posedge s_axis_aclk);
        s_axis_aresetn = 1;
        for(int i = 0; i<10;i++) begin
            @(posedge s_axis_aclk);
            s_axis_tvalid = 1;
            s_axis_tdata = $urandom;
        end
        @(posedge s_axis_aclk);
        s_axis_tlast = 1;
        @(posedge s_axis_aclk);
        s_axis_tlast = 0;
        s_axis_tvalid = 0;
        $finish;
    end
          
endmodule