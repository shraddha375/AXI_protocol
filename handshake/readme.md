# Handshake Mechanism between a Master and Slave

**Master**: Initiates a transaction

**Slave**: Serves the request of a master

<p align="center">
 <img src="https://github.com/shraddha375/AXI_protocol/blob/main/images/image1.jpg" width=50% height=50%>
</p>

---

<p align="center">
 <img src="https://github.com/shraddha375/AXI_protocol/blob/main/images/image2.jpg" width=50% height=50%>
</p>

- **Valid** and **Ready** signals are synchronous with respect to the **clock**.
- **Valid** is used to tell a slave that master has a valid data that it wishes to communicate to a slave.
- **Ready** is to convey that the slave is ready to serve the transaction.
- When both are **high**, it will mark the start of the data transfer.
- The valid signal goes from **source to destination**. Ready goes from **destination to source**.
- The source uses valid signal to indicate when the valid information is available. The valid signal must remain high (asserted) until the destination accepts the information. Signals that must remain asserted in this way are called **sticky signals**.
- The destination indicates when it can accept information using the Ready signal. The ready signal goes from the channel destination to channel source.
- This mechanism is not asynchronous handshake and it requires the rising edge of the clock for the handshake to complete.
- The masters can apply the new m_data in the next clock tick once ready and valid signals become high in the current clock tick.

Rules:
- Ready and Valid should be independent.
- Ready could be asserted prior to or after valid.
- Valid must remain high until completion of transfer or until Ready becomes high.

## Ready after Valid

<p align="center">
 <img src="https://github.com/shraddha375/AXI_protocol/blob/main/images/image3.jpg" width=50% height=50%>
</p>

## Ready before Valid

<p align="center">
 <img src="https://github.com/shraddha375/AXI_protocol/blob/main/images/image4.jpg" width=50% height=50%>
</p>

## Ready and Valid at the same time

<p align="center">
 <img src="https://github.com/shraddha375/AXI_protocol/blob/main/images/image5.jpg" width=50% height=50%>
</p>

## Flowcharts for Master and Slave

### For Master

### For Slave
