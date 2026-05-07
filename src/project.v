wire dispense_A;
wire dispense_B;
wire return_change;
wire insufficient_funds;
wire done;
wire [2:0] balance_display;

vending_machine vm (
    .clk(clk),
    .rst(!rst_n),
    .start(ui_in[7]),
    .nickel(ui_in[0]),
    .dime(ui_in[1]),
    .quarter(ui_in[2]),
    .select_A(ui_in[3]),
    .select_B(ui_in[4]),
    .cancel(ui_in[5]),
    .dispense_A(dispense_A),
    .dispense_B(dispense_B),
    .return_change(return_change),
    .insufficient_funds(insufficient_funds),
    .done(done),
    .balance_display(balance_display)
);

assign uo_out = {
    done,
    balance_display,
    insufficient_funds,
    return_change,
    dispense_B,
    dispense_A
};

assign uio_out = 0;
assign uio_oe = 0;

wire _unused = &{ena, ui_in[6], uio_in, 1'b0};
