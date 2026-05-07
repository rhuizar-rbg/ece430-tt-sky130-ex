`default_nettype none

module vending_machine (
    input wire clk,
    input wire rst,
    input wire start,
    input wire nickel,
    input wire dime,
    input wire quarter,
    input wire select_A,
    input wire select_B,
    input wire cancel,
    output reg dispense_A,
    output reg dispense_B,
    output reg return_change,
    output reg insufficient_funds,
    output reg done,
    output reg [2:0] balance_display
);

    localparam IDLE   = 3'd0;
    localparam ACCEPT = 3'd1;
    localparam CHECK  = 3'd2;
    localparam RETURN = 3'd3;
    localparam DONE   = 3'd4;

    reg [2:0] state;
    reg [7:0] balance;

    always @(posedge clk) begin
        if (rst) begin
            state <= IDLE;
            balance <= 0;
            dispense_A <= 0;
            dispense_B <= 0;
            return_change <= 0;
            insufficient_funds <= 0;
            done <= 0;
            balance_display <= 0;
        end else begin
            case (state)
                IDLE: begin
                    balance <= 0;
                    dispense_A <= 0;
                    dispense_B <= 0;
                    return_change <= 0;
                    insufficient_funds <= 0;
                    done <= 0;
                    balance_display <= 0;

                    if (start)
                        state <= ACCEPT;
                end

                ACCEPT: begin
                    if (nickel)
                        balance <= balance + 5;
                    else if (dime)
                        balance <= balance + 10;
                    else if (quarter)
                        balance <= balance + 25;
                    else if (cancel)
                        state <= RETURN;
                    else if (select_A || select_B)
                        state <= CHECK;

                    balance_display <= balance[4:2];
                end

                CHECK: begin
                    done <= 1;

                    if (select_A && balance >= 15)
                        dispense_A <= 1;
                    else if (select_B && balance >= 25)
                        dispense_B <= 1;
                    else
                        insufficient_funds <= 1;

                    state <= DONE;
                end

                RETURN: begin
                    return_change <= 1;
                    done <= 1;
                    state <= DONE;
                end

                DONE: begin
                    done <= 1;

                    if (!start)
                        state <= IDLE;
                end

                default: begin
                    state <= IDLE;
                end
            endcase
        end
    end

endmodule
