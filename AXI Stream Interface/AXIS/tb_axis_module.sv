module top_tb();
      
    reg clk = 0;
    reg rst;
    reg newd;
    reg [7:0] din;
    wire [7:0] dout;
    wire last;
     
    top dut(clk,rst, newd, din, dout, last);
      
    always #10 clk = ~clk;
     
    initial begin
        // Initialize inputs
        rst = 1'b0;
        repeat(10) @(posedge clk);
        rst = 1'b1;
        for(int i = 0; i <10; i++) begin
            @(posedge clk);
            newd = 1;
            din = $urandom_range(0,15);
            @(negedge last);
        end
        $finish;
    end
  
    initial begin
        $dumpfile("dump.vcd"); 
        $dumpvars;
    end
     
endmodule
