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

## Ready after Valid

<p align="center">
 <img src="https://github.com/shraddha375/AXI_protocol/blob/main/images/image3.jpg" width=50% height=50%>
</p>

## Ready before Valid

<p align="center">
 <img src="https://github.com/shraddha375/AXI_protocol/blob/main/images/image4.jpg" width=50% height=50%>
</p>

# Ready and Valid at the same time

<p align="center">
 <img src="https://github.com/shraddha375/AXI_protocol/blob/main/images/image5.jpg" width=50% height=50%>
</p>
