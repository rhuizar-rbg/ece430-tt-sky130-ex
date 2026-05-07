# SPDX-License-Identifier: Apache-2.0

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


async def run_multiply_case(dut, mc, mp):
    assert 0 <= mc <= 127
    assert 0 <= mp <= 255

    dut.ui_in.value = mc
    dut.uio_in.value = mp
    await ClockCycles(dut.clk, 2)

    dut.ui_in.value = (1 << 7) | mc
    await ClockCycles(dut.clk, 1)

    dut.ui_in.value = mc

    for _ in range(80):
        await ClockCycles(dut.clk, 1)
        if int(dut.uo_out.value) & 0x80:
            break

    raw_out = int(dut.uo_out.value)
    done = (raw_out >> 7) & 1
    got_product_low7 = raw_out & 0x7F
    expected_product_low7 = (mc * mp) & 0x7F

    assert done == 1, f"done never went high for mc={mc}, mp={mp}"
    assert got_product_low7 == expected_product_low7, (
        f"wrong product for mc={mc}, mp={mp}: "
        f"got low7={got_product_low7}, expected low7={expected_product_low7}"
    )


@cocotb.test()
async def test_pm32_selected_cases(dut):
    clock = Clock(dut.clk, 10, unit="us")
    cocotb.start_soon(clock.start())

    test_cases = [
        (0, 0),
        (0, 7),
        (1, 1),
        (1, 255),
        (2, 3),
        (3, 5),
        (7, 9),
        (10, 12),
        (15, 15),
        (31, 4),
        (63, 2),
        (64, 2),
        (100, 3),
        (127, 1),
        (127, 255),
    ]

    for mc, mp in test_cases:
        await reset_dut(dut)
        await run_multiply_case(dut, mc, mp)
