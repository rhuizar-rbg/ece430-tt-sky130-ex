module vending_machine (
    input clk,
    input rst,
    input start,
    input nickel,
    input dime,
    input quarter,
    input select_A,
    input select_B,
    input cancel,
    output reg dispense_A,
    output reg dispense_B,
    output reg return_change,
    output reg insufficient_funds,
    output reg done,
    output reg [2:0] balance_display
);

    localparam IDLE = 0;
    localparam ACCEPT = 1;
    localparam CHECK = 2;
    localparam DISPENSE = 3;
    localparam RETURN = 4;
    localparam DONE = 5;

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
            dispense_A <= 0;
            dispense_B <= 0;
            return_change <= 0;
            insufficient_funds <= 0;
            done <= 0;

            case (state)
                IDLE: begin
                    balance <= 0;
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
                    if (select_A && balance >= 15) begin
                        dispense_A <= 1;
                        state <= DISPENSE;
                    end else if (select_B && balance >= 25) begin
                        dispense_B <= 1;
                        state <= DISPENSE;
                    end else begin
                        insufficient_funds <= 1;
                        state <= DONE;
                    end
                end

                DISPENSE: begin
                    done <= 1;
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
            endcase
        end
    end

endmodule
