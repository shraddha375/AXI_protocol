`timescale 1ns / 1ps
module axi4_slave
(
    input  wire        s_axi_aclk,
    input  wire        s_axi_aresetn,
 
    input  wire [2:0]  s_axi_awid,
    input  wire        s_axi_awvalid,
    output reg         s_axi_awready,
    input  wire [31:0] s_axi_awaddr,
    input  wire [7:0]  s_axi_awlen,
    input  wire [2:0]  s_axi_awsize,
    input  wire [1:0]  s_axi_awburst,
    input  wire [1:0]  s_axi_awlock,
    input  wire [3:0]  s_axi_awcache,
    input  wire [2:0]  s_axi_awprot,
    input  wire [3:0]  s_axi_awqos,
    input  wire [4:0]  s_axi_awuser,
 
    input  wire [2:0]  s_axi_wid,
    input  wire        s_axi_wvalid,
    output reg         s_axi_wready,
    input  wire [31:0] s_axi_wdata,
    input  wire [3:0]  s_axi_wstrb,
    input  wire        s_axi_wlast,
 
    output reg  [2:0]  s_axi_bid,
    output reg         s_axi_bvalid,
    input  wire        s_axi_bready,
    output reg  [1:0]  s_axi_bresp,
 
    input  wire [2:0]  s_axi_arid,
    input  wire        s_axi_arvalid,
    output reg         s_axi_arready,
    input  wire [31:0] s_axi_araddr,
    input  wire [7:0]  s_axi_arlen,
    input  wire [2:0]  s_axi_arsize,
    input  wire [1:0]  s_axi_arburst,
    input  wire [1:0]  s_axi_arlock,
    input  wire [3:0]  s_axi_arcache,
    input  wire [2:0]  s_axi_arprot,
    input  wire [3:0]  s_axi_arqos,
    input  wire [4:0]  s_axi_aruser,
 
    output reg  [2:0]  s_axi_rid,
    output reg         s_axi_rvalid,
    input  wire        s_axi_rready,
    output reg  [31:0] s_axi_rdata,
    output reg         s_axi_rlast,
    output reg  [1:0]  s_axi_rresp
	);
 
localparam  idle = 0,
            predict_op = 1,
            accept_wr = 2,
            wait_wdata = 3,
            accept_wdata = 4,
            gen_data = 5,
            update_mem = 6,
            check_br_len = 7,
            send_ack = 8,
            accept_rd = 9,
            fetch_rdata = 10,
            send_rdata =11,
            rcheck_br_len = 12,
            fetch_ldata = 13,
            send_rlast = 14,
            write_err = 15;
            
   
   
   
   initial begin
   s_axi_awready = 0;
   s_axi_wready = 0;
   s_axi_bid    =0;
   s_axi_bvalid = 0;
   s_axi_bresp  = 0;
   s_axi_arready = 0;
   s_axi_rid   = 0;
   s_axi_rvalid = 0;
   s_axi_rdata = 0;
   s_axi_rlast = 0;
   s_axi_rresp = 0;
   end
   
            
reg [31:0] mem [15:0];
          
reg [4:0] state = 0;
integer i = 0;
reg [7:0] burst_len = 0,rburst_len = 0;
reg [31:0] waddr = 0, wdata = 0,raddr = 0, rdata = 0; 
reg [3:0] wstrb = 0;
integer timer = 0;
reg [31:0] data_write = 0; 
reg [1:0] count = 0;
 
always @(posedge s_axi_aclk) begin
    if (s_axi_aresetn == 0) begin
        for (i = 0; i < 16; i = i + 1) begin
            mem[i] <= 0;
        end
    end else begin
        case (state)
            idle: begin
                s_axi_awready <= 1'b0;
                s_axi_wready  <= 1'b0;
                s_axi_bid     <= 3'b000;
                s_axi_bvalid  <= 1'b0;
                s_axi_bresp   <= 2'b00;
                s_axi_arready <= 1'b0;
                s_axi_rvalid  <= 1'b0;
                s_axi_rresp   <= 2'b00;
                s_axi_rid     <= 3'b000;
                s_axi_rlast   <= 1'b0;
                s_axi_rdata   <= 32'h0;
                state         <= predict_op;
            end
 
            predict_op: begin
                if (s_axi_awvalid)
                    state <= accept_wr;
                else if (s_axi_arvalid)
                    state <= accept_rd;
            end
 
            accept_wr: begin
                if (s_axi_awaddr < 16 && ((s_axi_awaddr + s_axi_awlen) < 16)) begin
                    burst_len <= s_axi_awlen + 1;
                    waddr     <= s_axi_awaddr;
                    state     <= wait_wdata;
                    s_axi_awready <= 1'b1;
                end else begin
                    s_axi_awready <= 1'b0;
                    state <= idle;
                end
            end
 
            wait_wdata: begin
                s_axi_awready <= 1'b0;
                if (s_axi_wvalid) begin
                    state <= accept_wdata;
                    wdata <= s_axi_wdata;
                    wstrb <= s_axi_wstrb;
                end else if (timer == 15) begin
                    state <= write_err;
                    timer <= 0;
                end else begin
                    timer <= timer + 1;
                    state <= wait_wdata;
                end
            end
 
            accept_wdata: begin
                s_axi_wready <= 1'b1;
                state        <= gen_data;
            end
 
            gen_data: begin
                s_axi_wready <= 1'b0;
                data_write <= {(wdata[31:24] & {8{wstrb[3]}}), 24'h0} |
                              {8'h0, (wdata[23:16] & {8{wstrb[2]}}), 16'h0} |
                              {16'h0, (wdata[15:8] & {8{wstrb[1]}}), 8'h0} |
                              {24'h0, (wdata[7:0] & {8{wstrb[0]}})};
                state <= update_mem;
            end
 
            update_mem: begin
                if (count < 2) begin
                    count <= count + 1;
                    state <= update_mem;
                    mem[waddr] <= data_write;
                end else begin
                    burst_len <= burst_len - 1;
                    count <= 0;
                    state <= check_br_len;
                end
            end
 
            check_br_len: begin
                if (burst_len == 0)
                    state <= send_ack;
                else
                    state <= wait_wdata;
            end
 
            send_ack: begin
                if (s_axi_bready) begin
                    s_axi_bvalid <= 1'b1;
                    s_axi_bresp  <= 2'b00;
                    state        <= idle;
                end else if (timer == 15) begin
                    state <= idle;
                end else begin
                    timer <= timer + 1;
                    state <= send_ack;
                end
            end
 
            accept_rd: begin
                if (s_axi_araddr < 16 && ((s_axi_araddr + s_axi_arlen) < 16)) begin
                    rburst_len <= s_axi_arlen;
                    raddr      <= s_axi_araddr;
                    state      <= fetch_rdata;
                    s_axi_arready <= 1'b1;
                end else begin
                    s_axi_arready <= 1'b0;
                    state <= idle;
                end
            end
 
            fetch_rdata: begin
                s_axi_arready <= 1'b0;
                if (count < 2) begin
                    count <= count + 1;
                    state <= fetch_rdata;
                    rdata <= mem[raddr];
                end else begin
                    count <= 0;
                    state <= send_rdata;
                end
            end
 
            send_rdata: begin
                s_axi_rvalid <= 1'b1;
                s_axi_rdata  <= rdata;
                s_axi_rresp  <= 2'b00;
                if (s_axi_rready) begin
                    state <= rcheck_br_len;
                end else if (timer == 15) begin
                    state <= idle;
                    timer <= 0;
                end else begin
                    state <= send_rdata;
                    timer <= timer + 1;
                end
            end
 
            rcheck_br_len: begin
                rburst_len <= rburst_len - 1;
                s_axi_rvalid <= 1'b0;
 
                if (rburst_len == 1) begin
                    state <= fetch_ldata;
                end else begin
                    state <= fetch_rdata;
                end
            end
 
            fetch_ldata: begin
                if (count < 2) begin
                    count <= count + 1;
                    state <= fetch_ldata;
                    rdata <= mem[raddr];
                end else begin
                    count <= 0;
                    state <= send_rlast;
                    s_axi_rvalid <= 1'b1;
                    s_axi_rdata  <= rdata;
                    s_axi_rresp  <= 2'b00;
                    s_axi_rlast  <= 1'b1;
                end
            end
 
            send_rlast: begin
                if (s_axi_rready) begin
                    state <= idle;
                    s_axi_rvalid <= 1'b0;
                    s_axi_rdata  <= 0;
                    s_axi_rresp  <= 2'b00;
                    s_axi_rlast  <= 1'b0;
                    timer        <= 0;
                end else if (timer == 15) begin
                    state <= idle;
                    timer <= 0;
                end else begin
                    state <= send_rlast;
                    timer <= timer + 1;
                end
            end
 
            default: state <= idle;
        endcase
    end
end
 
 
endmodule
