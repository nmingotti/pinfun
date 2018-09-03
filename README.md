# pinfun
Prints out all pin configurations in a BeagleBone Black; works in FreeBSD
# Author: Dr. Nicola Mingotti.
# License: The one used in FreeBSD. 
# Thanks: 

# -------- USAGE ---------------
# #> ruby pinfun.rb 

# ------ WHAT DOES IT DO -------- 
# -] Simple script that print in output a table as: 
# -------------------------------------------------------------------
# POS      NAME           Mode  Function             Setup  
# -------------------------------------------------------------------
# ....
# P.9.19   I2C2_SCL        3    I2C2_SCL                    
# P.9.20   I2C2_SDA        3    I2C2_SDA                    
# P.9.21   UART2_TXD       3    ehrpwm0B                    
# P.9.22   UART2_RXD       3    ehrpwm0A                    
# P.9.23   GPIO1_17        7    gpio1[17]            <IN,PD>
# P.9.24   UART1_TXD       7    gpio0[15]            <IN,PU>
# P.9.25   GPIO3_21        0    mcasp0_ahclkx               
# ... 
# -] The script takes informations from "ofwdump", "gpioctl"
#    and uses the data table "data_H9" wich was converted from 
#    an Excel table found in this page: 
#    http://www.embedded-things.com/bbb/beaglebone-black-pin-mux-spreadsheet/

# ---- TODO -----
# -] Clean all, it is a big mess now. => make an object "Multiplexor"
#    to contains what are now global variables.
# -] Rewrite parsing data from "sysctl -b hw.fdt.dtb | dtc -I dtb -O dts"
#    instead of using "ofwdump -a -p", parsing will be easier. 
#    (suggested by John-Mark Gurney)
# -] Add header P.8, now it works only for header P.9.
# -] Eventually rewrite in C
# -] The double nature of pins P.9.41 and P.9.42 is fully ignored 
# -] Add more comment
# -] Convert comment from Italian to English

# --- "X" output in Mode ---- 
# When you see and "X" in colum "Mode" it means that the script 
# was not able to determine the current configuration of the pin.
# This implies that the pin actually has a configuration, but the 
# OS is not aware of what it is => You can not use it from the OS
# untill you configure the pin. (tentative explanation)

