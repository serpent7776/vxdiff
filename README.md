# vxdiff

[odiff](https://github.com/dmtrKovalenko/odiff/) compatible pixel-by-pixel image visual difference tool.

The comparison algorithm written entirely in AVX512 assembly.

Currently supports only PNG images, but that's not any inherent limitations.

## Performance

Very large image file:

```
  ./vxdiff ../test-images/funocaml.png ../test-images/funocaml2.png ran
    1.04 ± 0.04 times faster than ./odiff ../test-images/funocaml.png ../test-images/funocaml2.png
```

Very small image file:

```
  ./vxdiff /tmp/foo.png /tmp/foo2.png ran
   15.10 ± 29.81 times faster than ./odiff /tmp/foo.png /tmp/foo2.png
```

Image with alpha:

```
  ./vxdiff ../test-images/extreme-alpha.png ../test-images/extreme-alpha-1.png ran
    2.48 ± 0.37 times faster than ./odiff ../test-images/extreme-alpha.png ../test-images/extreme-alpha-1.png
```
