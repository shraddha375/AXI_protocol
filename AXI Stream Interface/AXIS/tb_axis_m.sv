////////////////////// TB Code:

module tb_axis_m;
    // Define testbench ports
    wire [7:0] m_axis_tdata;
    wire m_axis_tlast;
    reg m_axis_tready;
    wire m_axis_tvalid;
    reg m_axis_aclk = 0;
    reg m_axis_aresetn;
    reg newd;
    reg [7:0] din;
     
    // Instantiate the axis_m module
    axis_m dut (
        .m_axis_tdata(m_axis_tdata),
        .m_axis_tlast(m_axis_tlast),
        .m_axis_tready(m_axis_tready),
        .m_axis_tvalid(m_axis_tvalid),
        .m_axis_aclk(m_axis_aclk),
        .m_axis_aresetn(m_axis_aresetn),
        .newd(newd),
        .din(din)
    );
     
     
    always #10 m_axis_aclk = ~m_axis_aclk;
        
    initial begin
        m_axis_aresetn = 0;
        repeat(10) @(posedge m_axis_aclk);
        for(int i = 0; i < 5; i++) begin
            @(posedge m_axis_aclk);
            m_axis_aresetn = 1;
            m_axis_tready  = 1'b1;
            newd = 1;
            din = $random();
            @(negedge m_axis_tlast);
            m_axis_tready = 1'b0;
        end 
        $finish;
    end
    
    initial begin
        $dumpfile("dump.vcd"); 
        $dumpvars;
    end
       
endmodule
