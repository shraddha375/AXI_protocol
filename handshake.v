    `timescale 1ns / 1ps
     
    module handshake();
     
    localparam new_data = 0, wait_for_slave = 1;
    localparam wait_for_data = 0, process_data = 1;
     
    reg m_state = 0,s_state = 0;
     
    reg [7:0] m_data,s_data;
    reg m_validout;
    reg s_readyout;
    reg rstn;
    reg clk = 0;
     
    always #10 clk = ~clk;
     
    initial begin
    rstn = 0;
    repeat(10) @(posedge clk);
    rstn = 1;
    end
     
    //////////// master logic
     
    always@(posedge clk)
    begin
      if(rstn==1'b0)
        begin
        m_data <= 0;
        m_validout <= 0;
        end
      else
       begin
        case(m_state)
        new_data: 
            begin
               m_data <= $urandom_range(0,15);
               m_validout <= 1'b1;
               m_state      <= wait_for_slave;
            end
            
        wait_for_slave: 
            begin
               if(s_readyout)
                 begin
                 m_state <= new_data;
                 m_validout <= 1'b0;
                 end
               else
                 m_state <= wait_for_slave;
            end 
        endcase 
       end
    end
     
    /////////////////////// slave logic
     
    always@(posedge clk)
    begin
      if(rstn==1'b0)
        begin
        s_data     <= 0;
        s_readyout <= 0;
        end
      else
       begin
        case(s_state)
        wait_for_data: 
            begin
                s_readyout <= 1'b1;
                if(m_validout == 1'b1)
                   begin
                   s_state     <= process_data;
                   s_readyout <= 1'b0;
                   s_data      <= m_data;
                   end
                else
                   s_state <= wait_for_data; 
            end
        process_data: 
            begin
                s_state <= wait_for_data;
                s_readyout <= 1'b1; 
            end 
        endcase 
       end
    end
     
     
     
    endmodule
