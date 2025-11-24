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







