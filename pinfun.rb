#!/usr/local/bin/ruby

# *** UNDER DEVELOPEMENT ***

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
# -] Eventually rewrite in C
# -] The double nature of pins P.9.41 and P.9.42 is fully ignored 
# -] Add more comment
# -] Convert comment from Italian to English

# --- "-" output in Mode ---- 
# When you see and "-" in colum "Mode" it means that the script 
# was not able to determine the current configuration of the pin.
# This implies that the pin actually has a configuration, but the 
# OS is not aware of what it is => You can not use it from the OS
# untill you configure the pin. (tentative explanation)
# 
# ---- CHANGELOG --- 
# 04-sep-2018: Added support for header P8.
#


# require 'pry'

# ---------------------------------------------------------------------
# Data 
# ---------------------------------------------------------------------
# pin;name;offset;0;1;2;3;4;5;6;7;;
data_H9 = %q{1;GND;;;;;;;;;;;
2;GND;;;;;;;;;;;
3;DC_3.3V;;;;;;;;;;;
4;DC_3.3V;;;;;;;;;;;
5;VDD_5V;;;;;;;;;;;
6;VDD_5V;;;;;;;;;;;
7;SYS_5V;;;;;;;;;;;
8;SYS_5V;;;;;;;;;;;
9;PWR_BUT;;;;;;;;;;;
10;SYS_RESETn;;RESET_OUT;-;-;-;-;-;-;-;;
11;UART4_RXD;0x070;gpmc_wait0;mii2_crs;gpmc_csn4;rmii2_crs_dv;mmc1_sdcd;pr1_mii1_col;uart4_rxd;gpio0[30];;
12;GPIO1_28;0x078;gpmc_ben1;mii2_col;gpmc_csn6;mmc2_dat3;gpmc_dir;pr1_mii1_rxlink;mcasp0_aclkr;gpio1[28];;
13;UART4_TXD;0x074;gpmc_wpn;mii2_rxerr;gpmc_csn5;rmii2_rxerr;mmc2_sdcd;pr1_mii1_txen;uart4_txd;gpio0[31];;
14;EHRPWM1A;0x048;gpmc_a2;mii2_txd3;rgmii2_td3;mmc2_dat1;gpmc_a18;pr1_mii1_txd2;ehrpwm1A;gpio1[18];;
15;GPIO1_16;0x040;gpmc_a0;gmii2_txen;rmii2_tctl;mii2_txen;gpmc_a16;pr1_mii_mt1_clk;ehrpwm1_tripzone_input;gpio1[16];;
16;EHRPWM1B;0x04C;gpmc_a3;mii2_txd2;rgmii2_td2;mmc2_dat2;gpmc_a19;pr1_mii1_txd1;ehrpwm1B;gpio1[19];;
17;I2C1_SCL;0x15C;spi0_cs0;mmc2_sdwp;I2C1_SCL;ehrpwm0_synci;pr1_uart0_txd;pr1_edio_data_in1;pr1_edio_data_out1;gpio0[5];;
18;I2C1_SDA;0x158;spi0_d1;mmc1_sdwp;I2C1_SDA;ehrpwm0_tripzone;pr1_uart0_rxd;pr1_edio_data_in0;pr1_edio_data_out0;gpio0[4];;
19;I2C2_SCL;0x17C;uart1_rtsn;timer5;dcan0_rx;I2C2_SCL;spi1_cs1;pr1_uart0_rts_n;pr1_edc_latch1_in;gpio0[13];;
20;I2C2_SDA;0x178;uart1_ctsn;timer6;dcan0_tx;I2C2_SDA;spi1_cs0;pr1_uart0_cts_n;pr1_edc_latch0_in;gpio0[12];;
21;UART2_TXD;0x154;spi0_d0;uart2_txd;I2C2_SCL;ehrpwm0B;pr1_uart0_rts_n;pr1_edio_latch_in;EMU3;gpio0[3];;
22;UART2_RXD;0x150;spi0_sclk;uart2_rxd;I2C2_SDA;ehrpwm0A;pr1_uart0_cts_n;pr1_edio_sof;EMU2;gpio0[2];;Output
23;GPIO1_17;0x044;gpmc_a1;gmii2_rxdv;rgmii2_rxdv;mmc2_dat0;gpmc_a17;pr1_mii1_txd3;ehrpwm0_synco;gpio1[17];;Input
24;UART1_TXD;0x184;uart1_txd;mmc2_sdwp;dcan1_rx;I2C1_SCL;-;pr1_uart0_txd;pr1_pru0_pru_r31_16;gpio0[15];;I/O
25;GPIO3_21;0x1AC;mcasp0_ahclkx;eQEP0_strobe;mcasp0_axr3;mcasp1_axr1;EMU4;pr1_pru0_pru_r30_7;pr1_pru0_pru_r31_7;gpio3[21];;
26;UART1_RXD;0x180;uart1_rxd;mmc1_sdwp;dcan1_tx;I2C1_SDA;-;pr1_uart0_rxd;pr1_pru1_pru_r31_16;gpio0[14];;
27;GPIO3_19;0x1A4;mcasp0_fsr;eQEP0B_in;mcasp0_axr3;mcasp1_fsx;EMU2;pr1_pru0_pru_r30_5;pr1_pru0_pru_r31_5;gpio3[19];;
28;SPI1_CS0;0x19C;mcasp0_ahclkr;ehrpwm0_synci;mcasp0_axr2;spi1_cs0;eCAP2_in_PWM2_out;pr1_pru0_pru_r30_3;pr1_pru0_pru_r31_3;gpio3[17];;
29;SPI1_D0;0x194;mcasp0_fsx;ehrpwm0B;-;spi1_d0;mmc1_sdcd;pr1_pru0_pru_r30_1;pr1_pru0_pru_r31_1;gpio3[15];;
30;SPI1_D1;0x198;mcasp0_axr0;ehrpwm0_tripzone;-;spi1_d1;mmc2_sdcd;pr1_pru0_pru_r30_2;pr1_pru0_pru_r31_2;gpio3[16];;
31;SPI1_SCLK;0x190;mcasp0_aclkx;ehrpwm0A;-;spi1_sclk;mmc0_sdcd;pr1_pru0_pru_r30_0;pr1_pru0_pru_r31_0;gpio3[14];;
32;VADC;;;;;;;;;;;
33;AIN4;;;;;;;;;;;
34;AGND;;;;;;;;;;;
35;AIN6;;;;;;;;;;;
36;AIN5;;;;;;;;;;;
37;AIN2;;;;;;;;;;;
38;AIN3;;;;;;;;;;;
39;AIN0;;;;;;;;;;;
40;AIN1;;;;;;;;;;;
41;CLKOUT2;0x1B4;xdma_event_intr1;-;tclkin;clkout2;timer7;pr1_pru0_pru_r31_16;EMU3;gpio0[20];;
42;GPIO0_7;0x164;eCAP0_in_PWM0_out;uart3_txd;spi1_cs1;pr1_ecap0_ecap_capin_apwm_o;spi1_sclk;mmc0_sdwp;xdma_event_intr2;gpio0[7];;
43;GND;;;;;;;;;;;
44;GND;;;;;;;;;;;
45;GND;;;;;;;;;;;
46;GND;;;;;;;;;;;
};

