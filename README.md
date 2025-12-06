# AXI Interface

## What is AMBA Protocols

The Arm Advanced Microcontroller Bus Architecture, is an open-standard, on-chip interconnect specification that define how functional blocks in an SoC design communicate with each other.
The diagram below illustrates a typical SoC design, where multiple functional blocks rely on AMBA protocols such as AXI4 and AXI3 to communicate with one another:

<img width="748" height="643" alt="image" src="https://github.com/user-attachments/assets/a7c7b462-a582-46c0-8542-cb3e2055d244" />

AMBA makes it easier to design systems that include several processors along with many controllers and peripherals. 

## AXI Protocol
AXI is an interface specification that defines the interface of IP blocks.
All AXI connections are between master interfaces and slave interfaces.

The diagram below presents a simplified view of an SoC system, consisting of master components, slave components, and the interconnect that ties them together:

<img width="676" height="349" alt="image" src="https://github.com/user-attachments/assets/50890792-406c-455f-a96f-bb1bbeccca88" />

Where multiple masters and slaves are involved, an interconnect fabric is required.

## Types of AXI Interface

- AXI Stream
  
<p align="center">
 <img src="https://github.com/user-attachments/assets/bd5bcfba-7f69-466d-a433-284ee3d83f95" width=50% height=50%>
</p>
  
- AXI Lite

<p align="center">
 <img src="https://github.com/user-attachments/assets/8c9cb3e6-6f68-4f52-81ee-47bcbd8ff136" width=50% height=50%>
</p>
  
- AXI Full

<p align="center">
 <img src="https://github.com/user-attachments/assets/7fb2c1e9-7996-4228-a5aa-0e711113293b" width=50% height=50%>
</p>  

