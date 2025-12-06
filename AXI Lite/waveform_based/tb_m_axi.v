    `timescale 1ns / 1ps
     
    module p_axi_tb;
     
    reg clk = 0;
    reg resetn = 0;
    reg wr;
    reg [31:0] din;
    reg [3:0]  strbin;
    reg [31:0] addrin;
     
    wire [159:0] pc_asserted;
    wire pc_status;
    integer i = 0;
    wire bvalid;    
     
    design_1_wrapper DUT(
        .i_addrin(addrin),
        .i_din(din),
        .i_strb(strbin),
        .i_wr(wr),
        .m_axi_aclk(clk),
        .m_axi_aresetn(resetn),
        .pc_asserted(pc_asserted),
        .pc_status(pc_status),
        .s_axi_bvalid(bvalid)
    );
     
     
    always #10 clk = ~clk;
     
    initial begin
    resetn = 0;
    repeat(2)@(posedge clk);
    resetn = 1;
    end 
     
    initial 
    begin
    @(posedge resetn);
    @(posedge clk);
     
    for( i = 0; i < 10; i = i+1)
    begin
    @(posedge clk);
    wr = 1'b1;
    addrin  = $urandom_range(0,20);
    din     = $urandom_range(1,10);
    strbin  = 4'b1111;
    @(posedge bvalid);
    wr = 1'b0;
    @(posedge clk);
    end
     $stop;
    end  
