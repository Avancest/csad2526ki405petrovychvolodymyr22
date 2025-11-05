`timescale 1us/1ns  // Simulation time unit: 1 microsecond, precision: 1 nanosecond

// ------------------------------------------------------------
// Testbench: uart_tb
// Purpose: Verify operation of uart_tx, uart_rx, and baud_gen modules
// ------------------------------------------------------------
module uart_tb();
    // --------------------------------------------------------
    // Control signals
    // --------------------------------------------------------
    reg clk = 0;             // System clock
    reg rst = 0;             // Reset signal
    reg start = 0;           // Transmission start signal (for TX)

    // --------------------------------------------------------
    // Test data
    // --------------------------------------------------------
    reg [7:0] data_in = 8'hA5; // Byte to transmit (0xA5 = 1010_0101)

    // --------------------------------------------------------
    // Interconnecting wires
    // --------------------------------------------------------
    wire tx;                 // Line between TX and RX
    wire busy;               // TX busy flag
    wire ready;              // RX ready flag
    wire [7:0] data_out;     // Data received by RX
    wire baud_tick;          // Baud rate pulses from baud_gen

    // --------------------------------------------------------
    // Clock generation: 1 MHz (1 탎 period)
    // --------------------------------------------------------
    always #0.5 clk = ~clk;  // Invert every 0.5 탎 ? full period = 1 탎

    // --------------------------------------------------------
    // Baud rate generator module
    // --------------------------------------------------------
    baud_gen #( 
        .CLK_FREQ(1000000),   // System clock frequency: 1 MHz
        .BAUD_RATE(9600)      // UART baud rate: 9600
    ) baud_inst (
        .clk(clk),
        .rst(rst),
        .tick(baud_tick)
    );

    // --------------------------------------------------------
    // UART transmitter module
    // --------------------------------------------------------
    uart_tx tx_unit (
        .clk(clk),
        .rst(rst),
        .data_in(data_in),     // Data to transmit
        .start(start),         // Start signal
        .baud_tick(baud_tick), // Baud rate timing
        .tx(tx),               // TX output
        .busy(busy)            // Busy flag
    );

    // --------------------------------------------------------
    // UART receiver module
    // --------------------------------------------------------
    uart_rx rx_unit (
        .clk(clk),
        .rst(rst),
        .rx(tx),               // Connect RX directly to TX
        .baud_tick(baud_tick), // Baud rate timing
        .data_out(data_out),   // Received data
        .ready(ready)          // Data ready flag
    );

    // --------------------------------------------------------
    // Test sequence
    // --------------------------------------------------------
    initial begin
        $display("=== UART Testbench start ===");
        $dumpfile("uart.vcd");    // VCD file for waveform viewing (GTKWave)
        $dumpvars(0, uart_tb);    // Record all signals in the testbench

        // Apply initial reset
        rst = 1; 
        #10;                      // Hold reset for 10 탎
        rst = 0; 

        // Trigger transmission of byte 0xA5
        #20; 
        start = 1;                // Activate start signal
        #1; 
        start = 0;                // Deactivate after 1 탎

        // Wait for reception to complete (ready == 1)
        wait(ready == 1);
        $display("RX Data = %h", data_out);  // Display received data

        // Allow some extra time after transmission
        #1000;

        // End simulation
        $stop;
    end
endmodule


