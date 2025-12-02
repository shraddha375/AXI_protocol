    `timescale 1ns / 1ps
     
     
    module p_m_axi(
    		input	wire			m_axi_aclk, m_axi_aresetn,
     
    		input	wire			i_wr,
    		input	wire	[31:0]	i_din,
    		input   wire    [3:0]   i_strb,
    		input   wire    [31:0]  i_addrin,
     
    ///////////////Write Address Channel
    		output	reg			    m_axi_awvalid,
    		input	wire			m_axi_awready,
    		output	reg	    [31:0]  m_axi_awaddr,
    //////////////Write Data Channel
    		output	reg			    m_axi_wvalid,
    		input	wire			m_axi_wready,
    		output	reg	    [31:0]	m_axi_wdata,
    		output	reg     [3:0]	m_axi_wstrb,
    ////////////Write Response Channel
    		input	wire			m_axi_bvalid,
    		output	reg			    m_axi_bready,
    		input	wire	[1:0]	m_axi_bresp
        );
        
    ///Write Opeartion
     
        
    initial m_axi_awvalid = 0;
    initial m_axi_wvalid  = 0;
    initial m_axi_bready  = 0; 
        
    always@(posedge m_axi_aclk)
    begin
            if(m_axi_aresetn == 1'b0)
            begin
                    m_axi_awvalid <= 0;
                    m_axi_wvalid  <= 0;
                    m_axi_bready  <= 0;
            end   
            else if (m_axi_bready)
            begin
                    if(m_axi_awready)
                        m_axi_awvalid <= 0;
                    
                    if(m_axi_wready)
                        m_axi_wvalid  <= 0;
                        
                    if(m_axi_bvalid)
                       m_axi_bready  <= 0;
                        
            end
            else if(i_wr)
            begin
                    m_axi_awvalid <= 1;
                    m_axi_wvalid  <= 1;
                    m_axi_bready  <= 1;       
            
            end
            
    end   
    ////// Write Data
     
    initial m_axi_awaddr = 0;
     
    always@(posedge m_axi_aclk)
    begin
            if(m_axi_aresetn == 1'b0)
            m_axi_awaddr <= 0;
            else if (i_wr)
            m_axi_awaddr <= i_addrin;
            else if (m_axi_awvalid && m_axi_awready )  
            m_axi_awaddr <= 0;
    end    
     
    ///////    
     
    initial m_axi_wdata = 0;
    initial m_axi_wstrb = 0;
     
    always@(posedge m_axi_aclk)
    begin
            if(m_axi_aresetn == 1'b0)
            begin
            m_axi_wdata <= 0;
            m_axi_wstrb <= 0;
            end
            else if (i_wr)
            begin
            m_axi_wdata <= i_din;
            m_axi_wstrb <= i_strb;
            end
            else if (m_axi_wvalid && m_axi_wready ) 
            begin 
            m_axi_wdata <= 0;
            m_axi_wstrb <= 0;
            end
    end 
     
        
    endmodule
     
     
    module p_s_axi(
    		input	wire			s_axi_aclk, s_axi_aresetn,
     
    ///////////////Write Address Channel
    		input	wire			    s_axi_awvalid,
    		output	reg			        s_axi_awready,
    		input	wire	    [31:0]  s_axi_awaddr,
    //////////////Write Data Channel
    		input	wire			    s_axi_wvalid,
    		output	reg			        s_axi_wready,
    		input	wire	    [31:0]	s_axi_wdata,
    		input	wire        [3:0]	s_axi_wstrb,
    ////////////Write Response Channel
    		output	reg			        s_axi_bvalid,
    		input	wire			    s_axi_bready,
    		output	reg	        [1:0]	s_axi_bresp
    		
    		
        );
        
     
    ///////////// slave write address
    initial s_axi_awready = 0; 
    always@(posedge s_axi_aclk)
    begin
            if(s_axi_aresetn == 1'b0)
                    s_axi_awready <= 0;
            else if (s_axi_awready)
                    s_axi_awready <= 1'b0;
            else if (s_axi_awvalid)
                    s_axi_awready <= 1'b1;
    end   
     
     
    ///////////// slave write data
    initial s_axi_wready  = 0;
    always@(posedge s_axi_aclk)
    begin
            if(s_axi_aresetn == 1'b0)
                    s_axi_wready <= 0;
            else if (s_axi_wready)
                    s_axi_wready <= 1'b0;
            else if (s_axi_wvalid)
                    s_axi_wready <= 1'b1;
    end 
     
     
     
    //// register addr logic
    reg [31:0] addr_in    = 0;
    reg valid_a = 0;
     
     
    always@(posedge s_axi_aclk)
    begin
            if(s_axi_aresetn == 1'b0)
            begin
                    addr_in       <= 0;
                    valid_a       <= 0;
                    
            end 
            else if (s_axi_bvalid)
            begin
                    addr_in       <= 0;
                    valid_a       <= 0;
            end  
            else if (s_axi_awvalid)
            begin
                    addr_in       <= s_axi_awaddr;
                    valid_a       <= 1'b1;          
            end
     
    end 
     
     
     
    /////// register data
    reg [31:0]  data_in;
    reg valid_d = 0;
     
    always@(posedge s_axi_aclk)
    begin
            if(s_axi_aresetn == 1'b0)
            begin
                    data_in       <= 0;
                    valid_d       <= 0;
            end
            else if (s_axi_bvalid)
            begin
                    data_in      <= 0;
                    valid_d      <= 0;
            end   
            else if (s_axi_wvalid)
            begin
                    data_in      <= s_axi_wdata;
                    valid_d      <= 1;         
            end
     
    end 
     
     
    ///////////// update memory
    reg [31:0] mem [15:0];
    integer i = 0;
     
    always@(posedge s_axi_aclk)
    begin
    if(s_axi_aresetn == 1'b0)
    begin
            for( i = 0; i < 16 ; i = i + 1) // int i = 0, i++ i = i+1
            begin
            mem[i] <= 0;
            end
    end
    else if (valid_a && valid_d & addr_in <= 15)
    begin
            mem[addr_in] <= data_in;
    end
    end
     
    /////////////// generate transaction response
    initial s_axi_bvalid  = 0; 
    initial s_axi_bresp   = 0; 
     
    always@(posedge s_axi_aclk)
    begin
            if(s_axi_aresetn == 1'b0)
            begin
                    s_axi_bvalid  <= 0;
                    s_axi_bresp   <= 0;
            end   
            else if (valid_a && valid_d && !s_axi_bvalid )
            begin
                    s_axi_bvalid  <= 1;
                    if(addr_in <= 15)
                        s_axi_bresp <= 2'b00;
                    else          
                        s_axi_bresp <= 2'b11;     
            end
            else if (s_axi_bvalid)
            begin
                     s_axi_bvalid  <= 0;
                     s_axi_bresp   <= 2'b00;  
            end
            else 
            begin
                     s_axi_bvalid  <= 0;
                     s_axi_bresp   <= 2'b00;          
            end
    end
     
        
    endmodule
     
    //////////////////
