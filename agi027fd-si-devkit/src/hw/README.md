# Altera Agilex&trade; 7 Precision Time Protocol System Example Design - Hardware


# Dependency

- Altera Quartus Prime (See Release Notes for the supported version)

# Build Steps

Compile design and generate configuration (sof) file:

The synth folder contains a Makefile and the Quartus Project.The Makefile support various compile options such as:

- `make compile` - runs the compile stage of Quartus
- `make synth` - runs synthesis stage of Quartus
- `make all` - runs a full Quartus compile including the Assembler
Running `make` will print out all the options supported

The Design can be compiled to specificate datarate with or w/o ANLT option using two methods as explaied below.


**Config File Method:**

The project Makefile reads `src/hw/synth/config.txt` to determine the Ethernet data rate for the Ethernet Subsystem IPs. Open config.txt and set the configuration to the desired Ethernet data rate with ANLT support as shown in the snippet below.

The config text file will have below config for 10GbE with ANLT;

```
Configuration=10G_ANLT
```

User needs to modify above text content with required option by replacing `10G_ANLT` with ant one of following options.

`10G_NON_ANLT`, `25G_ANLT`, `25G_NON_ANLT`, `50G_ANLT`, `50G_NON_ANLT`, `100G_ANLT`, `100G_NON_ANLT` and `10G_25G_NON_ANLT_DR`

**Command Method:**

- User can specify the configuration using the optional argument CONFIG. 
- Supported options are `10G_ANLT`, `10G_NON_ANLT`, `25G_ANLT`, `25G_NON_ANLT`, `50G_ANLT`, `50G_NON_ANLT`, `100G_ANLT`, `100G_NON_ANLT` and `10G_25G_NON_ANLT_DR`
   - For e.g. `make all CONFIG=10G_ANLT`. 
- if the **CONFIG** argument is not specified, the value currently in `config.txt` will be built. 
- Running <make> will print out all the options supported

   ```
   cd synth/
   make all CONFIG=10G_ANLT     - Runs a full Quartus compile including the Assembler for 10G_ANLT
   
   ```

# Programming Files Generation Steps

- Download `u-boot-spl-dtb.hex` from `sw/artifacts/u-boot-spl-dtb.hex`.
- Generate `top{core,hps}.rbf` including U-Boot SPL:

   ```
   cd synth/
   quartus_pfg -c -o hps=on -o hps_path=../../sw/artifacts/u-boot-spl-dtb.hex output_files/top.sof output_files/top.rbf
   ```
