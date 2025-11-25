module axis_s(
    input  wire s_axis_aclk,
    input  wire s_axis_aresetn,
    output wire s_axis_tready,
    input  wire s_axis_tvalid,
    input  wire [7:0] s_axis_tdata,
    input  wire s_axis_tlast,
    output wire [7:0] dout
    );
     
    // Possible states for a slave: it's receving data, receving the last byte, or sitting idle
    // Idle : No receving of data
    // Store: Storing the received data from master
    typedef enum bit {idle = 1'b0, store = 1'b1} state_type;
    
    // Default state is idle, next state will be determines based on conditions but right now inittialized to idle
    state_type state = idle, next_state = idle;

    // At every clock tick, state goes to next_state unless there is a reset
    always@(posedge s_axis_aclk) begin
        if(s_axis_aresetn == 1'b0)
            state  <= idle;
        else
            state <= next_state;
    end
     
    // Explains how state changes
    //Combinatorial part
    always@(*) begin
        case(state)
            idle:
                begin 
                    // If the master is ready 
                    if(s_axis_tvalid == 1'b1)
                        next_state = store;
                    else
                        next_state = idle;
                end
                   
            store:
                begin
                    // If the last byte has arrived
                    if(s_axis_tlast == 1'b1 && s_axis_tvalid == 1'b1 ) 
                        next_state = idle;
                    // If it is not the last byte
                    else if (s_axis_tlast == 1'b0 && s_axis_tvalid == 1'b1)
                        next_state = store;
                    else
                        next_state = idle;
                end
                    
            default: next_state = idle;
                   
        endcase
    end
            
    assign s_axis_tready = (state == store);
    assign dout          = (state == store) ? s_axis_tdata : 8'h00;
          
endmodule
