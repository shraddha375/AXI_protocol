module axis_m(
    input  wire m_axis_aclk,
    input  wire m_axis_aresetn,
    input  wire newd,
    input  wire [7:0] din,
    input  wire m_axis_tready,
    output wire m_axis_tvalid,
    output wire [7:0] m_axis_tdata,
    output wire m_axis_tlast 
);
        
    typedef enum bit {idle = 1'b0, tx = 1'b1} state_type;
    state_type state = idle, next_state = idle;
        
    reg [2:0] count = 0;
        
    always@(posedge m_axis_aclk) begin
        if(m_axis_aresetn == 1'b0)
            state <= idle;
        else
            state <= next_state;
    end
        
    always@(posedge m_axis_aclk) begin
        if(state == idle)
            count <= 0;       
        else if(state == tx && count != 3 && m_axis_tready == 1'b1)
            count <= count + 1;
        else
            count <= count;
    end
        
    always@(*) begin
        case(state)
            idle:
                begin  
                    if(newd == 1'b1)
                        next_state = tx;
                    else
                        next_state = idle;
                end
                   
            tx:
                begin
                    if(m_axis_tready == 1'b1) begin                    
                        if(count != 3)
                            next_state  = tx;
                        else
                            next_state  = idle;
                    end
                    else begin
                        next_state  = tx;
                    end 
                end
                   
            default: next_state = idle;
                
        endcase    
    end
            
    assign m_axis_tdata   = (m_axis_tvalid) ? din*count : 0;   
    assign m_axis_tlast   = (count == 3 && state == tx) ? 1'b1 : 0;
    assign m_axis_tvalid  = (state == tx ) ? 1'b1 : 1'b0;
      
      
endmodule


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
    end
       
endmodule
