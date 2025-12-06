module top (
    input  [31:0] i_addrin,
    input         i_wr,
    input         m_axi_aclk,
    input         m_axi_aresetn,
    output [31:0] o_rdata,
    output [1:0]  o_resp
    );
     
    wire         m_axi_arvalid, m_axi_arready, m_axi_rvalid, m_axi_rready; 
    wire [31:0]  m_axi_araddr;
    wire [31:0]  m_axi_rdata;
    wire [1:0]   m_axi_rresp;
     
    p_m_axi mdut (
        .m_axi_aclk(m_axi_aclk),
        .m_axi_aresetn(m_axi_aresetn),
        .i_wr(i_wr),
        .i_addrin(i_addrin),
        .m_axi_arvalid(m_axi_arvalid),
        .m_axi_arready(m_axi_arready),
        .m_axi_araddr(m_axi_araddr),
        .m_axi_rvalid(m_axi_rvalid),
        .m_axi_rready(m_axi_rready),
        .m_axi_rdata(m_axi_rdata),
        .m_axi_rresp(m_axi_rresp),
        .o_rdata(o_rdata),
        .o_resp(o_resp)
    );
     
    p_s_axi sdut (
        .s_axi_aclk(m_axi_aclk),
        .s_axi_aresetn(m_axi_aresetn),
        .s_axi_arvalid(m_axi_arvalid),
        .s_axi_arready(m_axi_arready),
        .s_axi_araddr(m_axi_araddr),
        .s_axi_rvalid(m_axi_rvalid),
        .s_axi_rready(m_axi_rready),
        .s_axi_rdata(m_axi_rdata),
        .s_axi_rresp(m_axi_rresp)
    );
     
endmodule
