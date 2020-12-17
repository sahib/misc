# Animated wallpaper

This is a small helper I used to produce a Matroska video file that is displayed
as my desktop background using [mpvpaper](https://github.com/GhostNaN/mpvpaper).

![Thumbnail of the video](/animated_wallpaper/thumbnail.gif?raw=true "Video thumbnail")

Since the video uses variable frame rate it is rather efficient to render. CPU
is only wasted during blend-over. This happens on my setup only once in a hour,
which is pretty okay.

This setup works in several steps:

1. Get a list of images you want to blend over. I recommend to look over
   [here](https://github.com/adi1090x/dynamic-wallpaper/tree/master/images) for
   some very good examples (I used the ``firewatch`` directory) & save the
   images in a directory somewhere. Optionally resize them to fit your desired
   resolution (1920x1200 for me).
2. Run the utility provided in this repository over the image in the order you
   want. The ``--blend-duration`` configures how long to blend the images over.
   The ``--key-duration`` says how long to show the last image of the blend.
   I should probably note that this might take up a lot memory, depending on
   the input resolution. It will render the intermediate frames using CPU
   and the result is written to a directory in ``/tmp/``.

```bash
$ go run main.go \
    --output /tmp/wp.mkv \
    --frames-per-second 24 \
    --blend-duration 5s \
    --key-duration 3595s \
    --input /path/to/key/frame_0.png \
    --input /path/to/key/frame_1.png \
    ...
    --input /path/to/key/frame_n.png \
```

3. Once rendered you should have a ``/tmp/wp.mkv`` file which you can verify
   with ``mpv``. You can now follow the ``mpvpaper`` docs to show it as your
   background. I call it the following way to show the correct "time" in the
   pictures based on the real time:

```bash
mpvpaper \
    --mpv-options "--loop=inf --no-audio --start=$(date +'%H:00:00')" \
    eDP-1 \
    ~/wp-23h.mkv
```

4. You probably want to hook this up somewhere in your autostart. Since I use ``sway`` I have this in my config:

```bash
# Dynamically change the wallpaper based on the day hour:
exec_always ~/wallday/wallday.sh
```

That's it. Your mileage may vary.

# Alternatives

## Use ``ffmpeg`` directly to interpolate

* http://ffmpeg.org/ffmpeg-filters.html#minterpolate
* https://github.com/dthpham/butterflow

I'm not sure how easy it is to achieve a variable framerate with those though.
With the above solutions I had good control over the quality. Also I had
something to play around with on a winter day.
