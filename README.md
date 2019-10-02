# Welcome to Glitch Draw

This is a fun little side project I worked on for [Webflow](www.webflow.com)'s office. It's a series of six touch-sensitive LED panels connected to a Raspberry Pi. The Pi drives a small LCD panel with Photoshop-like functionality, enabling you to create all manner of interesting drawings with your finger. Think of it as a finger-painting lite brite™!  There's a catch, though. If you stop working on your drawing, a countdown kicks in that will eventually _glitch_ your image and will continue to do so until your image is gone forever. It's a fight against entropy, folks!

![GlitchDraw sitting on the wall](https://www.dropbox.com/s/soxu6gudgcme51e/glitchdraw_front.png?dl=1)

![GlitchDraw in action](https://www.dropbox.com/s/xyg3wlaeenvdenk/glitchdraw_draw.png?dl=1)

![GlitchDraw UI (written in Qt)](https://www.dropbox.com/s/i9k0y0s8u2zsc1k/glitchdraw_ui.png?dl=1)

Here's [a video](https://vimeo.com/363608705) of it in action.

##### Qt + Smart LED Matrix + Raspberry Pi + IR Touch Bezel = FUN

![Glitch Draw Background with Components](https://www.dropbox.com/s/oyqjbf3hm8kau13/glitchdraw_back.jpg?dl=1)

Parts:

- 6x Smart LED Matrix
- Rasperry Pi 4
- GPIO splitter board
- Voltage Amplifier
- 3D Printed Frame
- IR Touch Bezel

Software:

- Raspbian Buster + experimental GBM Drivers (No X Server required)
- Qt (5.12) and Qt Creator
- Smart Matrix LED Library

### How to run

I cross-compiled Qt for Buster in Ubuntu and developed it on a separate machine from my Raspberry Pi. This was difficult. I'm happy to explain how, and will do so if there's enough interest in this project. Otherwise, you can compile this _on_ your Raspberry Pi, but expect it to take awhile. Open up the project in Qt Creator and compile away!
