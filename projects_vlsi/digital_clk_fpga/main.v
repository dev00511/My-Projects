module digital_clock(
    input clk_100MHz,            // 100MHz system clock
    input reset_pb,               // Reset push-button to reset
                                    // the clock to 12:00
    output [6:0] seg,             // Seven segment display
                                    // output (for digits)
    output [3:0] an               // Seven segment display
                                    // anode control
);

// Clock and time variables
reg [31:0] counter = 0;
parameter max_count = 10_00_00_000;  
// 100MHz / 1Hz = 100M / 2 (for low and high pulses) = 50M

reg [5:0] hrs, min = 0;     
// hours and minutes (0-59 for minutes, 0-23 for hours)

reg [3:0] min_ones, min_tens, hrs_ones, hrs_tens = 0; 
// Seven-segment digits

// Seven-segment display module instantiation
seven_seg ssd (
    .clk_100MHz(clk_100MHz),   // Pass the clock to the
                               // seven-segment display module
    .min_ones(min_ones),
    .min_tens(min_tens),
    .hrs_ones(hrs_ones),
    .hrs_tens(hrs_tens),
    .seg(seg),
    .an(an)
);

// Main clock logic with reset and counter
always @(posedge clk_100MHz or posedge reset_pb) begin
    if (reset_pb) begin
        // Reset time to 12:00 when reset button is pressed
        hrs     <= 12;
        min     <= 0;
        counter <= 0;
    end 
    else begin
        // Increment the counter to keep track of time
        if (counter < max_count)
            counter <= counter + 1;
        else begin
            counter <= 0;
            min <= min + 1;  // Increment minutes

            if (min >= 60) begin
                min <= 0;
                hrs <= hrs + 1;  // Increment hours when
                                 // minutes reach 60
            end
        end

        if (hrs >= 24) begin
            hrs <= 0;  // Reset hours after 24
        end
    end

    // Update the digits for the seven-segment display
    min_ones <= min % 10;   // Get ones digit of minutes
    min_tens <= min / 10;   // Get tens digit of minutes

    if (hrs < 10) begin
        hrs_ones <= hrs;    // For hours 0-9
        hrs_tens <= 0;      // Tens digit for hours 0-9 will be 0
    end 
    else begin
        hrs_ones <= hrs % 10; // Get ones digit of hours
        hrs_tens <= hrs / 10; // Get tens digit of hours
    end
end

endmodule
