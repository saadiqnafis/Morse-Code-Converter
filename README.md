# Morse Code Converter
A converter for converting letters/words into Morse Code

### Morse Code
Morse code is a method of communication using binary signals. Typically, the “on” signal is a beep and the “off” signal is silence. There are two types of signals used to make up the alphabet: dots and dashes (also referred to as dits and dahs, respectively)

### Converter
I with my teammates Zihao Yuan and Remington Gall, built a morse code converter, a binary signal communication method where the “on” signal is a beep or LED on and the “off” signal is silence or LED off, as our Final Project in Digital Electronics. The key components of our design are an SCI receiver, a converter, a sound component, and an SCI transmitter for verification of the information received. The SCI receiver receives the SCI signal from the USB-RS232 interface and outputs the 8-bits ASCII data and a signal letting us know that the output is available. The converter takes the output of the SCI receiver as input and provides the Morse Code as the output The converter component contains a FSM and has 4 subcomponents: a Queue to store input data, a MorseROM and a LengthROM to store the Morse code data, and a convert component that provides Morse code output. The queue stores received ASCII from the receiver, and its output data is fed to MorseROM and LengthROM for obtaining the Morse code data, and to the Convert component that is a datapath to store and operate on its input data. The sound component takes the MorseOut output of the converter as input and produces the square wave (sound) signal of the Morse code as the output. Each of the 4 components passed their behavioral simulation tests and/or hardware validation tests. For SCI receiver and transmitter, the oscilloscope shows the ASCII received by the receiver is immediately outputted by the transmitter via SCI. For the converter, the oscilloscope shows correct Morse code output of MorseOut and soundOut outputs. The convert, converter, lengthROM, MorseROM, queue, and SerialRX components of our converter all passed their behavioral simulation tests. Our converter is successfully implemented: corresponding Morse codes light and sound are outputted when characters are typed on Putty, and the spacings between dots and dashes, between characters, and between words are correct.

## Getting Started

### 1. Prerequisites

- [Xilinx Vivado](https://www.xilinx.com/products/design-tools/vivado.html) 
- Compatible FPGA part (e.g., `xc7a35tcpg236-1`) — update `create_project.tcl` if using a different part

### 2. Clone the Repository

```bash
git clone https://github.com/saadiqnafis/Morse-Code-Converter.git
cd Morse-Code-Converter
```

### 3. Recreate the Vivado Project

```bash
vivado -source create_converter.tcl
```

This will:
 - Create a new Vivado project
 - Add all VHDL and constraint files
 - Set the correct part and synthesis order

### 4. Build and Simulate
Once the project is created:

1. Open the generated .xpr file in Vivado (created by the script)
2. Run synthesis and implementation as needed
3. (Optional) Add simulation sources and run behavioral/simulation tests

## Here's a demo of the converter
https://github.com/user-attachments/assets/760fba40-2075-4981-8926-7fe13720f641