data_H8 = %q{1;GND;;;;;;;;;;;
2;GND;;;;;;;;;;;
3;GPIO1_6;0x018;gpmc_ad6;mmc1_dat6;-;-;-;-;-;gpio1[6];;
4;GPIO1_7;0x01C;gpmc_ad7;mmc1_dat7;-;-;-;-;-;gpio1[7];;
5;GPIO1_2;0x008;gpmc_ad2;mmc1_dat2;-;-;-;-;-;gpio1[2];;
6;GPIO1_3;0x00C;gpmc_ad3;mmc1_dat3;-;-;-;-;-;gpio1[3];;
7;TIMER4;0x090;gpmc_advn_ale;-;timer4;-;-;-;-;gpio2[2];;
8;TIMER7;0x094;gpmc_oen_ren;-;timer7;-;-;-;-;gpio2[3];;
9;TIMER5;0x09C;gpmc_ben0_cle;-;timer5;-;-;-;-;gpio2[5];;
10;TIMER6;0x098;gpmc_wen;-;timer6;-;-;-;-;gpio2[4];;
11;GPIO1_13;0x034;gpmc_ad13;lcd_data18;mmc1_dat5;mmc2_dat1;eQEP2B_in;pr1_mii0_txd1;pr1_pru0_pru_r30_15;gpio1[13];;
12;GPIO1_12;0x030;gpmc_ad12;lcd_data19;mmc1_dat4;mmc2_dat0;eQEP2A_IN;pr1_mii0_txd2;pr1_pru0_pru_r30_14;gpio1[12];;
13;EHRPWM2B;0x024;gpmc_ad9;lcd_data22;mmc1_dat1;mmc2_dat5;ehrpwm2B;pr1_mii0_col;-;gpio0[23];;
14;GPIO0_26;0x028;gpmc_ad10;lcd_data21;mmc1_dat2;mmc2_dat6;ehrpwm2_tripzone_in;pr1_mii0_txen;-;gpio0[26];;
15;GPIO1_15;0x03C;gpmc_ad15;lcd_data16;mmc1_dat7;mmc2_dat3;eQEP2_strobe;pr1_ecap0_ecap_capin_apwm_o;pr1_pru0_pru_r31_15;gpio1[15];;
16;GPIO1_14;0x038;gpmc_ad14;lcd_data17;mmc1_dat6;mmc2_dat2;eQEP2_index;pr1_mii0_txd0;pr1_pru0_pru_r31_14;gpio1[14];;
17;GPIO0_27;0x02C;gpmc_ad11;lcd_data20;mmc1_dat3;mmc2_dat7;ehrpwm0_synco;pr1_mii0_txd3;-;gpio0[27];;
18;GPIO2_1;0x08C;gpmc_clk;lcd_memory_clk;gpmc_wait1;mmc2_clk;pr1_mii1_crs;pr1_mdio_mdclk;mcasp0_fsr;gpio2[1];;
19;EHRPWM2A;0x020;gpmc_ad8;lcd_data23;mmc1_dat0;mmc2_dat4;ehrpwm2A;pr1_mii_mt0_clk;-;gpio0[22];;
20;GPIO1_31;0x084;gpmc_csn2;gpmc_be1n;mmc1_cmd;pr1_edio_data_in7;pr1_edio_data_out7;pr1_pru1_pru_r30_13;pr1_pru1_pru_r31_13;gpio1[31];;
21;GPIO1_30;0x080;gpmc_csn1;gpmc_clk;mmc1_clk;pr1_edio_data_in6;pr1_edio_data_out6;pr1_pru1_pru_r30_12;pr1_pru1_pru_r31_12;gpio1[30];;Output
22;GPIO1_5;0x014;gpmc_ad5;mmc1_dat5;-;-;-;-;-;gpio1[5];;Input
23;GPIO1_4;0x010;gpmc_ad4;mmc1_dat4;-;-;-;-;-;gpio1[4];;I/O
24;GPIO1_1;0x004;gpmc_ad1;mmc1_dat1;-;-;-;-;-;gpio1[1];;
25;GPIO1_0;0x000;gpmc_ad0;mmc1_dat0;-;-;-;-;-;gpio1[0];;
26;GPIO1_29;0x07C;gpmc_csn0;-;-;-;-;-;-;gpio1[29];;
27;GPIO2_22;0x0E0;lcd_vsync;gpmc_a8;gpmc_a1;pr1_edio_data_in2;pr1_edio_data_out2;pr1_pru1_pru_r30_8;pr1_pru1_pru_r31_8;gpio2[22];;
28;GPIO2_24;0x0E8;lcd_pclk;gpmc_a10;pr1_mii0_crs;pr1_edio_data_in4;pr1_edio_data_out4;pr1_pru1_pru_r30_10;pr1_pru1_pru_r31_10;gpio2[24];;
29;GPIO2_23;0x0E4;lcd_hsync;gpmc_a9;gpmc_a2;pr1_edio_data_in3;pr1_edio_data_out3;pr1_pru1_pru_r30_9;pr1_pru1_pru_r31_9;gpio2[23];;
30;GPIO2_25;0x0EC;lcd_ac_bias_en;gpmc_a11;pr1_mii1_crs;pr1_edio_data_in5;pr1_edio_data_out5;pr1_pru1_pru_r30_11;pr1_pru1_pru_r31_11;gpio2[25];;
31;UART5_CTSN;0x0D8;lcd_data14;gpmc_a18;eQEP1_index;mcasp0_axr1;uart5_rxd;pr1_mii0_rxd3;uart5_ctsn;gpio0[10];;
32;UART5_RTSN;0x0DC;lcd_data15;gpmc_a19;eQEP1_strobe;mcasp0_ahclkx;mcasp0_axr3;pr1_mii0_rxdv;uart5_rtsn;gpio0[11];;
33;UART4_RTSN;0x0D4;lcd_data13;gpmc_a17;eQEP1B_in;mcasp0_fsr;mcasp0_axr3;pr1_mii0_rxer;uart4_rtsn;gpio0[9];;
34;UART3_RTSN;0x0CC;lcd_data11;gpmc_a15;ehrpwm1B;mcasp0_ahclkr;mcasp0_axr2;pr1_mii0_rxd0;uart3_rtsn;gpio2[17];;
35;UART4_CTSN;0x0D0;lcd_data12;gpmc_a16;eQEP1A_in;mcasp0_aclkr;mcasp0_axr2;pr1_mii0_rxlink;uart4_ctsn;gpio0[8];;
36;UART3_CTSN;0x0C8;lcd_data10;gpmc_a14;ehrpwm1A;mcasp0_axr0;-;pr1_mii0_rxd1;uart3_ctsn;gpio2[16];;
37;UART5_TXD;0x0C0;lcd_data8;gpmc_a12;ehrpwm1_tripzone_in;mcasp0_aclkx;uart5_txd;pr1_mii0_rxd3;uart2_ctsn;gpio2[14];;
38;UART5_RXD;0x0C4;lcd_data9;gpmc_a13;ehrpwm0_synco;mcasp0_fsx;uart5_rxd;pr1_mii0_rxd2;uart2_rtsn;gpio2[15];;
39;GPIO2_12;0x0B8;lcd_data6;gpmc_a6;pr1_edio_data_in6;eQEP2_index;pr1_edio_data_out6;pr1_pru1_pru_r30_6;pr1_pru1_pru_r31_6;gpio2[12];;
40;GPIO2_13;0x0BC;lcd_data7;gpmc_a7;pr1_edio_data_in7;eQEP2_strobe;pr1_edio_data_out7;pr1_pru1_pru_r30_7;pr1_pru1_pru_r31_7;gpio2[13];;
41;GPIO2_10;0x0B0;lcd_data4;gpmc_a4;pr1_mii0_txd1;eQEP2A_in;-;pr1_pru1_pru_r30_4;pr1_pru1_pru_r31_4;gpio2[10];;
42;GPIO2_11;0x0B4;lcd_data5;gpmc_a5;pr1_mii0_txd0;eQEP2B_in;-;pr1_pru1_pru_r30_5;pr1_pru1_pru_r31_5;gpio2[11];;
43;GPIO2_8;0x0A8;lcd_data2;gpmc_a2;pr1_mii0_txd3;ehrpwm2_tripzone_in;-;pr1_pru1_pru_r30_2;pr1_pru1_pru_r31_2;gpio2[8];;
44;GPIO2_9;0x0AC;lcd_data3;gpmc_a3;pr1_mii0_txd2;ehrpwm0_synco;-;pr1_pru1_pru_r30_3;pr1_pru1_pru_r31_3;gpio2[9];;
45;GPIO2_6;0x0A0;lcd_data0;gpmc_a0;pr1_mii_mt0_clk;ehrpwm2A;-;pr1_pru1_pru_r30_0;pr1_pru1_pru_r31_0;gpio2[6];;
46;GPIO2_7;0x0A4;lcd_data1;gpmc_a1;pr1_mii0_txen;ehrpwm2B;-;pr1_pru1_pru_r30_1;pr1_pru1_pru_r31_1;gpio2[7];;
};


