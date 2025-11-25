# AXI Interface

## Types of AXI Interface

- AXI Stream
  
  ![Untitled](https://github.com/user-attachments/assets/bd5bcfba-7f69-466d-a433-284ee3d83f95)
  
- AXI Lite
  
  ![Untitled](https://github.com/user-attachments/assets/8c9cb3e6-6f68-4f52-81ee-47bcbd8ff136)
  
- AXI Full
  
  ![Untitled-1](https://github.com/user-attachments/assets/7fb2c1e9-7996-4228-a5aa-0e711113293b)
  

![Untitled](https://github.com/user-attachments/assets/939f9c27-e744-486b-b0e1-a997761d36d0)


| AXI Stream                                  | AXI Lite                                  | AXI Full                                                                             |
|---------------------------------------------|-------------------------------------------|--------------------------------------------------------------------------------------|
| `No address`, purely data transfer          | `Single address` per transaction          | `Multiple address` supported in a burst mode                                         |
| `No burst support`, single data transfers   | `No burst support`, single data transfers | `Supports burst` transactions                                                        |
| `Simple handshaking`                        | `Simple handshaking`                      | `Complex handshaking` with multiple signals and support for out of order transctions |
| `Low Complexity`                            | `Low Complexity`                          | `Higher Complexity`                                                                  |
| `High speed, high throughput` data transfer | `Simple register access`                  | `High performance`, supports `bursts`, multiple outstanding transctions              |

In a simple memory,

![Untitled](https://github.com/user-attachments/assets/6bb01c2c-04f1-40f1-a270-e73b7dc37b8c)

Problems: 
- No signal to indiacte if write data valid/ read data valid (No way of knowing if the data is valid)
- Write address or Read address is valid
- Whether memory update is a success or not
- Whether memory is free or busy

To fix these issues, we introduce AXI:

![Untitled](https://github.com/user-attachments/assets/79a3e185-4640-42f8-863d-c0dbf80521ad)

1. Write Address
2. Write Data
3. Write Response
4. Read Address
5. Read Data + Response

All the above channels have handshaking mechanism between master and slave to fix the above issues.

## Valid Ready Handshake

- `Master`: Inititate a transaction
- `Slave`: Serve the request of a master

<p align="center">
 <img src="https://github.com/shraddha375/AXI_protocol/blob/main/images/image1.jpg" width=50% height=50%>
</p>

- `Valid` and `Ready` signals are `synchronous` with respect to the clock.
- `Valid` is used to tell a slave that `master has a valid data` that it wishes to communicate to the slave.
- `Ready` is to convey that the `slave is ready to serve` the transaction.
- When `both are high`, it will mark the `start of the data transfer`.
- The `valid` signal goes from the `source to the destination`. `Ready` does from the `destination to the source`.
- The `source` uses `valid` signal to indicate when the `valid information is available`. The valid signal `must remain high(asserted)` until the destination accepts the information. `Signals` that must `remain asserted` in this way are called `sticky signals`.
- The `destination` indicates when it can `accept information` using the `Ready` signal. The ready signal goes from channel destination to channel source.
- The mechanism is `not asynchronous handshake` and it requires the rising edge of the clock for the handshake to complete.

<p align="center">
 <img src="https://github.com/shraddha375/AXI_protocol/blob/main/images/image2.jpg" width=50% height=50%>
</p>

The master can apply the new m_data in the next clock tick once ready and valid signals become high in the current clock tick.

Valid Ready Handshake Rules:
- Ready and Valid signals should be `independent`.
- Ready could be `asserted prior` to or after valid.
- Valid must remain high until the `completion of transfer` or until `Ready becomes high`.

### Ready after Valid

<p align="center">
 <img src="https://github.com/shraddha375/AXI_protocol/blob/main/images/image3.jpg" width=50% height=50%>
</p>

### Ready before Valid

<p align="center">
 <img src="https://github.com/shraddha375/AXI_protocol/blob/main/images/image4.jpg" width=50% height=50%>
</p>

### Ready and Valid at the same time

<p align="center">
 <img src="https://github.com/shraddha375/AXI_protocol/blob/main/images/image5.jpg" width=50% height=50%>
</p>

### Flowchart for Master's and Slave's operation:

#### For Master

<p align="center">
 <img src="https://github.com/shraddha375/AXI_protocol/blob/main/images/image6.jpg" width=50% height=50%>
</p>

#### For Slave

<p align="center">
 <img src="https://github.com/shraddha375/AXI_protocol/blob/main/images/image7.jpg" width=50% height=50%>
</p>

## AXI Stream

An AXI Full looks something like this:

<img width="499" height="517" alt="Intro_to_AXI_AXI_channels" src="https://github.com/user-attachments/assets/cd506a57-c2e7-4b26-b222-6bbbc1b62f0d" />
![axi4_channel](https://github.com/user-attachments/assets/53b10242-d63c-4cab-a1cb-eac3a83af900)

For applications where there is point to point communication (usually in one direction), some of the signals can be dropped (e.g one doesnt need address). So the structure simplifies to:

![Untitled](https://github.com/user-attachments/assets/353ae789-2576-443b-82c3-5193d19bb353)

Applications include:

<img width="723" height="563" alt="Untitled Diagram" src="https://github.com/user-attachments/assets/2ec616f6-9d08-4bb9-a30a-7af89ffc0dd7" />

### AXI Stream Signals

<img width="536" height="417" alt="image" src="https://github.com/user-attachments/assets/701e49b9-854c-4bc5-a60f-d398fc9eadb0" />

<img width="518" height="269" alt="image" src="https://github.com/user-attachments/assets/c4c3cae0-e815-4913-b3ea-ec17cb69a776" />

<img width="547" height="229" alt="image" src="https://github.com/user-attachments/assets/24513190-a3c9-485d-9207-4cd2a9376fb0" />

### TKEEP and TSTRB

The two byte qualifiers supported by the AXI-Stream protocol:
- `TKEEP`: A byte qualifier signal used to indicate whether the content of the associated byte must be transported to the destination.
- `TSTRB`: A byte qualifier signal used to indicate whether the content of the associated byte is a data byte or a position byte.

Each bit of the TKEEP and TSTRB is associated with a byte of payload:
• TKEEP[x] is associated with TDATA[(8x+7):8x]
• TSTRB[x] is associated with TDATA[(8x+7):8x]

![Untitled](https://github.com/user-attachments/assets/06582bf0-3aae-41fd-aa46-a8af473c70f4)


#### TKEEP Qualification

- When TKEEP is asserted, it indicates that the associated byte must be transmitted to the destination.
- When TKEEP is deasserted, it indicates a null byte that can be removed from the stream. A transfer is permitted with all TKEEP bits deasserted.

#### TSTRB Qualification

- TKEEP is asserted, TSTRB is used to indicate whether the associated byte is a data byte or a position byte.
- TSTRB is asserted, it indicates that the associated byte contains valid information and is a data byte. When TSTRB is deasserted, it indicates that the associated byte does not contain valid information and is a position byte.

Position byte is used to indicate the correct relative position of the data bytes within the stream. Position bytes are typically used when the data stream is performing a partial update of information at the destination.

<img width="990" height="367" alt="image" src="https://github.com/user-attachments/assets/e292c320-2aba-4a3f-a58a-c759cbd1e23b" />


## References


- https://www.allaboutcircuits.com/technical-articles/introduction-to-the-advanced-extensible-interface-axi/
- https://fpgaemu.readthedocs.io/en/latest/axi.html
