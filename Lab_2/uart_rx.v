module uart_rx (
    input  wire clk,        // System clock
    input  wire rst,        // Reset signal (active high)
    input  wire rx,         // UART receive line (RX)
    input  wire baud_tick,  // Baud rate timing tick
    output reg [7:0] data_out, // Received 8-bit data
    output reg ready           // Flag indicating data is ready to read
);

    // --------------------------------------------------------
    // Finite State Machine (FSM) states for UART receiver
    // --------------------------------------------------------
    reg [2:0] state;

    localparam IDLE  = 3'd0;  // Waiting for start bit
    localparam START = 3'd1;  // Start bit validation
    localparam DATA  = 3'd2;  // Receiving 8 data bits
    localparam STOP  = 3'd3;  // Waiting for stop bit

    initial state = IDLE;     // Initial state

    // --------------------------------------------------------
    // Internal registers
    // --------------------------------------------------------
    reg [3:0] bit_index = 0;   // Counter for received bits (0?7)
    reg [7:0] rx_shift = 0;    // Temporary shift register for incoming bits
    reg [15:0] baud_count = 0; // Counter for baud_tick timing

    // --------------------------------------------------------
    // Main UART reception process (clock-driven)
    // --------------------------------------------------------
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            // Reset all internal registers and outputs
            state <= IDLE;
            bit_index <= 0;
            rx_shift <= 0;
            baud_count <= 0;
            ready <= 0;
            data_out <= 0;
        end else begin
            // Default: ready is low
            ready <= 0;

            // UART receiver state machine
            case (state)

                // ------------------------------------------------
                // IDLE state: wait for start bit (RX goes low)
                // ------------------------------------------------
                IDLE: begin
                    if (!rx) begin            // Detect falling edge on RX
                        state <= START;       // Move to START state
                        baud_count <= 0;      // Reset baud counter
                    end
                end

                // ------------------------------------------------
                // START state: wait for middle of start bit
                // ------------------------------------------------
                START: begin
                    if (baud_tick) baud_count <= baud_count + 1;

                    // After half a bit period, confirm start bit
                    if (baud_count == 1) begin
                        baud_count <= 0;
                        bit_index <= 0;
                        state <= DATA;        // Begin receiving data bits
                    end
                end

                // ------------------------------------------------
                // DATA state: read 8 data bits sequentially
                // ------------------------------------------------
                DATA: begin
                    if (baud_tick) begin
                        rx_shift[bit_index] <= rx; // Store current bit
                        bit_index <= bit_index + 1;
                        
                        // After 8 bits, move to STOP state
                        if (bit_index == 7)
                            state <= STOP;
                    end
                end

                // ------------------------------------------------
                // STOP state: check stop bit and finalize reception
                // ------------------------------------------------
                STOP: begin
                    if (baud_tick) begin
                        data_out <= rx_shift;   // Output received byte
                        ready <= 1;             // Indicate data is ready
                        state <= IDLE;          // Return to IDLE
                    end
                end

            endcase
        end
    end
endmodule


