## SSH
Add an empty file called "ssh" in the boot partition, to enable SSH. 

## Edit overlay trees
Prior to first boot, if available, edit `/boot/config.txt` for optional [overclocking](https://magpi.raspberrypi.org/articles/how-to-overclock-raspberry-pi-4) and additional kernel modules. [Additional information.](https://friendsoflittleyus.nl/overclocking-raspberry-pi4-on-ubuntu-20-10/)
[Other tips](https://blog.elhacker.net/2021/02/opciones-configurar-raspberry-pi-4-trucos-consejos-wifi-apagar-leds-temperaturas.html)


```
# Over-clocking
over_voltage=2
arm_freq=1750

# HiFi Berry Dac2
#dtparam=audio=on
dtoverlay=hifiberry-dacplus

# No WiFi
dtoverlay=disable-wifi # antes llamado pi3-disable-wifi 

# No Bluetooth
dtoverlay=disable-bt # antes llamado dtoverlay=pi3-disable-bt

# No blinking lights
dtoverlay=act-led

# Disable the PWR LED.
dtparam=pwr_led_trigger=none
dtparam=pwr_led_activelow=off

# Disable the ACT LED.
dtparam=act_led_trigger=none
dtparam=act_led_activelow=off

# Disable ethernet port LEDs
dtparam=eth_led0=4
dtparam=eth_led1=4
```

