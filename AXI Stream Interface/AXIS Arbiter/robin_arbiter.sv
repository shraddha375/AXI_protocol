///////////Design Code:

`timescale 1ns / 1ps
     
module robin_arbiter(
    input  clk, rst,
    input  req1, req2,
    output reg gnt1, gnt2
    );

    // States that the arbiter is in:
    // idle : indicates that the arbiter is not processing either of the two requests
    // s1   : indicates it is ready to process request 1
    // s2   : indicates it is ready to process request 2 
    typedef enum bit [1:0] {idle = 2'b00, s1 = 2'b01, s2 = 2'b10} state_type;
    state_type state, next_state;  

    // At every clock tick, state goes to next_state unless there is a reset    
    always @(posedge clk) begin
        if (rst)
            state <= idle;
        else
            state <= next_state;
    end
    
    // Explains how state changes
    //Combinatorial part
    always @(*) begin
        case (state)
            idle: begin
                // When the device is in idle, req1 has a higher priority than req2 
                if (req1)
                    next_state = s1;
                else if (req2)
                    next_state = s2;
                else
                    next_state = idle;
            end
     
            s1: begin
                // When the device is in s1, req2 has a higher priority than req1
                if (req2)
                    next_state = s2;
                else if (req1)
                    next_state = s1;
                else
                    next_state = idle;
            end
     
            s2: begin
                // When the device is in s2, req1 has a higher priority than req2
                if (req1)
                    next_state = s1;
                else if (req2)
                    next_state = s2;
                else
                    next_state = idle;
            end
     
            default: begin
                next_state = idle;
            end
        endcase
    end
    
    // Explains how the grant signal behaves with state
    always @(*) begin
        case (state)
            idle: begin
                gnt1 = 1'b0;
                gnt2 = 1'b0;
            end
     
            s1: begin
                gnt1 = 1'b1;
                gnt2 = 1'b0;
            end
     
            s2: begin
                gnt1 = 1'b0;
                gnt2 = 1'b1;
            end
     
            default: begin
                gnt1 = 1'b0;
                gnt2 = 1'b0;
            end
        endcase
    end
     
endmodule
     


