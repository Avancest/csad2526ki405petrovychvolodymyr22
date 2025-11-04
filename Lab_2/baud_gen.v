// ------------------------------------------------------------
// Module: Baud Rate Generator (baud_gen)
// ------------------------------------------------------------
module baud_gen #(
    parameter CLK_FREQ  = 1000000,  // System clock frequency (e.g., 1 MHz)
    parameter BAUD_RATE = 9600      // Desired UART baud rate
)(
    input  wire clk,  // System clock input
    input  wire rst,  // Reset signal (active high)
    output reg  tick  // Output pulse ? "baud tick" for UART TX/RX
);

    // --------------------------------------------------------
    // Compute clock divider
    // --------------------------------------------------------
    localparam integer DIVISOR = CLK_FREQ / BAUD_RATE; 
    // Example: 1_000_000 / 9600 ? 104 ? one tick every 104 clock cycles

    // --------------------------------------------------------
    // Counter to generate baud tick
    // --------------------------------------------------------
    reg [31:0] counter = 0;  // Counts clock cycles until next tick

    // --------------------------------------------------------
    // Main process to generate baud_tick
    // --------------------------------------------------------
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            // Reset counter and output tick
            counter <= 0;
            tick <= 0;
        end else begin
            // If counter reaches divisor, generate tick
            if (counter == DIVISOR - 1) begin
                counter <= 0;  // Restart counter
                tick <= 1;     // Pulse active for one clock cycle
            end else begin
                counter <= counter + 1; // Increment counter
                tick <= 0;              // Tick inactive
            end
        end
    end
endmodule

