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
    
    // Possible states for a master: either it's transmitting or sitting idle
    // Idle : No transmission of data
    // Tx   : Transmitting data from master to slave
    typedef enum bit {idle = 1'b0, tx = 1'b1} state_type;

    // Default state is idle, next state will be determines based on conditions but right now inittialized to idle
    state_type state = idle, next_state = idle;
    
    // Count here acts as data to be transmitted, we may wish to use actual data as well
    reg [2:0] count = 0;

    // At every clock tick, state goes to next_state unless there is a reset    
    always@(posedge m_axis_aclk) begin
        if(m_axis_aresetn == 1'b0)
            state <= idle;
        else
            state <= next_state;
    end
    
    // (1) Count is reset to if the state returns to idle
    // (2) Count value increments under this condition
    // (3) Count value holds its value if the above condition fails 
    always@(posedge m_axis_aclk) begin
        if(state == idle)
            count <= 0;       
        else if(state == tx && count != 3 && m_axis_tready == 1'b1)
            count <= count + 1;
        else
            count <= count;
    end
    
    // Explains how state changes
    //Combinatorial part
    always@(*) begin
        case(state)
            idle:
                begin
                    // If new data is available, master goes to transmitting state  
                    if(newd == 1'b1)
                        next_state = tx;
                    else
                        next_state = idle;
                end
                   
            tx:
                begin
                    // If ready = 1, then the slave is ready to receive the data stream depending on count
                    // If ready = 0, then the master waits in transmitting state and it holds the current data value until the slave is ready again
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
            
            // Default state     
            default: next_state = idle;
                
        endcase    
    end
    // Data is made available only when the valid signal is high        
    assign m_axis_tdata   = (m_axis_tvalid) ? din*count : 0;   
    // Last signal is made high when state is in tx and count is 3, indicating the 4th byte
    assign m_axis_tlast   = (count == 3 && state == tx) ? 1'b1 : 0;
    // As soon as state goes to the transmission mode, valid is made high
    assign m_axis_tvalid  = (state == tx ) ? 1'b1 : 1'b0;
      
      
endmodule
