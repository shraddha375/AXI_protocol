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

<pic>

Problems: 
- No signal to indiacte if write data valid/ read data valid (No way of knowing if the data is valid)
- Write address or Read address is valid
- Whether memory update is a success or not
- Whether memory is free or busy

To fix these issues, we introduce AXI:

<pic>

- Write Address
- Write Data
- Write Response
- Read Address
- Read Data + Response

All the above channels have handshaking mechanism between master and slave to fix the above issues.

## Valid Ready Handshake

- `**Master**`: Inititate a transaction
- `**Slave**`: Serve the request of a master

<pic>

- `Valid` and `Ready` signals are `synchronous` with respect to the clock.
- `Valid` is used to tell a slave that `master has a valid data` that it wishes to communicate to the slave.
- `Ready` is to convey that the `slave is ready to serve` the transaction.
- When `both are high`, it will mark the `start of the data transfer`.
- The `valid` signal goes from the `source to the destination`. `Ready` does from the `destination to the source`.
- The `source` uses `valid` signal to indicate when the `valid information is available`. The valid signal `must remain high(asserted)` until the destination accepts the information. `Signals` that must `remain asserted` in this way are called `sticky signals`.
- The `destination` indicates when it can `accept information` using the `Ready` signal. The ready signal goes from channel destination to channel source.
- The mechanism is `not asynchronous handshake` and it requires the rising edge of the clock for the handshake to complete.

  <pic>

The master can apply the new m_data in the next clock tick once ready and valid signals become high in the current clock tick.

Valid Ready Handshake Rules:
- Ready and Valid signals should be `independent`.
- Ready could be `asserted prior` to or after valid.
- Valid must remain high until the `completion of transfer` or until `Ready becomes high`.

<pic>
<pic>
<pic>

Flowchart for Master's and Slave's operation:

Master:

<pic>

Slave:

<pic>





