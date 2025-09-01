/////Design Code:

module axis_fifo(
    // Input side the AXIS FIFO    
    input  wire                   aclk,
    input  wire                   aresetn,
    input  wire                   s_axis_tvalid,
    input  wire  [7:0]            s_axis_tdata,
    input  wire                   s_axis_tkeep,
    input  wire                   s_axis_tlast,
    // Output side of AXIS FIFO
    output reg                    m_axis_tvalid,  // output to mux
    output reg   [7:0]            m_axis_tdata,   // output to mux
    output reg                    m_axis_tkeep,   // output to mux
    output reg                    m_axis_tlast,   // output to mux
    input  wire                   m_axis_tready   // input from mux
    );
    
    // Data Storage elements in the FIFO, depth of FIFO = 16
    // d : Data (8 bits) ; k : Keep ; l : Last
    reg [7:0] mem_d [16];
    reg       mem_k [16];
    reg       mem_l [16];
    
    // Pointers for Read and Write
    reg [4:0] wr_ptr;
    reg [4:0] rd_ptr;
    
    // Internal signals of the FIFO to indicate if the FIFO is full or empty
    wire full;
    wire empty;
    // Keeps track of which element is being written or read
    reg [4:0] count;
    
    // Logic for full and empty signals
    assign full  = (count == 5'd15) ? 1 : 0;
    assign empty = (count == 5'd0)  ? 1 : 0;
    
    // Sequential section of the circuit
    always @(posedge aclk) begin

        if(aresetn == 1'b0) begin
            // Internal Signals: 
            wr_ptr        <= 0;
            rd_ptr        <= 0;
            count         <= 0;
            // Output Pins:
            m_axis_tvalid <= 1'b0;
            m_axis_tkeep  <= 1'b0;
            m_axis_tlast  <= 1'b0;
            m_axis_tdata  <= 8'h00;
        
            // Initialize memory:
            for (int i = 0; i < 16; i++) begin
                mem_d[i]    <= 8'h00;
                mem_k[i]    <= 1'b0;
                mem_l[i]    <= 1'b0;
            end
        end
       
        // Update FIFO memory
        else if (s_axis_tvalid == 1'b1 && full == 1'b0) begin
            // Data gets written into FIFO
            mem_d[wr_ptr]   <= s_axis_tdata;
            mem_k[wr_ptr]   <= s_axis_tkeep;
            mem_l[wr_ptr]   <= s_axis_tlast;
            // Write pointer and Counter gets updated
            wr_ptr          <= wr_ptr + 1;
            count           <= count + 1;
            // Output pins are no longer active
            m_axis_tvalid   <= 1'b0;
            m_axis_tkeep    <= 1'b0;
            m_axis_tlast    <= 1'b0;
            m_axis_tdata    <= 8'h00;
        end  
      
        // Read data from the FIFO if it's not empty and Consumer is ready
        else if (m_axis_tready == 1'b1 && empty == 1'b0) begin
            // Output data receives data from FIFO
            m_axis_tdata   <= mem_d[rd_ptr] ;
            m_axis_tkeep   <= mem_k[rd_ptr];
            m_axis_tlast   <= mem_l[rd_ptr];
            // Output pins : valid is made high after the ready signal whereas in AXI, the two signals are independent
            m_axis_tvalid  <= 1'b1;
            // Read pointer and Counter gets updated
            rd_ptr         <= rd_ptr + 1;
            count          <= count - 1;
        end
    end
endmodule
     