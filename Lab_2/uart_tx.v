module uart_tx (
    input  wire clk,           // Clock signal
    input  wire rst,           // Reset signal (active high)
    input  wire [7:0] data_in, // Input data byte to transmit
    input  wire start,         // Transmission start trigger
    input  wire baud_tick,     // Baud rate timing tick (determines bit rate)
    output reg  tx,            // Serial transmit line (TX)
    output reg  busy           // Flag indicating transmitter is busy
);

    // --------------------------------------------------------
    // Internal state registers
    // --------------------------------------------------------
    reg [9:0] shift_reg = 10'b1111111111; // Shift register: [STOP][DATA(8)][START]
    reg [3:0] bit_index = 0;              // Bit counter (0?9)

    // --------------------------------------------------------
    // Main transmission process (clock-driven)
    // --------------------------------------------------------
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            // Reset all control and data signals
            tx <= 1'b1;                   // Idle state of TX line (logic high)
            busy <= 0;                    // Transmitter not active
            bit_index <= 0;               // Reset bit counter
            shift_reg <= 10'b1111111111;  // Clear shift register (all bits set)
        end else begin
            // ------------------------------------------------
            // Start transmission when 'start' is high and transmitter is idle
            // ------------------------------------------------
            if (start && !busy) begin
                // Frame format: [STOP=1][DATA][START=0]
                shift_reg <= {1'b1, data_in, 1'b0};
                busy <= 1;                 // Set transmitter as active
                bit_index <= 0;            // Begin from first bit
            end 
            // ------------------------------------------------
            // Transmit bits sequentially at each baud tick
            // ------------------------------------------------
            else if (busy && baud_tick) begin
                tx <= shift_reg[bit_index]; // Output current bit on TX line
                bit_index <= bit_index + 1; // Move to next bit

                // After sending all 10 bits, end transmission
                if (bit_index == 9)
                    busy <= 0;             // Transmission complete
            end
        end
    end
endmodule

