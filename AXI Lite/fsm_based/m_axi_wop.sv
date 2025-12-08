    module axilite_m
    (    
        input wire          new_tx,
        input wire          wr,
        input wire   [31:0] waddr,
        input wire   [31:0] raddr,
        input wire   [31:0] din,
        output reg [31:0]   dout,
        output reg  [1:0]   resp,
        output reg          wr_timeout, rd_timeout, 
     
        input  wire        m_axi_aclk,
        input  wire        m_axi_aresetn,
        output reg         m_axi_awvalid,
        input wire         m_axi_awready,
        output reg [31: 0] m_axi_awaddr,
     
        output reg         m_axi_wvalid,
        input wire         m_axi_wready,
        output reg [31: 0] m_axi_wdata,
        output reg [3: 0]  m_axi_wstrb,
     
        input wire         m_axi_bvalid,
        output reg         m_axi_bready,
        input wire  [1: 0] m_axi_bresp,
     
        output reg         m_axi_arvalid,
        input wire         m_axi_arready,
        output reg [31: 0] m_axi_araddr,
     
        input wire         m_axi_rvalid,
        output reg         m_axi_rready,
        input wire [31: 0] m_axi_rdata,
        input wire  [1: 0] m_axi_rresp
    );
     
     
    /////////////write FSM    
     
    localparam wr_idle            = 0, 
               wait_for_wr_op     = 1,
               waddr_write        = 2,
               wait_for_wdata_ack = 3,
               wait_for_wr_resp   = 4,
               no_ack_wdata       = 5,
               no_ack_waddr       = 6,
               no_slave_wr_resp   = 7,
               comp_wr_tx         = 8;
               
    reg [3:0] wstate      = wr_idle;
    reg [3:0] wnext_state = wr_idle;
    reg [3:0] wr_count    = 0;
               
    ////////////////reset decoding
    always @(posedge m_axi_aclk) begin
        if (m_axi_aresetn == 1'b0)
            wstate <= wr_idle;
        else
            wstate <= wnext_state;        
    end
     
    /////////////////next state decoder
    always @(*) begin
        case (wstate)
            wr_idle: begin
                m_axi_awvalid = 0;
                m_axi_awaddr  = 0;
                m_axi_wvalid  = 0;
                m_axi_wdata   = 0;
                m_axi_wstrb   = 0;
                m_axi_bready  = 0;
                wr_timeout    = 1'b0;
                if(new_tx == 1'b1)
                wnext_state   = wait_for_wr_op;
                else
                wnext_state   = wr_idle;
            end
     
            wait_for_wr_op: begin
                if (wr == 1)
                    wnext_state = waddr_write;
                else
                    wnext_state = wr_idle;
            end
     
            waddr_write: begin
                m_axi_wstrb   = 4'b1111;
                m_axi_awvalid = 1;
                m_axi_wvalid  = 1;
                m_axi_awaddr  = waddr;
                m_axi_wdata   = din;
                m_axi_bready  = 1;
                
                if (m_axi_awready == 1 && m_axi_wready == 1)
                    wnext_state = wait_for_wr_resp;
                else if (m_axi_awready == 1)
                    wnext_state = wait_for_wdata_ack;
                else if (wr_count == 15)
                    wnext_state = no_ack_waddr;
                else
                    wnext_state = waddr_write;
            end
     
            wait_for_wdata_ack: begin
                m_axi_awvalid = 0;
                m_axi_awaddr  = 0;
                if (m_axi_wready == 1)
                    wnext_state = wait_for_wr_resp;
                else if (wr_count == 14)
                    wnext_state = no_ack_wdata;
                else
                    wnext_state = wait_for_wdata_ack;     
            end
     
            wait_for_wr_resp: begin
                m_axi_awvalid = 0;
                m_axi_wvalid  = 0;
                m_axi_wdata   = 0;
                m_axi_awaddr  = 0;
                if (m_axi_bvalid == 1)
                    wnext_state = comp_wr_tx;
                else if (wr_count == 14)
                    wnext_state = no_slave_wr_resp;
            end
     
            no_ack_wdata, no_ack_waddr: begin
                    wr_timeout  = 1'b1;
                if (m_axi_bvalid == 1)
                    wnext_state = comp_wr_tx;
                else if (wr_count == 14)
                    wnext_state = no_slave_wr_resp;
            end
     
            no_slave_wr_resp: begin
                wr_timeout  = 1'b1;
                wnext_state = wr_idle;
            end
     
            comp_wr_tx: begin
                m_axi_bready  = 0;
                wnext_state = wr_idle;
            end
     
            default: wnext_state = wr_idle;
        endcase
    end
     
    wire first;
    reg first_d;
    assign first = (wstate != wnext_state) ? 1'b1 : 0;
     
    always@(posedge m_axi_aclk)
    begin
    first_d <= first;
    end
     
     
    ///////write counter
    always @(posedge m_axi_aclk) begin
        case (wstate)
            wr_idle:                    wr_count <= 0;
            
            wait_for_wr_op:             wr_count <= 0;
            
            waddr_write   :             wr_count <= wr_count + 1;
            
            wait_for_wdata_ack:
            begin
            if(first_d)
            wr_count <= 0;
            else
            wr_count <= wr_count + 1;
            end
            
            wait_for_wr_resp:
            begin
            if(first_d)
            wr_count <= 0;
            else
            wr_count <= wr_count + 1;
            end
            
            no_ack_wdata:
            begin
            if(first_d)
            wr_count <= 0;
            else
            wr_count <= wr_count + 1;
            end
            
            no_ack_waddr:
            begin
            if(first_d)
            wr_count <= 0;
            else
            wr_count <= wr_count + 1;
            end
                      
            no_slave_wr_resp:           wr_count <= 0;
            
            comp_wr_tx:                 wr_count <= 0;
               
            default:                    wr_count <= 0;
        endcase
    end
     
     
     
    /////////////////read FSM
     
    localparam rd_idle         = 0, 
               wait_for_rd_op  = 1,
               raddr_write     = 2,
               wait_for_rdata  = 3,
               no_resp_raddr   = 4,
               no_resp_rdata   = 5,
               comp_rd_tx      = 6;
     
    reg [2:0] rstate      = rd_idle, rnext_state = rd_idle;
    reg [3:0] rd_count    = 0;
     
    always @(posedge m_axi_aclk) begin
        if (m_axi_aresetn == 1'b0)
            rstate <= rd_idle;
        else
            rstate <= rnext_state;
    end
     
    //////////
    always @(*) begin
        case (rstate)
            rd_idle: begin
                m_axi_arvalid = 0;
                m_axi_araddr  = 0;
                m_axi_rready  = 0;
                dout          = 0;
                resp          = 0;
                rd_timeout    = 1'b0;
                
                if(new_tx == 1'b1)
                rnext_state   = wait_for_rd_op;
                else
                rnext_state   =  rd_idle;
                
            end
     
            wait_for_rd_op: begin
                if (wr == 0)
                    rnext_state = raddr_write;
                else
                    rnext_state = rd_idle;
            end
     
            raddr_write: begin
                m_axi_arvalid = 1;
                m_axi_araddr  = raddr;
                m_axi_rready  = 1'b1;
                
                if(m_axi_arready == 1 && m_axi_rvalid == 1)
                    rnext_state = comp_rd_tx;
                else if (m_axi_arready == 1)
                    rnext_state = wait_for_rdata;
                else if (rd_count == 15)
                    rnext_state = no_resp_raddr;
                else
                    rnext_state = raddr_write;
            end
     
            wait_for_rdata: begin
                m_axi_arvalid = 0;
                m_axi_araddr  = 0;
                if (m_axi_rvalid == 1)
                    rnext_state = comp_rd_tx;
                else if (rd_count == 14)
                    rnext_state = no_resp_rdata;
            end
     
            no_resp_raddr, no_resp_rdata: begin
                rd_timeout  = 1'b1;
                rnext_state = rd_idle;
            end
     
            comp_rd_tx: begin
                m_axi_rready  = 1'b0;
                m_axi_arvalid = 1'b0;
                dout          = m_axi_rdata;
                resp          = m_axi_rresp;
                rnext_state   = rd_idle;
            end
     
            default: rnext_state = rd_idle;
        endcase
    end
     
     
    wire first_r;
    reg first_d_r;
    assign first_r = (rstate != rnext_state) ? 1'b1 : 0;
     
    always@(posedge m_axi_aclk)
    begin
    first_d_r <= first_r;
    end
     
     
     
    //////////////read counter
    always @(posedge m_axi_aclk) begin
        case (rstate)
            rd_idle,
            wait_for_rd_op,
            no_resp_raddr,
            no_resp_rdata,
            comp_rd_tx: rd_count <= 0;
     
            raddr_write : rd_count <= rd_count + 1;
            wait_for_rdata: 
            begin
            if(first_d_r)
            rd_count <= 0;
            else
            rd_count <= rd_count + 1;
            end
     
            default: rd_count <= 0;
        endcase
    end
     
      
     
     
    endmodule
     
     
    ///////////////////////////
     
     
    module tb_axilite_m;
     
        reg         new_tx = 0;
        wire        wr_timeout, rd_timeout; 
        reg         wr;
        reg  [31:0] waddr;
        reg  [31:0] raddr;
        reg  [31:0] din;
        wire [31:0] dout;
        wire  [1:0] resp;
     
        reg         m_axi_aclk;
        reg         m_axi_aresetn;
        wire        m_axi_awvalid;
        reg         m_axi_awready;
        wire [31:0] m_axi_awaddr;
        wire  [1:0] m_axi_awprot;
     
        wire        m_axi_wvalid;
        reg         m_axi_wready;
        wire [31:0] m_axi_wdata;
        wire  [3:0] m_axi_wstrb;
     
        reg         m_axi_bvalid;
        wire        m_axi_bready;
        reg  [1:0]  m_axi_bresp;
     
        wire        m_axi_arvalid;
        reg         m_axi_arready;
        wire [31:0] m_axi_araddr;
        wire  [1:0] m_axi_arprot;
     
        reg         m_axi_rvalid;
        wire        m_axi_rready;
        reg  [31:0] m_axi_rdata;
        reg  [1:0]  m_axi_rresp;
     
        // Instantiate the DUT (Device Under Test)
        axilite_m uut (
            .new_tx(new_tx),
            .wr_timeout(wr_timeout),
            .rd_timeout(rd_timeout),
            .wr(wr),
            .waddr(waddr),
            .raddr(raddr),
            .din(din),
            .dout(dout),
            .resp(resp),
            .m_axi_aclk(m_axi_aclk),
            .m_axi_aresetn(m_axi_aresetn),
            .m_axi_awvalid(m_axi_awvalid),
            .m_axi_awready(m_axi_awready),
            .m_axi_awaddr(m_axi_awaddr),
            .m_axi_wvalid(m_axi_wvalid),
            .m_axi_wready(m_axi_wready),
            .m_axi_wdata(m_axi_wdata),
            .m_axi_wstrb(m_axi_wstrb),
            .m_axi_bvalid(m_axi_bvalid),
            .m_axi_bready(m_axi_bready),
            .m_axi_bresp(m_axi_bresp),
            .m_axi_arvalid(m_axi_arvalid),
            .m_axi_arready(m_axi_arready),
            .m_axi_araddr(m_axi_araddr),
            .m_axi_rvalid(m_axi_rvalid),
            .m_axi_rready(m_axi_rready),
            .m_axi_rdata(m_axi_rdata),
            .m_axi_rresp(m_axi_rresp)
        );
     
        // Clock generation
        always #5 m_axi_aclk = ~m_axi_aclk;
     
        integer i = 0;
        initial begin
            // Initialize signals
            m_axi_aclk = 0;
            m_axi_aresetn = 0;
            wr = 0;
            waddr = 32'h0;
            raddr = 32'h0;
            din = 32'h0;
            m_axi_awready = 0;
            m_axi_wready = 0;
            m_axi_bvalid = 0;
            m_axi_bresp = 2'b00;
            m_axi_arready = 0;
            m_axi_rvalid = 0;
            m_axi_rdata = 32'h0;
            m_axi_rresp = 2'b00;
     
            // Reset sequence
            #10;
            m_axi_aresetn = 1;
     
            // Write operation
            for (i = 0; i < 10; i = i + 1) begin
                @(posedge m_axi_aclk);
                new_tx = 1'b1;
                wr = 1;
                waddr = i;
                din = i;
                repeat(7) @(posedge m_axi_aclk);
                new_tx = 0;
                m_axi_awready = 1;
                m_axi_wready = 1;
                repeat(7) @(posedge m_axi_aclk);
                m_axi_awready = 0;
                m_axi_wready = 0;
                m_axi_bvalid = 1;
                m_axi_bresp = 2'b00;
                @(posedge m_axi_aclk);
                m_axi_bvalid = 0;
            end
     
            // Read operation
            for (i = 0; i < 10; i = i + 1) begin
                @(posedge m_axi_aclk);
                new_tx = 1;
                wr = 0;
                raddr = i;
                repeat(8) @(posedge m_axi_aclk);
                new_tx = 0;
                m_axi_arready = 1;
                m_axi_rdata = 5;
                m_axi_rresp = 2'b00;
                m_axi_rvalid = 1;
                @(posedge m_axi_aclk);
                m_axi_arready = 0;
                m_axi_rvalid = 0;
                m_axi_rdata = 0;
                m_axi_rresp = 2'b00;
            end
     
            $finish;
        end
     
    endmodule
