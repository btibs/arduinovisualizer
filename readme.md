## Arduino Visualizer

This project includes three files - the Arduino code, and two visualizations for the data.  The Arduino communicates over the serial port (which you may need to change for your setup), in a format like: `$A0:123,A1:456,D0:0,D1:1,` where `An` is an analog input and `Dn` is a digital input, with value after the colon.  Each line begins with a dollar sign.

**ScopeGraph** is a typical oscilloscope-style graph, where inputs are plotted as they come in, labeled on the y-axis.  For clarity, digital inputs are plotted separately from analog on the lower portion of the window.

**AbstractGraph** is a more qualitative representation of the inputs, inspired by a solar system.  Analog signals are circles rotating around the center, and have size, brightness, and speed proportional to the input value (like planets).  Digital signals are squares that are drawn to analog ones (like moons), and glow when they have a high signal.

To run this yourself, you will need an Arduino, the Arduino environment, and Processing installed. Then:

1. Download the repository
2. Upload arduinograph.ino to your Arduino
3. Open either scopegraph.pde or abstractgraph.pde in Processing
4. Change the arrays `aPinsToPlot` and `dPinsToPlot` to include the analog and digital pins you would like to see displayed, respectively.
5. Run!