![Untitled](https://github.com/user-attachments/assets/939f9c27-e744-486b-b0e1-a997761d36d0)


| AXI Stream                                  | AXI Lite                                  | AXI Full                                                                             |
|---------------------------------------------|-------------------------------------------|--------------------------------------------------------------------------------------|
| `No address`, purely data transfer          | `Single address` per transaction          | `Multiple address` supported in a burst mode                                         |
| `No burst support`, single data transfers   | `No burst support`, single data transfers | `Supports burst` transactions                                                        |
| `Simple handshaking`                        | `Simple handshaking`                      | `Complex handshaking` with multiple signals and support for out of order transctions |
| `Low Complexity`                            | `Low Complexity`                          | `Higher Complexity`                                                                  |
| `High speed, high throughput` data transfer | `Simple register access`                  | `High performance`, supports `bursts`, multiple outstanding transctions              |

In a simple memory,

<p align="center">
 <img src="https://github.com/user-attachments/assets/6bb01c2c-04f1-40f1-a270-e73b7dc37b8c" width=50% height=50%>
</p>

Problems: 
- No signal to indiacte if write data valid/ read data valid (No way of knowing if the data is valid)
- Write address or Read address is valid
- Whether memory update is a success or not
- Whether memory is free or busy

To fix these issues, we introduce AXI:

<p align="center">
 <img src="https://github.com/user-attachments/assets/79a3e185-4640-42f8-863d-c0dbf80521ad" width=50% height=50%>
</p>

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

<p align="center">
<img width="499" height="517" alt="Intro_to_AXI_AXI_channels" src="https://github.com/user-attachments/assets/cd506a57-c2e7-4b26-b222-6bbbc1b62f0d" />
</p>

<p align="center">
<img src="https://github.com/user-attachments/assets/53b10242-d63c-4cab-a1cb-eac3a83af900" width=50% height=50%>
</p>

For applications where there is point to point communication (usually in one direction), some of the signals can be dropped (e.g one doesnt need address). So the structure simplifies to:

<p align="center">
<img src="https://github.com/user-attachments/assets/353ae789-2576-443b-82c3-5193d19bb353" width=50% height=50%>
</p>

Applications include:

<img width="361" height="281" alt="Untitled Diagram" src="https://github.com/user-attachments/assets/2ec616f6-9d08-4bb9-a30a-7af89ffc0dd7" />

<p align="center">
  <img src="https://github.com/user-attachments/assets/707e84af-1f9d-432f-b49c-e2dfa9b105bb" width=50% height=50%>
</p>

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

### Custom AXI Interface

AXI Interface can be made form:
- Peripheral RTL from Scratch: More control over latency and strict timing requirements
- Vivado Verilog Template
- Vivado HLS: Specify an interface and HLS will automatically generate an interface; Less control over latency

### AXIS Module

Rules to recap:

1. We neednot wait for the tready signal before applying the tvalid signal.
2. As long as tready is high, you can apply new data but as soon as it is low, you need to hold tvalid and tdata (tlast as well if applicable) values until tready is high again.

##### Scenario 1:

<p align="center">
  <img src="https://github.com/user-attachments/assets/74082304-0174-4668-8a29-eef883566618" width=50% height=50%>
</p>

##### Scenario 2:

<p align="center">
  <img src="https://github.com/user-attachments/assets/9a130909-b883-4159-837e-24d1066f53cc" width=50% height=50%>
</p>


##### Scenario 3:

<p align="center">
  <img src="https://github.com/user-attachments/assets/48f3e445-aa4d-4bae-92c9-1015a998af3c" width=50% height=50%>
</p>

#### AXIS Master

<p align="center">
  <img src="https://github.com/user-attachments/assets/a90dc8f2-dcc7-4a38-b431-3c6100ac7edd" width=50% height=50%>
</p>

<p align="center">
  <img src="https://github.com/user-attachments/assets/b6c172ff-9ce3-44d7-a677-2ea55b28843f" width=50% height=50%>
</p>

<p align="center">
  <img src="https://github.com/user-attachments/assets/b27da4b0-348f-4e79-9603-38628e1b72aa" width=50% height=50%>
</p>

<img width="1893" height="400" alt="image" src="https://github.com/user-attachments/assets/0061a187-527f-4b53-8e4b-3ca4bddc243a" />

#### AXIS Slave

<p align="center">
  <img src="https://github.com/user-attachments/assets/0dce7491-abde-4e59-af9f-de7a78a1e9b0" width=50% height=50%>
</p>

<p align="center">
  <img src="https://github.com/user-attachments/assets/71f7bc48-560a-4f6c-bf9b-2d199cf0fd83" width=50% height=50%>
</p>

<p align="center">
  <img src="https://github.com/user-attachments/assets/75100ff6-29d6-4f2c-9dd8-4bb1c534f450" width=50% height=50%>
</p>

<img width="1909" height="316" alt="image" src="https://github.com/user-attachments/assets/f18d6073-6cbb-40de-9aac-2e82ff3cf63d" />


#### AXIS Module

<p align="center">
  <img src="https://github.com/user-attachments/assets/bfca3424-5cad-4080-92d5-ea8b841e23cc" width=50% height=50%>
</p>

<img width="1900" height="607" alt="image" src="https://github.com/user-attachments/assets/915c1107-b026-4bde-956b-1b9694d5dfe4" />


### AXIS Arbiter

Round Robin Arbiter
- Priority is set for one of the requests
- Equally serve all the requests (Number of requests considered = 2)

<p align="center">
  <img src="https://github.com/user-attachments/assets/b7aad7c8-da8a-4817-9167-32b286a87cbf" width=50% height=50%>
</p>

<p align="center">
  <img src="https://github.com/user-attachments/assets/690516b0-419a-4202-a151-fa69965f6955" width=50% height=50%>
</p>

<p align="center">
  <img src="https://github.com/user-attachments/assets/a80d0ec4-571f-449f-911e-58d69f1b8626" width=50% height=50%>
</p>

<p align="center">
  <img src="https://github.com/user-attachments/assets/fd9d1c75-c462-4feb-842e-4c174bf39810" width=50% height=50%>
</p>


#### Implementation of AXIS Arbiter

Arbiter is needed when you have more than one masters/slaves.

<p align="center">
  <img src="https://github.com/user-attachments/assets/88dcdb46-c6a4-4ffc-b6f3-ed88f802971b" width=50% height=50%>
</p>

<p align="center">
  <img src="https://github.com/user-attachments/assets/af3c08e0-79bc-4f83-9149-25f30f920843" width=50% height=50%>
</p>

<img width="1897" height="586" alt="image" src="https://github.com/user-attachments/assets/dd8c0053-c4a4-4b0f-a5a3-253573fcf9b9" />

### AXIS FIFO

This components accepts several requests from the master and stores in the FIFO. 

<p align="center">
 <img src="https://github.com/shraddha375/AXI_protocol/blob/main/images/image9.jpg" width=50% height=50%>
</p>

<p align="center">
 <img src="https://github.com/shraddha375/AXI_protocol/blob/main/images/image8.jpg" width=50% height=50%>
</p>

<img width="1900" height="523" alt="image" src="https://github.com/user-attachments/assets/30b0b6d1-8c17-4167-840d-d0bd4df2330e" />

## AXI Lite

<p align="center">
 <img src="https://github.com/user-attachments/assets/76706a10-b12e-43e2-bc71-7031890bc3b8" width=50% height=50%>
</p>

<p align="center">
 <img src="https://github.com/user-attachments/assets/eb1fc21e-6eaf-4fae-ba28-e4c09c4975c4" width=50% height=50%>
</p>

A `beat` is an individual data transfer within the AXI burst. Here we assume beat size of 8 bits/byte.

<img width="840" height="591" alt="AXI_read_transaction svg" src="https://github.com/user-attachments/assets/8b90c86a-d6e6-46b4-b077-0fedf871bae6" />

### Write Address Channel

<p align="center">
 <img src="https://github.com/user-attachments/assets/7420a742-113e-4b28-820e-cfa7e4aabea8" width=50% height=50%>
</p>

- `awready` and `awvalid` are for handshake mechanism
- `awaddr`: Indicates starting address of the transfer

<p align="center">
 <img src="https://github.com/user-attachments/assets/e63f8c28-1ef4-4834-a4dc-d53c7cbd00a5" width=50% height=50%>
</p>

- `awsize`: Size of each beat

<p align="center">
 <img src="https://github.com/user-attachments/assets/d393a7f0-ff89-454a-8849-3552c0ceae13" width=50% height=50%>
</p>

- `awburst`: Indicates type of burst (INCR, FIXED, WRAP)
- `awlen`: Number of beats in a transfer; burst lenght = awlen + 1
- `awid`: Unique ID of a transaction

<img width="1000" height="726" alt="image" src="https://github.com/user-attachments/assets/8edf451c-ca98-47b4-939e-c4e7dadfa711" />

<img width="948" height="423" alt="image" src="https://github.com/user-attachments/assets/2b4a47c3-bb70-4c42-8ba3-1038f9951bf9" />


### Channel ID

![Untitled](https://github.com/user-attachments/assets/b58a146d-95f0-4352-bb66-4b080d2050ac)

Master will wait till it receives the response of the current transaction before applying the address of the second transaction.

![Untitled](https://github.com/user-attachments/assets/d7f07591-0ffb-4fd3-961c-1800ff163a05)

Master will not wait before applying for a new transaction.

To distinguish between reponses from different transactions, we can use id for different transactions.

![Untitled](https://github.com/user-attachments/assets/c281652c-d8d3-41b6-ae03-d16c4b7b286e)

### Write Data Channel

![Untitled](https://github.com/user-attachments/assets/09677e92-c4fa-496b-bc41-3c8803a48409)

![Untitled](https://github.com/user-attachments/assets/1dd9720b-2ec3-4700-813c-2cb8b662ae9b)

-`wstrb`: Indicates which byte to be ignored by the slave

![Untitled](https://github.com/user-attachments/assets/60805882-5d58-4efa-870b-8d8f36fdffda)

<img width="994" height="562" alt="image" src="https://github.com/user-attachments/assets/9e634d64-4e23-4ecb-b6b6-0eb86651e022" />


### Write Response Channel

![Untitled-1](https://github.com/user-attachments/assets/262b2ee4-629e-4987-8b0e-eebf78add8b5)

![Untitled](https://github.com/user-attachments/assets/3a35e49b-55bc-46bb-8da0-bb0a9d78ebb9)

- `bid` = `awid` but `bid` may or may not be equal to `wid`
- `bresp`: Indicates successful read or write operation

Types of Responses:

![Untitled-1](https://github.com/user-attachments/assets/18941e49-77d8-4224-a2d5-7861b3e1ecfe)

![Untitled-1](https://github.com/user-attachments/assets/1e0e4200-b6bd-4f49-9e13-c4291d3dc1e9)

- `awlock`: to get exclusive access to certain variable when multiple masters are trying to access a shared variable. `awlock` = 2'b10 means only one master can access; `awlock` = 2'b11 locks the shared resources for multiple transactions

<img width="1008" height="451" alt="image" src="https://github.com/user-attachments/assets/dcc00c51-5b6f-470d-a2ee-890564ae5221" />

### Read Address Channel

<img width="984" height="751" alt="image" src="https://github.com/user-attachments/assets/fac77142-8b36-46dc-a1c6-eb70dad97e58" />

<img width="985" height="321" alt="image" src="https://github.com/user-attachments/assets/7eb8c4fa-160c-4193-93ee-0d65aa3e546a" />

### Read Data Channel

<img width="1027" height="562" alt="image" src="https://github.com/user-attachments/assets/f93b50af-05d0-486b-8f09-77a2eb9f43d3" />

### Different AXI Configurations

![Untitled](https://github.com/user-attachments/assets/c6562872-58a4-4e49-865b-6dde562f6b81)

- Single beat without pipeline - E.g. GPIO/UARt
- Single beat with pipeline - E.g. DSP/ Network S/W
- Burst without pipeline - E.g. Image Sensors/ Display buffers
- Burst with pipeline - E.g. GPU/ Data Centers/ Servers/ Smartphones/ Gaming Consoles

#### Single beat without pipeline

![Untitled](https://github.com/user-attachments/assets/d827917e-371b-4f22-97a3-155eca3b2922)

Wait for response of the current transaction before applying the address of the next transaction.

#### Single beat with pipeline

![Untitled](https://github.com/user-attachments/assets/e9f81c9f-0d3c-4b33-9b4c-88601f64fb82)

Burst - Multiple beats

### Waveform based Simulation

Look at the waveform, then predict the behavior of the output port in terms of input ports.

<p align="center">
  <img src="https://github.com/user-attachments/assets/c07c75d4-704a-47ee-b77e-400e46343435" width=50% height=50%>
</p>


    initial m_axi_awaddr = 0;

    always @(posedge m_axi_aclk) begin
        if (m_axi_aresetn == 1'b0)
            m_axi_awaddr <= 0;
        else if (i_wr)
            m_axi_awaddr <= i_addrin;
        else if (m_axi_awvalid && m_axi_awready)
            m_axi_awaddr <= 0;
    end

### FSM based Simulation

Design is based on FSM.

    detect_op: begin
        if (wr)
            state <= send_waddr;
        else
            state <= send_raddr;
    end

    send_waddr: begin
        din <= wr_din * 5;
        m_axi_awaddr <= wr_addr;
        m_axi_awvalid <= 1;
        m_axi_wvalid <= 1;
        m_axi_awlen <= wr_burst_len;
        m_axi_awsize <= 3'b010;
        m_axi_awburst <= wr_burst_type;
        m_axi_wdata <= wr_din;
        m_axi_wstrb <= wr_strbin << 1;
        m_axi_wlast <= 0;
        burst_count <= wr_burst_len;
        m_axi_bready <= 1;

        if (m_axi_awready == 1) begin
            state <= send_value;

### AXI Lite Module

#### Write Section


<p align="center">
  <img src="https://github.com/user-attachments/assets/c07c75d4-704a-47ee-b77e-400e46343435" width=50% height=50%>
</p>

<p align="center">
  <img src="https://github.com/user-attachments/assets/5664b40a-ee77-4629-875f-021f3d6b1cc4" width=50% height=50%>
</p>


#### Read Section


The implementation is about a single beat transaction without pipelining.


## References

- Udemy
- https://www.allaboutcircuits.com/technical-articles/introduction-to-the-advanced-extensible-interface-axi/
- https://fpgaemu.readthedocs.io/en/latest/axi.html
