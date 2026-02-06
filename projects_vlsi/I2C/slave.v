module i2c_slave ( 
    input  wire       clk,          // System clock (not used for sampling here) 
    input  wire       rst_n,        // Active-low reset 
    inout  wire       sda,          // I2C data (bidirectional) 
    input  wire       scl,          // I2C clock (driven by master) 
    output reg [7:0]  data_out      // Received data 
); 
 
    reg [7:0] shift_reg; 
    reg [3:0] bit_cnt; 
    
    // The slave is not driving SDA in this example. 
    assign sda = 1'bz; 
    
    // Sample data on the falling edge of SCL. 
    always @(negedge scl or negedge rst_n) begin 
        if (!rst_n) begin 
            bit_cnt   <= 0; 
            shift_reg <= 0; 
            data_out  <= 0; 
        end else begin 
            // Shift in the sampled bit. 
            shift_reg <= {shift_reg[6:0], sda}; 
            bit_cnt <= bit_cnt + 1; 
            if (bit_cnt == 3'd7) begin 
                data_out <= {shift_reg[6:0], sda}; // After 8 bits, update data_out. 
                bit_cnt <= 0; 
                shift_reg <= 0; 
            end 
        end 
    end 
 
endmodule 
