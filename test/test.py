import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles


async def reset_dut(dut):
    dut.ui_in.value = 0
    dut.uio_in.value = 0
    dut.ena.value = 1

    dut.rst_n.value = 0
    await ClockCycles(dut.clk, 5)

    dut.rst_n.value = 1
    await ClockCycles(dut.clk, 2)


async def pulse_input(dut, value):
    dut.ui_in.value = value
    await ClockCycles(dut.clk, 1)
    dut.ui_in.value = 0
    await ClockCycles(dut.clk, 1)

async def wait_for_done(dut):
    for _ in range(20):
        await ClockCycles(dut.clk, 1)

        out = int(dut.uo_out.value)

        if (out >> 7) & 1:
            return out

    assert False, "done did not go high"

@cocotb.test()
async def test_vending_machine_item_a(dut):
    clock = Clock(dut.clk, 10, units="us")
    cocotb.start_soon(clock.start())

    await reset_dut(dut)

    # start machine
    await pulse_input(dut, 0x80)

    # insert dime + nickel = 15 cents
    await pulse_input(dut, 0x02)
    await pulse_input(dut, 0x01)

    # select item A
    dut.ui_in.value = 0x08
    await ClockCycles(dut.clk, 2)
    dut.ui_in.value = 0

    out = await wait_for_done(dut)

    dispense_A = out & 0x01
    done = (out >> 7) & 0x01

    assert done == 1, "done did not go high"
    assert dispense_A == 1, "item A was not dispensed"


@cocotb.test()
async def test_vending_machine_insufficient_funds(dut):
    clock = Clock(dut.clk, 10, units="us")
    cocotb.start_soon(clock.start())

    await reset_dut(dut)

    # start machine
    await pulse_input(dut, 0x80)

    # insert only nickel = 5 cents
    await pulse_input(dut, 0x01)

    # try to select item B, which costs 25 cents
    dut.ui_in.value = 0x10
    await ClockCycles(dut.clk, 2)
    dut.ui_in.value = 0

    out = await wait_for_done(dut)

    insufficient = (out >> 3) & 0x01
    done = (out >> 7) & 0x01

    assert done == 1, "done did not go high"
    assert insufficient == 1, "insufficient funds did not go high"
