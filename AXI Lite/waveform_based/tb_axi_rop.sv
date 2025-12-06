module tb;
     
    // Declare testbench signals
    reg  [31:0] i_addrin;
    reg         i_wr = 0;
    reg         m_axi_aclk = 0;
    reg         m_axi_aresetn = 0;
    wire [31:0] o_rdata;
    wire [1:0]  o_resp;
     
    // Instantiate the design under test (DUT)
    top DUT (
        .i_addrin(i_addrin),
        .i_wr(i_wr),
        .m_axi_aclk(m_axi_aclk),
        .m_axi_aresetn(m_axi_aresetn),
        .o_rdata(o_rdata),
        .o_resp(o_resp)
    );
     
    // Clock generation
    initial begin
        m_axi_aclk = 0;
        forever #10 m_axi_aclk = ~m_axi_aclk;  // 100 MHz clock
    end
     
    // Reset generation
    initial begin
        m_axi_aresetn = 0;
        #20 m_axi_aresetn = 1;
    end
     
    integer i = 0;
     
    // Stimulus
    initial begin
        @(posedge m_axi_aresetn);
        for (i = 0; i < 10; i = i + 1) begin
            @(posedge m_axi_aclk);
            i_addrin = $urandom_range(0, 15);
            @(posedge DUT.mdut.m_axi_rready);
        end
        $finish;  // End simulation
    end
     
endmodule
