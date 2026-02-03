# Altera Agilex™ 7 IEEE1588 PTP Multi-Channel QoS Support System Example Design Build Scripts


# Dependency

- Altera Quartus Prime (See Release Notes for the supported version)

# Build Steps

 1. Compile design and generate configuration (sof) file:
    
    The synth folder contains a Makefile and the Quartus Project.The Makefile support various compile options such as 
    - make compile - runs the compile stage of Quartus
    - make synth   - runs synthesis stage of Quartus
     
    # Specify the configuration using the optional argument CONFIG. 
    # Supported options are 10G_ANLT, 10G_NON_ANLT, 25G_ANLT, 25G_NON_ANLT, 50G_ANLT, 50G_NON_ANLT, 100G_ANLT and 100G_NON_ANL
    # For e.g. "make all CONFIG=10G_ANLT". 
    # if the CONFIG argument is not specified, the value currently in config.txt will be built. 
    # Running <make> will print out all the options supported
    # Alternatively, if using the GUI is preferred, the qpf file can be opened in Quartus and compile options selected there.
    # Before compiling in GUI, appropriate CONFIG options has to be provided in config.txt. For e.g. Configuration=10G_ANLT 

    ```
    cd synth/
    make all CONFIG=10G_ANLT     - Runs a full Quartus compile including the Assembler for 10G_ANLT
    
    ```

# Programming Files Generation Steps <UPDATE BELOW>

 Generate `ghrd_agmf039r47a1e2vr0.{core,hps}.rbf` including U-Boot SPL:

    ```
    cd synth/
    quartus_pfg -c -o hps=on -o hps_path=../../sw/artifacts/u-boot-spl-dtb.hex output_files/top.sof output_files/top.rbf
    ```
