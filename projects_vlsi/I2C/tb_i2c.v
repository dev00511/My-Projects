`timescale 1ns/1ps 
module tb_i2c; 
    reg        clk; 
    reg        rst_n; 
    reg        start; 
    reg  [7:0] data_in; 
    wire       scl; 
    wire       sda; 
    wire       done; 
    wire [7:0] data_out; 
 
    // Instantiate I2C master. 
    i2c_master master_inst ( 
        .clk(clk), 
        .rst_n(rst_n), 
        .start(start), 
        .data_in(data_in), 
        .scl(scl), 
        .sda(sda), 
        .done(done) 
    ); 
 
    // Instantiate I2C slave. 
    i2c_slave slave_inst ( 
        .clk(clk), 
        .rst_n(rst_n), 
        .sda(sda), 
        .scl(scl), 
        .data_out(data_out) 
    ); 
 
    // Dump waveforms for viewing. 
    initial begin 
        $dumpfile("i2c_waveform.vcd"); 
        $dumpvars(0, tb_i2c); 
    end 
 
    // Generate 100 MHz clock (10 ns period). 
    initial begin 
        clk = 0; 
        forever #5 clk = ~clk; 
    end 
 
    // Reset and stimulus. 
    initial begin 
        rst_n   = 0; 
        start   = 0; 
        data_in = 8'hA5; // Example data 
        #20;          // Hold reset for 20 ns 
        rst_n = 1; 
        #10; 
        start = 1;    // Trigger the I2C transaction 
        #10; 
        start = 0;    // Remove the start signal 
        wait(done);   // Wait for transaction to complete 
        #20; 
        $display("I2C Transaction complete. Slave received data: %h", data_out); 
        #50; 
        $finish; 
  end 
endmodule 
