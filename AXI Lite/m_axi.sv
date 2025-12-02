`timescale 1ns / 1ps

module m_axi (
    input wire        i_clk, 
    input wire        i_resetn,
    input wire        i_wr,
    input wire [31:0] i_din,
    input wire [3:0]  i_strb,
    input wire [31:0] i_addrin,
 
    ///////////////Write Address Channel
    output reg         m_axi_awvalid,
    input  wire        m_axi_awready,
    output reg  [31:0] m_axi_awaddr,
    //////////////Write Data Channel
    output reg         m_axi_wvalid,
    input  wire        m_axi_wready,
    output reg  [31:0] m_axi_wdata,
    output reg  [ 3:0] m_axi_wstrb,
    ////////////Write Response Channel
    input  wire        m_axi_bvalid,
    output reg         m_axi_bready,
    input  wire [ 1:0] m_axi_bresp
    );
 
    ///Write Operation

    initial m_axi_awvalid = 0;
    initial m_axi_wvalid = 0;
    initial m_axi_bready = 0;
 
    always @(posedge i_clk) begin
        if (i_resetn == 1'b0) begin
            m_axi_awvalid <= 0;
            m_axi_wvalid  <= 0;
            m_axi_bready  <= 0;
        end 
        else if (m_axi_bready) begin
            if (m_axi_awready) 
                m_axi_awvalid <= 0;
            if (m_axi_wready) 
                m_axi_wvalid <= 0;
            if (m_axi_bvalid) 
                m_axi_bready <= 0;
 
        end 
        else if (i_wr) begin
            m_axi_awvalid <= 1;
            m_axi_wvalid  <= 1;
            m_axi_bready  <= 1;
        end
 
    end

    ////// Write Data
 
    initial m_axi_awaddr = 0;
 
    always @(posedge i_clk) begin
        if (i_resetn == 1'b0) 
            m_axi_awaddr <= 0;
        else if (i_wr) 
            m_axi_awaddr <= i_addrin;
        else if (m_axi_awvalid && m_axi_awready) 
            m_axi_awaddr <= 0;
    end
 
    initial m_axi_wdata = 0;
    initial m_axi_wstrb = 0;
 
    always @(posedge i_clk) begin
        if (i_resetn == 1'b0) begin
            m_axi_wdata <= 0;
            m_axi_wstrb <= 0;
        end 
        else if (i_wr) begin
            m_axi_wdata <= i_din;
            m_axi_wstrb <= i_strb;
        end 
        else if (m_axi_wvalid && m_axi_wready) begin
            m_axi_wdata <= 0;
            m_axi_wstrb <= 0;
        end
    end
 
endmodule
