@def title = "Livestreaming in Javis"
@def date = Date(2021, 07, 02)

### अहम् ब्रह्मास्मि । 
######  _I am the infinite reality._
---
~~~<img src="https://developers.google.com/open-source/gsoc/resources/downloads/GSoC-logo-horizontal.svg">~~~

~~~<a href="https://github.com/Wikunia/Javis.jl/pull/337">#337</a>~~~ was born out of the desire to make viewing and sharing Javis generated animations in a much more flexible fashion. This feature brings in two new ways of sharing animations:
* Dump to a local network and viewed using any tool that can read from a network stream.
* Stream directly to platfroms like ~~~<a href="twitch.tv">twitch.tv</a>~~~ (_WIP_) 

The streaming process is handled by `ffmpeg`. 
~~~<img src="https://miro.medium.com/max/1400/1*M991891hzkJrFHyMzWrhSg.jpeg">~~~

We make use of Julia's `@async` macro to stream asynchronously to avoid holding up the julia shell.
The streaming can be terminated by using the `cancel_stream()` method.

Setting up streaming is a simple process:
* Defining the stream configuration object
```julia
# for a local stream
stream_conf = setup_stream(:local)

# for twitch stream
stream_conf = setup_stream(:twitch, <TWITCH STREAMING KEY>)
```
* passing the configuration object to the `render` function. 
```julia
# for a local stream
render(vid, streamconfig=stream_conf)
```

Local streams can be read by tools like ~~~<a href="https://obsproject.com/">OBS Studio</a>~~~, ~~~<a href="https://ffmpeg.org/ffplay.html">ffplay</a>~~~, ~~~<a href="https://www.videolan.org/">VLC</a>~~~ or any similar software.
~~~<img src="/assets/obs.png">~~~

Learn more about livestreaming in Javis ~~~<a href="https://wikunia.github.io/Javis.jl/dev/workflows/#Tools-for-Viewing-Live-Streams">here</a>~~~.
