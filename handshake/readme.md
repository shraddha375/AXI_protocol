# Handshake mechanism between a Master and a Slave

SDRAM (Synchronous Dynamic Random-Access Memory) is widely used in embedded systems, FPGAs, and CPUs due to its high-speed data access capabilities. SDRAM cannot be directly interfaced with most processors, FPGAs, or other digital systems without proper control logic. SDRAM has a complex timing and command sequence that must be carefully managed to ensure correct operation.

An SDRAM Controller is a hardware block that:
- Interfaces between the system (CPU, FPGA, etc.) and the SDRAM.
- Converts simple read/write requests into the detailed command sequences required by the SDRAM.
- Manages all the timing, refresh, and bus control automatically.

---

## How does a DRAM work?

The fundamental memory cell within a DRAM consists of a transistor and a capacitor. 

<img src="https://github.com/shraddha375/sdram_controller/blob/main/images/image_1.jpg" width=100% height=100%>

When you want to **write** to a memory cell:
- Enable the Wordline
- Apply VDD/GND on the Bitline

<img src="https://github.com/shraddha375/sdram_controller/blob/main/images/image_2.jpg" width=100% height=100%>

 When you want to **read** from a memory cell:
- Precharge Bitline to VDD/2
- Enable Wordline
- Sense value on the Bitline
- Apply Refresh 

<p align="center">
 <img src="https://github.com/shraddha375/sdram_controller/blob/main/images/image_3.jpg" width=50% height=50%>
</p>

## Concept of Refresh

Read is a destructive process because it removes or adds extra charge to the capacitor. Hence we need to perform refresh which essentially restores the original charge on the capacitor. This is usually done by reading the cell value and writing the same value back.

Switches are made from transistors and over a period of time the charges on the capapcitirs leak. To ensure data integrity, we need to perform refresh periodically.

There are two types of refresh: 
- *Auto-Refresh*: Refreshes the capacitors during a normal operation with the SDRAM
- *Self-Refresh*: Refreshes the SDRAM in a power down mode when the clock enable is 0.

## Generartions of DRAM

### First Generation of DRAM

The first generation of DRAM looks as shown below:

<p align="center">
<img src="https://github.com/shraddha375/sdram_controller/blob/main/images/image_4.jpg" width=50% height=50%>
</p>

Inside the cell matrix, each memory bit uses one of the many outputs from Row and Column decoders:

<p align="center">
<img src="https://github.com/shraddha375/sdram_controller/blob/main/images/image_5.jpg" width=50% height=50%>
</p>

To get an idea on how row and column decoders enable one cell inside the cell matrix:

<p align="center">
<img src="https://github.com/shraddha375/sdram_controller/blob/main/images/image_6.jpg" width=25% height=25%>
</p>

In an actual 1st generation DRAM, each cell conists of 3 transistors: 

<p align="center">
<img src="https://github.com/shraddha375/sdram_controller/blob/main/images/image_10.jpg" width=50% height=50%>
</p>

When we want to carry out a Write operation, Write rowline is made high. M1 transistor turns on and whatever data present is on the Write columnline is passed to the gate of M2. The information either discharges or charges the input capacitor at the gate of M2. If we want to carry out a READ operation, precharge the Read columnline to a known value and then driving the Row rowline to high. Driving the Read rowline high turnd M3 on, and allows M2 to pull the Read coulmnline low or to not chnage the precharge voltage of the Read columnline (If the voltage at M2 is zero then M2 is OFF and the precharged value will not change whereas if the voltage at M2 is high then M2 is ON and it will pull the precharged value to zero).

The main drawback of using the 3-transistor DRAM cell is that it requires two pairs of column and rowlines. This consumes large layout area. Modern DRAM cells use only 1-transistor and 1-capacitor.

#### READ Operation

<p align="center">
<img src="https://github.com/shraddha375/sdram_controller/blob/main/images/image_7.jpg" width=50% height=50%>
</p>

#### WRITE Operation

<p align="center">
<img src="https://github.com/shraddha375/sdram_controller/blob/main/images/image_8.jpg" width=50% height=50%>
</p>

#### REFRESH Operation

<p align="center">
<img src="https://github.com/shraddha375/sdram_controller/blob/main/images/image_9.jpg" width=50% height=50%>
</p>





## References

