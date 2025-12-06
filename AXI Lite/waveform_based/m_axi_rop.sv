`timescale 1ns / 1ps
     
module p_m_axi (
    input wire         m_axi_aclk,    // i_aclk
    input wire         m_axi_aresetn, // i_aresetn
    input wire         i_wr,
    input wire [31:0]  i_addrin,
    // Read Address Channel
    output reg         m_axi_arvalid,
    input  wire        m_axi_arready,
    output reg [31:0]  m_axi_araddr,
    // Read Data Channel
    input  wire        m_axi_rvalid,
    output reg         m_axi_rready,
    input  wire [31:0] m_axi_rdata,
    input  wire [1:0]  m_axi_rresp,
    // Read Out
    output reg [31:0]  o_rdata,
    output reg [1:0]   o_resp
    );
     
    // Read Operation - Handles arvalid, araddr and rready
    reg wait_for_rdata = 0;
     
    initial m_axi_arvalid = 0;
    initial m_axi_araddr = 0;
    initial m_axi_rready = 0;
     
    always @(posedge m_axi_aclk) begin
        if (m_axi_aresetn == 1'b0) begin
            m_axi_arvalid <= 0;
        end 
        else if (wait_for_rdata) begin
            if (m_axi_arready)  
                m_axi_arvalid <= 1'b0;
        end 
        else if (i_wr == 1'b0) begin
            m_axi_arvalid <= 1'b1; 
        end
    end
     
    always @(posedge m_axi_aclk) begin
        if (m_axi_aresetn == 1'b0) begin
            m_axi_araddr <= 0;
        end 
        else if (wait_for_rdata) begin
            if (m_axi_arready)  
                m_axi_araddr <= 0;
        end 
        else if (i_wr == 1'b0) begin
            m_axi_araddr <= i_addrin;  
        end
    end
     
    always @(posedge m_axi_aclk) begin
        if (m_axi_aresetn == 1'b0) begin
            m_axi_rready <= 0;
        end 
        else if (m_axi_rready) begin  
            m_axi_rready <= 0;
        end 
        else if (m_axi_rvalid) begin
            m_axi_rready <= 1;
        end
    end
     
    always @(posedge m_axi_aclk) begin
        if (m_axi_aresetn == 1'b0) begin
            o_rdata <= 0;
            o_resp <= 0;
            wait_for_rdata <= 0;
        end 
        else if (m_axi_rvalid && m_axi_rready) begin
            o_rdata <= m_axi_rdata;
            o_resp <= m_axi_rresp;
            wait_for_rdata <= 0;
        end 
        else if (m_axi_arvalid) begin
            o_rdata <= 0;
            o_resp <= 0;
            wait_for_rdata <= 1;
        end
    end
     
endmodule
     
