// Read Operation

`timescale 1ns / 1ps

module s_axi (
    input wire i_clk,
    input wire i_resetn,
 
    ///////////////Write Address Channel
    input  wire        s_axi_awvalid,
    output reg         s_axi_awready,
    input  wire [31:0] s_axi_awaddr,
    //////////////Write Data Channel
    input  wire        s_axi_wvalid,
    output reg         s_axi_wready,
    input  wire [31:0] s_axi_wdata,
    input  wire [ 3:0] s_axi_wstrb,
    ////////////Write Response Channel
    output reg         s_axi_bvalid,
    input  wire        s_axi_bready,
    output reg  [ 1:0] s_axi_bresp
    );
 
 
    ///////////// slave write address
    initial s_axi_awready = 0;
    always @(posedge i_clk) begin
        if (i_resetn == 1'b0) 
            s_axi_awready <= 0;
        else if (s_axi_awready) 
            s_axi_awready <= 1'b0;
        else if (s_axi_awvalid) 
            s_axi_awready <= 1'b1;
    end
 
 
    ///////////// slave write data
    initial s_axi_wready = 0;
    always @(posedge i_clk) begin
        if (i_resetn == 1'b0) 
            s_axi_wready <= 0;
        else if (s_axi_wready)
            s_axi_wready <= 1'b0;
        else if (s_axi_wvalid) 
            s_axi_wready <= 1'b1;
    end
 
    //// register addr logic
    reg [31:0] addr_in = 0;
    reg valid_a = 0;
 
    always @(posedge i_clk) begin
        if (i_resetn == 1'b0) begin
            addr_in <= 0;
            valid_a <= 0;
        end else if (s_axi_bvalid) begin
            addr_in <= 0;
            valid_a <= 0;
        end else if (s_axi_awvalid) begin
            addr_in <= s_axi_awaddr;
            valid_a <= 1'b1;
        end
    end
 
    /////// register data
    reg [31:0] data_in;
    reg valid_d = 0;
 
    always @(posedge i_clk) begin
        if (i_resetn == 1'b0) begin
            data_in <= 0;
            valid_d <= 0;
        end 
        else if (s_axi_bvalid) begin
            data_in <= 0;
            valid_d <= 0;
        end else if (s_axi_wvalid) begin
            data_in <= s_axi_wdata;
            valid_d <= 1;
        end
    end
 
 
    ///////////// update memory
    reg [31:0] mem[16];
  
    always @(posedge i_clk) begin
        if (i_resetn == 1'b0) begin
            for (int i = 0; i < 16; i++) begin
                mem[i] <= 0;
            end
        end 
        else if (valid_a && valid_d & addr_in <= 15) begin
            mem[addr_in] <= data_in;
        end
    end
  
    /////////////// generate transaction response
    initial s_axi_bvalid = 0;
    initial s_axi_bresp = 0;
  
    always @(posedge i_clk) begin
        if (i_resetn == 1'b0) begin
            s_axi_bvalid <= 0;
            s_axi_bresp  <= 0;
        end
        else if (valid_a && valid_d && !s_axi_bvalid) begin
            s_axi_bvalid <= 1;
            if (addr_in <= 15) 
                s_axi_bresp <= 2'b00;
            else 
                s_axi_bresp <= 2'b11;
        end
        else if (s_axi_bvalid) begin
            s_axi_bvalid <= 0;
            s_axi_bresp  <= 2'b00;
        end
        else begin
            s_axi_bvalid <= 0;
            s_axi_bresp  <= 2'b00;
        end
    end
  
endmodule
