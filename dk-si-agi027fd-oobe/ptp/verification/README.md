# How to setup UVM TB and run sumulation for UVM Testcase for FTILE PTP NON-ANLT  
# There are 4 variants in NON-ANLT DESIGN. 10G,25G,50G and 100G.
# Below steps needs to be done for each variant in a separate xterm. 
# Two variants cannot be run in a single xterm. This needs to be taken care primarily.

# Initial Setup:
  1)  Get a Bash shell (e.g. xterm)
# For Internal Customers:
  2)  source env/env.sh
  3)  source env/setup.sh
# For External Customers:
  1)  Set all tool paths vcs, python etc. Please make sure Tool versions used are as follows:
      VCS : vcsmx/T-2022.06-SP2-3
      Python : python/3.7.7
      Quartus : To be checked for the latest quartus version
  2)  Set the required environment and directory Structure variables (as shown below)
      export PTP_ROOTDIR=<pwd>
      export QUARTUS_HOME=<Quartus Installation path upto /quartus>
      export QUARTUS_INSTALL_DIR=$QUARTUS_HOME
      export UVM_HOME=<UVM HOME Dir>
      export SYNTH_DIR=$PTP_ROOTDIR/../../synth


# How to Run UVM Testcases 
1)  cd $PTP_ROOTDIR/scripts

#   10G NON-ANLT Design
2)  For Compiling IPs and Subsystems, execute: “gmake -f Makefile.mk cmplib  HSSI_10G=1 | tee cmp.log” 
3)  For building RTL & TB QOS , execute: “gmake -f Makefile.mk build  HSSI_10G=1 [DUMP=1]” [ DUMP is an option. If VPD is required, then use DUMP else it is not required]
#   25G NON-ANLT Design
2)  For Compiling IPs and Subsystems, execute: “gmake -f Makefile.mk cmplib  HSSI_25G=1 | tee cmp.log” 
3)  For building RTL & TB QOS , execute: “gmake -f Makefile.mk build  HSSI_25G=1 [DUMP=1]” [ DUMP is an option. If VPD is required, then use DUMP else it is not required]
#   50G NON-ANLT Design
2)  For Compiling IPs and Subsystems, execute: “gmake -f Makefile.mk cmplib  HSSI_50G=1 | tee cmp.log” 
3)  For building RTL & TB QOS , execute: “gmake -f Makefile.mk build  HSSI_50G=1 [DUMP=1]” [ DUMP is an option. If VPD is required, then use DUMP else it is not required]
#   100G NON-ANLT Design
2)  For Compiling IPs and Subsystems, execute: “gmake -f Makefile.mk cmplib  HSSI_100G=1 | tee cmp.log” 
3)  For building RTL & TB QOS , execute: “gmake -f Makefile.mk build  HSSI_100G=1 [DUMP=1]” [ DUMP is an option. If VPD is required, then use DUMP else it is not required]

4)  For tests run execute: “gmake -f Makefile.mk run TESTNAME=fptp_csr_test SEQNAME=fptp_csr_seq 
5)  Results are created in a sim directory ($PTP_ROOTDIR/sim/$TESTNAME).Check simulate_$TESTNAME.log for Simulation result. 
6)  If same test is  re-run, then the previous result dir gets renamed and moved as $PTP_ROOTDIR/verification/sim/$TESTNAME.#. E.g.fptp_csr_test.1, fptp_csr_test.2 .... and the latest test run result is created as $PTP_ROOTDIR/sim/$TESTNAME. 
7)  To clean the generated files in TB do "gmake -f Makefile clean " -> cleans sim folder, ip_libraries and generated files in scripts folder. Note: Don't do this unless it is required.


# UVM TESTS 
# BASE TEST
fptp_base_test.svh

# IO/CSR TESTS (DMA/PTPBRIDGE/TCAM/HSSI)
1.fptp_csr_test.svh
2.fptp_csr_tcam_test.svh

#  DATA PATH TESTS
3.fptp_dma_base_test.svh
4.fptp_usr_base_test.svh
5.fptp_qos_base_test.svh
6.fptp_qos_usr_test.svh
7.fptp_qos_usr_rand_test.svh

# EXTENDED DATA PATH TESTS
8.fptp_dma_base_priority0_test.svh
9.fptp_dma_base_priority1_test.svh
10.fptp_dma_base_randp0_test.svh
11.fptp_dma_base_randp1_test.svh
12.fptp_dma_base_randp2_test.svh
13.fptp_usr_lpbk_test.svh



How to Run UVM Regressions?:
1) cd $PTP_ROOTDIR/scripts
2)  Need to pass the arguments as per the variant
#  10G NON-ANLT Design
   "perl regress_run.pl fptp_regr_pkg 10G" 
#  25G NON-ANLT Design
   "perl regress_run.pl fptp_regr_pkg 25G" 
#  50G NON-ANLT Design
   "perl regress_run.pl fptp_regr_pkg 50G" 
#  100G NON-ANLT Design
   "perl regress_run.pl fptp_regr_pkg 100G" 

3) Results are created in a sim directory ($PTP_ROOTDIR/sim/$TESTNAME).Check stimulate_$TESTNAME.log for Simulation result. 
4) To run the regression with code coverage enabled run the below command as per the variant
#  10G NON-ANLT Design
   "perl regress_run.pl fptp_regr_pkg 10G cov" 
#  25G NON-ANLT Design
   "perl regress_run.pl fptp_regr_pkg 25G cov" 
#  50G NON-ANLT Design
   "perl regress_run.pl fptp_regr_pkg 50G cov" 
#  100G NON-ANLT Design
   "perl regress_run.pl fptp_regr_pkg 100G cov" 
5) To generate coverage report for a regression, execute: 
   #“urg -dir <$VERDIR/sim/simv.vdb> <$VERDIR/sim/regression.vdb> -format both -dbname final.vdb”
   #Note: The default report directory is “urgReport” and coverage database (regression.vdb) will be present in the same directory 
6)To open DVE of a single regression or testcase, execute:  ”dve -full64 -cov -covdir simv.vdb regression.vdb &”
7)To open DVE of a merged regression, execute: ”dve -full64 -cov -covdir <dirname.vdb> &
8)To load the coverage report, execute: “firefox urgReport/dashboard.html”
