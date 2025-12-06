module p_s_axi (
    input wire        s_axi_aclk, 
    input wire        s_axi_aresetn,
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
        end 
        else if (s_axi_arready) begin
            s_axi_arready <= 1'b0;
        end 
        else if (s_axi_arvalid) begin
            s_axi_arready <= 1'b1;
        end
    end
     
    initial s_axi_rvalid = 0;
    always @(posedge s_axi_aclk) begin
        if (s_axi_aresetn == 1'b0) begin
            s_axi_rvalid <= 1'b0;
        end 
        else if (data_ready && !s_axi_rvalid) begin
            s_axi_rvalid <= 1; 
        end 
        else if (s_axi_rready) begin
            s_axi_rvalid <= 0;
        end
    end
     
    always @(posedge s_axi_aclk) begin
        if (s_axi_aresetn == 1'b0) begin
            state <= 0;
            data_ready <= 1'b0;
            araddr <= 0;
            rdata <= 0;
        end 
        else begin
            case(state)
            0:  begin
                    if (s_axi_arvalid) begin
                        state <= 1;
                        araddr <= s_axi_araddr;
                    end 
                    else begin
                        state <= 0;
                    end
                end
            1:  begin
                    rdata <= mem[araddr];
                    state <= 2;  
                end
            2:  begin
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
        end 
        else if (data_ready) begin
            if (araddr <= 15) begin
                rresp <= 2'b00;
            end 
            else begin
                rresp <= 2'b11;
            end
        end 
        else begin
            rresp <= 2'b00;
        end
    end
     
    assign s_axi_rdata = (s_axi_rvalid) ? rdata : 0;
    assign s_axi_rresp = (s_axi_rvalid) ? rresp : 0;
     
endmodule
