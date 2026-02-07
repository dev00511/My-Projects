module seven_seg_disp_module( 
input clk_100MHz, 
input [3:0] min_ones, min_tens, hrs_ones, hrs_tens, 
output reg [6:0] seg, 
output reg [3:0] an 
); 
// Declaring registers and wires 
reg [1:0] digit_display_ssd = 0; 
reg [6:0] display_ssd [3:0]; 
reg [18:0] counter = 0; 
parameter max_count = 500000; // 100MHz/100Hz = 1M/2 (for low 
and high pulses) = 500,000; 
wire [3:0] four_bit_ssd [3:0]; 
// Assigning values that need to be displayed on the SSD 
assign four_bit_ssd[0] = min_ones; 
assign four_bit_ssd[1] = min_tens; 
assign four_bit_ssd[2] = hrs_ones; 
assign four_bit_ssd[3] = hrs_tens; 
// Generating 100Hz slow clock from the inbuilt 100MHz clock 
always @(posedge clk_100MHz) begin 
if(counter < max_count) 
counter <= counter + 1; 
else begin 
digit_display_ssd <= digit_display_ssd + 1; 
counter <= 0; 
end 
// BCD to seven segment display 
case(four_bit_ssd[digit_display_ssd]) 
4'b0000: display_ssd[digit_display_ssd] <= 7'b0000001; // 0 
4'b0001: display_ssd[digit_display_ssd] <= 7'b1001111; // 1 
4'b0010: display_ssd[digit_display_ssd] <= 7'b0010010; // 2 
4'b0011: display_ssd[digit_display_ssd] <= 7'b0000110; // 3 
4'b0100: display_ssd[digit_display_ssd] <= 7'b1001100; // 4 
4'b0101: display_ssd[digit_display_ssd] <= 7'b0100100; // 5 
4'b0110: display_ssd[digit_display_ssd] <= 7'b0100000; // 6 
4'b0111: display_ssd[digit_display_ssd] <= 7'b0001111; // 7 
4'b1000: display_ssd[digit_display_ssd] <= 7'b0000000; // 8 
4'b1001: display_ssd[digit_display_ssd] <= 7'b0001000; // 9 
default: display_ssd[digit_display_ssd] <= 7'b1111111;  
endcase 
// Enabling each segment and displaying the digit 
case(digit_display_ssd) 
2'b00: begin 
an <= 4'b1110; // Enable first display (min_ones) 
seg <= display_ssd[0]; 
end 
2'b01: begin 
an <= 4'b1101; // Enable second display (min_tens) 
seg <= display_ssd[1]; 
end 
2'b10: begin 
an <= 4'b1011; // Enable third display (hrs_ones) 
seg <= display_ssd[2]; 
end 
2'b11: begin 
an <= 4'b0111; // Enable fourth display (hrs_tens) 
seg <= display_ssd[3]; 
end 
endcase 
end  
endmodule