# -------------------------------------------------------------------

lines_H9 = data_H9.split /\n/;
lines_H8 = data_H8.split /\n/;

class Pin
  attr_accessor :pos, :name, :offset, :modeVec
end

# list of all pins as Ruby objects 
$pinList = []

# populate $pinList with all pins from header 8
lines_H8.each do |li|
  fields = li.split /;/;
  pin = Pin.new
  pin.pos = "P.8.#{fields[0]}"
  pin.name = fields[1]
  pin.offset = fields[2]
  vec = []
  (0..7).each do |i|
    vec[i] = fields[3+i]
  end
  pin.modeVec = vec
  $pinList.push(pin)
end

# populate $pinList with all pins from header 9
lines_H9.each do |li|
  fields = li.split /;/;
  pin = Pin.new
  pin.pos = "P.9.#{fields[0]}"
  pin.name = fields[1]
  pin.offset = fields[2]
  vec = []
  (0..7).each do |i|
    vec[i] = fields[3+i]
  end
  pin.modeVec = vec
  $pinList.push(pin)
end


# get pin data from "ofwdump"
ofw_txt = `ofwdump -a -p`;


# trova i blocchi di testo-dati, che sono i blocche per cui 
# pinctrl-single,pins:HEXNUMBERS-SPACES-OR-NEWLINES
dataTxtLines = ofw_txt.scan(/pinctrl-single,pins:\n\s+((?:\d|\s|[abcdef]|\n)+)\w/m)

