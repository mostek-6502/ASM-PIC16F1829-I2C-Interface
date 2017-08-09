# PIC16F1829-Assembly
This Assembly code was written for a Microchip PIC16F1829 processor.

This code utilized the I2C protocol to talk to multiple Dallas Semiconductor DS2482-800's with the down stream I2C communication to DS18B20's.

For my purposes, I used one DS2482-800 Channel per DS18B20 probe even though the 1-Wire protocol allows multiple probes to hang off the same channel.

Assembly code for even a tiny processor can be very 'performant' and I 'think' I remember getting new temperature readings (16 total) every 200ms.

The probes themselves were set to return at 75ms and rounded to .0(C) or .5(C). (9 bit resolution)

The rest to the 125ms was spent formtting the output and sending the data through the serial port.

I did add a bit of CRC checking before sending the data out.

The Delay's for this version of the code were 'older'.

I eventually wrote a C++ app that would calculate a desired delay based on clock speed and clock ticks per instruction. In this case the instructions were NOPs, Calls, Returns, Jumps, Decs, MOVF etc.

Of course, if your clock crystal was not precise, the delay would reflect the imprecision.

All of this to say that the MPU had no understanding of 'time',

At the end of the run, the C++ App would output the actual PIC assembly code needed for that delay.

Generally, specific delays on the older PIC's had to be hand calculated and were painful to get right. I 'brute forced' it and cycled through every possibility. (It only took a few seconds to calculate.)

If you want that code, ask and I will try to find it.

http://www.microchip.com/wwwproducts/en/PIC16F1829 
https://datasheets.maximintegrated.com/en/ds/DS2482-800.pdf 
https://datasheets.maximintegrated.com/en/ds/DS18B20.pdf
