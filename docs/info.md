<!---

This file is used to generate your project datasheet. Please fill in the information below and delete any unused
sections.

You can also include images in this folder and reference them in the markdown. Each image must be less than
512 kb in size, and the combined size of all images must be less than 1 MB.
-->

## HW9 Vending Machine

## What does it do

This vending machine is implemented as a finite state machine in Verilog. The user can insert a nickel, dime, or quarter, then select item A or item B. Item A costs 15 cents and item B costs 25 cents. If the inserted balance is high enough, the machine dispenses the selected item and raises the done signal. If the balance is too low, the insufficient funds output is raised. The design also supports a cancel input that returns change.
 


## Block Diagram with info

Tiny Tapeout I/P                          ------------------                  --------------------                 Tiny Tapeout O/P
ui[0] nickel                              |Vending Machine |                  |Balance Register  |                 uo[0] dispense_a
ui[1] dime                                |Idle            |                  |Stores Inserted # |                 u0[1] dispense_b
ui[2] quarter             --------------->|Accept          |----------------->|                  |---------------->uo[2] return_change
ui[3] select_a                            |Check           |                  |                  |                 uo[3] insufficientfunds
ui[4] select_b                            |Return          |                  |                  |                 uo[4:6] balancedisplay
ui[5] cancel                              |Done            |                  |                  |                 uo[7] done
ui[7] start                               ------------------                  --------------------

ui[7] is not used
The rest of the pins are self explanatory