# per ogni blocco di testo-dati ritorna solo gli hexdigits
hexLines = []
dataTxtLines.each do |line|
  tmp = line[0].gsub(/\s/, "")
  if tmp.class == String then
    hexLines.push(tmp)
  end
  if tmp.class == Array then 
    tmp.each do |x| hexLines.push(x)
    end 
  end
end

# split hex-strings into 16-hex-digits-strings blocks ==> 64 bit
str64bitList = []
hexLines.each do |str|
  tmp = str.scan(/[0123456789abcdef]{16}/)
  if tmp.class == String then
    str64bitList.push(tmp) ; end
  if tmp.class == Array then 
    tmp.each do |x| 
      str64bitList.push(x)
    end
  end
end

# class for object representing Memory addresses and values 
class MemVal 
  attr_accessor :offset, :value
  # get the pin mode, which is the value of the first byte, the less
  # significant.
  def getMode()
    out = sprintf("%o", eval("0x#{@value}") )
    # last character of octal representation 
    return out[-1]
  end
end

# List of objects "MemVal"
$memValList = []
str64bitList.each do |str64|
  off, val = str64.scan(/[0123456789abcdef]{8}/)
  mv = MemVal.new
  mv.offset = off 
  mv.value = val
  $memValList.push(mv)
end


