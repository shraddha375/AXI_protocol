    `timescale 1ns / 1ps
     
    module p_m_axi (
        input wire         m_axi_aclk, m_axi_aresetn,
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
     
    // Read Operation
    reg wait_for_rdata = 0;
     
    initial m_axi_arvalid = 0;
    initial m_axi_araddr = 0;
    initial m_axi_rready = 0;
     
    always @(posedge m_axi_aclk) begin
        if (m_axi_aresetn == 1'b0) begin
            m_axi_arvalid <= 0;
        end else if (wait_for_rdata) begin
            if (m_axi_arready)  
                m_axi_arvalid <= 1'b0;
        end else if (i_wr == 1'b0) begin
            m_axi_arvalid <= 1'b1; 
        end
    end
     
    always @(posedge m_axi_aclk) begin
        if (m_axi_aresetn == 1'b0) begin
            m_axi_araddr <= 0;
        end else if (wait_for_rdata) begin
            if (m_axi_arready)  
                m_axi_araddr <= 0;
        end else if (i_wr == 1'b0) begin
            m_axi_araddr <= i_addrin;  
        end
    end
     
    always @(posedge m_axi_aclk) begin
        if (m_axi_aresetn == 1'b0) begin
            m_axi_rready <= 0;
        end else if (m_axi_rready) begin  
            m_axi_rready <= 0;
        end else if (m_axi_rvalid) begin
            m_axi_rready <= 1;
        end
    end
     
    always @(posedge m_axi_aclk) begin
        if (m_axi_aresetn == 1'b0) begin
            o_rdata <= 0;
            o_resp <= 0;
            wait_for_rdata <= 0;
        end else if (m_axi_rvalid && m_axi_rready) begin
            o_rdata <= m_axi_rdata;
            o_resp <= m_axi_rresp;
            wait_for_rdata <= 0;
        end else if (m_axi_arvalid) begin
            o_rdata <= 0;
            o_resp <= 0;
            wait_for_rdata <= 1;
        end
    end
     
    endmodule
     
    ////////////////////////////////////////////////////////////
     
    module p_s_axi (
        input wire        s_axi_aclk, s_axi_aresetn,
        // Read Address Channel
        input wire        s_axi_arvalid,
        output reg        s_axi_arready,
        input wire [31:0] s_axi_araddr,
        // Read Data Channel
        output reg        s_axi_rvalid,
        input wire        s_axi_rready,
        output wire [31:0] s_axi_rdata,
        output wire [1:0]  s_axi_rresp
    );
     
    // Update Memory
    reg [31:0] mem [15:0];
    integer i;
     
    always @(posedge s_axi_aclk) begin
        if (s_axi_aresetn == 1'b0) begin
            for (i = 0; i < 16; i = i + 1) begin
                mem[i] <= i * 5;
            end
        end
    end
     
    // Read Operation
    reg [31:0] araddr;
    reg [1:0] state = 0;
    reg [31:0] rdata;
    reg data_ready = 0;
     
    initial s_axi_arready = 0; 
     
    always @(posedge s_axi_aclk) begin
        if (s_axi_aresetn == 1'b0) begin
            s_axi_arready <= 1'b0;
        end else if (s_axi_arready) begin
            s_axi_arready <= 1'b0;
        end else if (s_axi_arvalid) begin
            s_axi_arready <= 1'b1;
        end
    end
     
    initial s_axi_rvalid = 0;
    always @(posedge s_axi_aclk) begin
        if (s_axi_aresetn == 1'b0) begin
            s_axi_rvalid <= 1'b0;
        end else if (data_ready && !s_axi_rvalid) begin
            s_axi_rvalid <= 1; 
        end else if (s_axi_rready) begin
            s_axi_rvalid <= 0;
        end
    end
     
    always @(posedge s_axi_aclk) begin
        if (s_axi_aresetn == 1'b0) begin
            state <= 0;
            data_ready <= 1'b0;
            araddr <= 0;
            rdata <= 0;
        end else begin
            case(state)
            0: begin
                if (s_axi_arvalid) begin
                    state <= 1;
                    araddr <= s_axi_araddr;
                end else begin
                    state <= 0;
                end
            end
            1: begin
                rdata <= mem[araddr];
                state <= 2;  
            end
            2: begin
                rdata <= mem[araddr]; 
                data_ready <= 1'b1;
                if (s_axi_rready) begin
                    state <= 0;
                    data_ready <= 1'b0;
                end
            end
            endcase
        end
    end
     
    reg [1:0] rresp;
    always @(posedge s_axi_aclk) begin
        if (s_axi_aresetn == 1'b0) begin
            rresp <= 2'b00;
        end else if (data_ready) begin
            if (araddr <= 15) begin
                rresp <= 2'b00;
            end else begin
                rresp <= 2'b11;
            end
        end else begin
            rresp <= 2'b00;
        end
    end
     
    assign s_axi_rdata = (s_axi_rvalid) ? rdata : 0;
    assign s_axi_rresp = (s_axi_rvalid) ? rresp : 0;
     
    endmodule
     
     


///////Top Code:


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


//////////////////////////////// Testbench Code:


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
