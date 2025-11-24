# AXI Interface

## Types of AXI Interface

- AXI Stream
- AXI Lite
- AXI Full

![Untitled](https://github.com/user-attachments/assets/939f9c27-e744-486b-b0e1-a997761d36d0)

<img width="834" height="769" alt="image" src="https://github.com/user-attachments/assets/60ac7ca7-8885-4733-921a-301d1b4827b8" />



| AXI Stream                                  | AXI Lite                                  | AXI Full                                                                             |
|---------------------------------------------|-------------------------------------------|--------------------------------------------------------------------------------------|
| `No address`, purely data transfer          | `Single address` per transaction          | `Multiple address` supported in a burst mode                                         |
| `No burst support`, single data transfers   | `No burst support`, single data transfers | `Supports burst` transactions                                                        |
| `Simple handshaking`                        | `Simple handshaking`                      | `Complex handshaking` with multiple signals and support for out of order transctions |
| `Low Complexity`                            | `Low Complexity`                          | `Higher Complexity`                                                                  |
| `High speed, high throughput` data transfer | `Simple register access`                  | `High performance`, supports `bursts`, multiple outstanding transctions              |

