# Welcome to Glitch Draw

This is a fun little side project I worked on for [Webflow](www.webflow.com)'s office. It's a series of six touch-sensitive LED panels connected to a Raspberry Pi. The Pi drives a small LCD panel with Photoshop-like functionality, enabling you to create all manner of interesting drawings with your finger. Think of it as a finger-painting lite brite™!  There's a catch, though. If you stop working on your drawing, a countdown start in that will eventually _glitch_ your image and will continue to do so until your image is gone forever. It's a fight against entropy, folks, so keep drawing!

![Here's the lovely Stacy using it!](https://dl.dropboxusercontent.com/s/dy2n2b3r6oxnjqt/glitchdraw_usage.gif)

![GlitchDraw sitting on the wall](https://dl.dropboxusercontent.com/s/soxu6gudgcme51e/glitchdraw_front.png)

![GlitchDraw in action](https://dl.dropboxusercontent.com/s/xyg3wlaeenvdenk/glitchdraw_draw.png?dl=1)

![GlitchDraw UI (written in Qt)](https://dl.dropboxusercontent.com/s/i9k0y0s8u2zsc1k/glitchdraw_ui.png?dl=1)

##### Watch a video of it in action

[![Watch the video](https://dl.dropboxusercontent.com/s/5c5mpog47o13obg/glitchdraw_video_preview.png?dl=1)](https://youtu.be/vt5fpE0bzSY)

##### Qt + Smart LED Matrix + Raspberry Pi + IR Touch Bezel = FUN

![Glitch Draw Background with Components](https://dl.dropboxusercontent.com/s/oyqjbf3hm8kau13/glitchdraw_back.jpg?dl=1)

**Parts:**

- [6x Smart LED Matrix](https://www.adafruit.com/product/1484)
- [Rasperry Pi 4](https://www.adafruit.com/product/4295)
- [GPIO breakout board](https://github.com/hzeller/rpi-rgb-led-matrix/tree/master/adapter)
- [Step-up Voltage Converter](https://www.amazon.com/gp/product/B07GJDNKG9/ref=ppx_yo_dt_b_search_asin_title?ie=UTF8&psc=1)
- 3D Printed Frame
- [IR Touch Panel](https://www.amazon.com/gp/product/B07CWL55CK/ref=ppx_yo_dt_b_search_asin_title?ie=UTF8&psc=1)

**Software:**

- [Raspbian Buster + experimental GBM Drivers (No X Server required)](https://www.raspberrypi.org/downloads/)
- [Qt (5.12) and Qt Creator](https://www.qt.io/)
- [RGB LED Matrix Library](https://github.com/hzeller/rpi-rgb-led-matrix)

### How to run

I cross-compiled Qt for Buster in Ubuntu and developed it on a separate machine from my Raspberry Pi. This was difficult. I'm happy to explain how, and will do so if there's enough interest in this project. Otherwise, you can compile this _on_ your Raspberry Pi, but expect it to take awhile. Open up the project in Qt Creator and compile away!