# Use "gpioctl" to get list of active GPIO pins 
# The result is put into an hash which contains, for example
# gpio1[24] --> <OUT> 
# gpio1[25] --> <IN,PD> ... 
$gpioHash = {}
[0, 1, 2, 3].each do |idx|
   txt = `gpioctl -f /dev/gpioc#{idx} -l`
   lines = txt.split /\n/
   lines.each do |li|
     # drop all lines of ending with "gpio_XY<>", which are not configured gpios
     next if li.match /gpio_\d{1,2}<>$/;
     li.match /gpio_(\d+)<(.*?)>$/;
     # puts "DBG> gpio#{idx}[#{$1}] -- <#{$2}>"
     $gpioHash["gpio#{idx}[#{$1}]"] = "<#{$2}>"
   end
end


# A new method for the Pin class which gets the pinMode  
# -] out can be nil, or {0, 1, ... , 7}, or "not-fount" in case  
#    something went wrong.
class Pin 
  def getMode
    tmp = self.offset
    return nil if tmp == nil 
    tmp.sub!(/^0x0*/,"")
    tmp.downcase!
    # puts "DBG> tmp: #{tmp}"
    $memValList.each do |mv|
      tmp2 = mv.offset
      tmp2.sub!(/^0*/,"")
      tmp2.downcase!
      # puts "DBG> tmp2: #{tmp2}"
      if tmp == tmp2 then
        out = mv.getMode
        return out.to_i
      end
    end
    # if we arrived here a correspondence was not found 
    # we check if the pin corresponds to an active GPIO
    pinGPIOname = self.modeVec[7]
    if $gpioHash.has_key? pinGPIOname then
      return 7
    else 
      return "-"  
    end
  end
end


# A new method for class Pin wich gets the pin function name
# accordin to the pin mode.
class Pin 
  def getFunction
    mode = self.getMode
    return nil if not (mode.class == Integer)
    out = self.modeVec[mode]
    return out
  end
end


# Print a table with all pin: position, name, mode, function and setup-(for gpios)
printf("-------------------------------------------------------------------\n")
printf("%-8s %-15sMode  %-20s %-7s\n", "Pos", "Name", "Function", "Setup")
printf("-------------------------------------------------------------------\n")
$pinList.each do |p|
  pinFunction = p.getFunction
  gpioConf = ""
  if ((pinFunction != nil) && (pinFunction.match /^gpio/)) then 
    vv = $gpioHash[p.getFunction]
    vv.match(/<(.*?)>/)
    gpioConf = "<#{$1}>"
  end
  tmp = sprintf("%-8s %-15s %-3s  %-20s %-7s", p.pos, p.name, p.getMode.to_s, 
                pinFunction, gpioConf)
  puts tmp
end


# for debug: 
# binding.pry


