module i2c_master ( 
    input  wire       clk,         // System clock 
    input  wire       rst_n,       // Active-low reset 
    input  wire       start,       // Start signal for transmission 
    input  wire [7:0] data_in,     // Data to transmit 
    output reg        scl,         // I2C clock 
    inout  wire       sda,         // I2C data (bidirectional) 
    output reg        done         // Transaction complete 
); 
 
    reg [7:0] shift_reg; 
    reg [3:0] bit_cnt; 
    reg       sda_en;   // When asserted, drives SDA 
    reg       sda_out;  // Value driven on SDA when enabled 
 
    // Tri-state assignment: if sda_en is high, drive sda_out; else, high-Z. 
    assign sda = sda_en ? sda_out : 1'bz; 
 
    // Define states for our simple state machine. 
    localparam IDLE        = 3'd0, 
               START_STATE = 3'd1, 
               BIT_LOW     = 3'd2, 
               BIT_HIGH    = 3'd3, 
               STOP_STATE  = 3'd4, 
               DONE_STATE  = 3'd5; 
    reg [2:0] state; 
 
    always @(posedge clk or negedge rst_n) begin 
        if (!rst_n) begin 
            state     <= IDLE; 
            scl       <= 1; 
            sda_en    <= 0; 
            sda_out   <= 1; 
            bit_cnt   <= 0; 
            shift_reg <= 8'd0; 
            done      <= 0; 
        end else begin 
            case (state) 
                IDLE: begin 
                    done   <= 0; 
                    scl    <= 1; 
                    sda_en <= 0; 
                    sda_out<= 1; 
                    bit_cnt<= 0; 
                    if (start) begin 
                        shift_reg <= data_in; 
                        state     <= START_STATE; 
                    end 
                end 
 
                START_STATE: begin 
                    // Start condition: while SCL is high, pull SDA low. 
                    sda_en  <= 1; 
                    sda_out <= 0; 
                    scl     <= 1; 
                    state   <= BIT_LOW; 
                end 
 
                BIT_LOW: begin 
                    // Drive SCL low and set SDA to the current bit. 
                    scl     <= 0; 
                    sda_out <= shift_reg[7 - bit_cnt]; 
                    state   <= BIT_HIGH; 
                end 
 
                BIT_HIGH: begin 
                    // Drive SCL high so the slave can sample the bit. 
                    scl <= 1; 
                    // After SCL is high, move to next bit or finish if 8 bits sent. 
                    if (bit_cnt < 7) begin 
                        bit_cnt <= bit_cnt + 1; 
                        state   <= BIT_LOW; 
                    end else begin 
                        state <= STOP_STATE; 
                    end 
                end 
 
                STOP_STATE: begin 
                    // Generate stop condition: 
                    // First, drive SCL low and SDA low; then release SDA while SCL goes high. 
                    scl     <= 0; 
                    sda_out <= 0; 
                    state   <= DONE_STATE; 
                end 
 
                DONE_STATE: begin 
                    scl     <= 1; 
                    sda_out <= 1; 
                    sda_en  <= 0;  // Release SDA 
                    done    <= 1;  // Signal that transmission is complete 
                    state   <= IDLE; 
                end 
 
                default: state <= IDLE; 
            endcase 
        end 
 end 
endmodule 
