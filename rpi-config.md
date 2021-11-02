Prior to first boot, if available, edit `/boot/config.txt` for optional [overclocking](https://magpi.raspberrypi.org/articles/how-to-overclock-raspberry-pi-4) and additional kernel modules.

```
over_voltage=2
arm_freq=1750

# Comment out default audio jack
#dtparam=audio=on
dtoverlay=hifiberry-dacplus
```
