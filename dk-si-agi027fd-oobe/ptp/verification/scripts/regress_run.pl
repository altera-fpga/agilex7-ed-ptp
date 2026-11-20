########################################################################
# Copyright (C) 2025 Altera Corporation.
# SPDX-License-Identifier: MIT
########################################################################
# Regresion script
########################################################################

#!/usr/bin/env perl

use strict;
use warnings;

use MIME::Lite; 
use Net::SMTP;
#use Cwd qw();
my $PTP_ROOTDIR = Cwd::cwd();
my $PTP_ROOTDIR=`git rev-parse --show-toplevel`; 
my $sanitytests = `echo \${PTP_ROOTDIR}/tests/fptp_regr_pkg.svh`;
my $sim = `echo \${PTP_ROOTDIR}/sim`;
my $filename ;
my $comp_log_end_pattern;
my $sim_log_end_pattern;
my $runsim ;
my $testdir = ' '; 
my $a = "FAILED"; 
my $b = "FAILED"; 
my $flag = 0;
my $run = 0;
my $result = ' ';
my $seed;
my $data = "<table border='1'>";
my $count=0;
my $cmd_opt = ' ';
my $package  = $ARGV[0];
my $variant = $ARGV[1];
my $coverage = $ARGV[2];
my $scripts=`pwd`;
my @tests_to_run ;
my $git_rev = `git log -n 1`;
my $testname = ' ';
my $seqname = ' ';
$cmd_opt = 'arc submit -PE flow/sw/bigmem mem=20000 -- ';
chomp $scripts;

print "sim -> $sim\n";

chomp $sim;
$filename = '../sim/vcs.log';
$comp_log_end_pattern = 'CPU';
$sim_log_end_pattern = 'Test failed|Test passed|UVM_ERROR|UVM_FATAL|CPU Time|Fatal: ';
$runsim = '';


if($package eq "fptp_regr_pkg")
{
   print "PTP ROOT DIR = $PTP_ROOTDIR\n";
   my $sanitytests = `echo \${PTP_ROOTDIR}/tests/fptp_regr_pkg.svh`;
   print "$sanitytests\n";
   push(@tests_to_run,$sanitytests);
   chomp $sanitytests;
   open FH,"<",$sanitytests or die "Couldn't open file file.txt, $!";
   my $test_path = `echo \${PTP_ROOTDIR}/tests/`;
   chomp $test_path;
   while(<FH>)
   {
       if($_ =~ m/include /i)
       {
           my @local_array = split("include",$_);
           $local_array[1] =~ s/"//g;
           $local_array[1] =~ s/ //g;
           $local_array[1]= "$test_path".$local_array[1];
           push(@tests_to_run,$local_array[1]);
       }
   }
}


if(defined $variant)
{
  if($variant eq "100G")
  {
    print "100G\n";
    if(defined $coverage)
    { 
      if ($coverage eq "cov")
      {
        print "WITH COVERAGE\n";
        #system("gmake -f Makefile_VCS.mk clean");
        system("gmake -f Makefile.mk cmplib HSSI_100G=1 | tee cmp.log");
        system("gmake -f Makefile.mk build HSSI_100G=1 COV=1");
      }
    }
    else
    {
      print "WITHOUT COVERAGE\n";
      #system("gmake -f Makefile_VCS.mk clean");
      system("gmake -f Makefile.mk cmplib HSSI_100G=1 | tee cmp.log");
      system("gmake -f Makefile.mk build HSSI_100G=1");
    }  
  }
  if($variant eq "50G")
  {
    print "50G\n";
    if(defined $coverage)
    { 
      if ($coverage eq "cov")
      {
        print "WITH COVERAGE\n";
        #system("gmake -f Makefile_VCS.mk clean");
        system("gmake -f Makefile.mk cmplib HSSI_50G=1 | tee cmp.log");
        system("gmake -f Makefile.mk build HSSI_50G=1 COV=1");
      }
    }
    else
    {
      print "WITHOUT COVERAGE\n";
      #system("gmake -f Makefile_VCS.mk clean");
      system("gmake -f Makefile.mk cmplib HSSI_50G=1 | tee cmp.log");
      system("gmake -f Makefile.mk build HSSI_50G=1");
    }  
  }
  if($variant eq "25G")
  {
    print "25G\n";
    if(defined $coverage)
    { 
      if ($coverage eq "cov")
      {
        print "WITH COVERAGE\n";
        #system("gmake -f Makefile_VCS.mk clean");
        system("gmake -f Makefile.mk cmplib HSSI_25G=1 | tee cmp.log");
        system("gmake -f Makefile.mk build HSSI_25G=1 COV=1");
      }
    }
    else
    {
      print "WITHOUT COVERAGE\n";
      #system("gmake -f Makefile_VCS.mk clean");
      system("gmake -f Makefile.mk cmplib HSSI_25G=1 | tee cmp.log");
      system("gmake -f Makefile.mk build HSSI_25G=1");
    }  
  }
  if ($variant eq "10G")
   {
     print "10G\n";
     if(defined $coverage)
    { 
      if ($coverage eq "cov")
      {
        print "WITH COVERAGE\n";
        #system("gmake -f Makefile_VCS.mk clean");
        system("gmake -f Makefile.mk cmplib HSSI_10G=1 | tee cmp.log");
        system("gmake -f Makefile.mk build HSSI_10G=1 COV=1");
      }
    }
    else
    {
      print "WITHOUT COVERAGE\n";
      #system("gmake -f Makefile_VCS.mk clean");
      system("gmake -f Makefile.mk cmplib HSSI_10G=1 | tee cmp.log");
      system("gmake -f Makefile.mk build HSSI_10G=1");
    }  
  }
 }

while (1) {
if (-e $filename) {
print "Compilation log is created..!";
   last;
   }

}

open(my $fh,  $filename)
  or die "Could not open file '$filename' $!";


while (1) { 
while (my $row = <$fh>) {
  chomp $row;
  if($row =~ m/$comp_log_end_pattern/)
  { print "$row\n"; $flag = 1; }
}
  if($flag == 1) {

   last;

  }

}


foreach my $item(@tests_to_run)
{
    open(my $sh,  $item)
    or die "Could not open file '$item' $!";

    while (my $test = <$sh>) {
      chomp $test;

      next if($test =~ m/`include "(fptp_base_test).svh"/);

      if($test =~ m/`include "(fptp_.*).svh"/)
      {
          $runsim = "simulate_$1.log";
          $testname = $1;
          $seqname=$1=~s/test/seq/r;    
          chomp $sim;
          print "$seqname\n";              
          if(defined $coverage)
          { 
             if ($coverage eq "cov") {
                 if($package eq "fptp_regr_pkg") {
                   system("$cmd_opt gmake -f Makefile.mk run TESTNAME=$testname SEQNAME=$seqname COV=1"); 
                 } 
             }
          }     
          else {
              if($package eq "fptp_regr_pkg") {
                system("$cmd_opt gmake -f Makefile.mk run TESTNAME=$testname SEQNAME=$seqname"); 
              } 
          }     
          print "$testname\n"; 
       }
     }
close $sh;
}


foreach my $item(@tests_to_run)
{
open(my $sh1,  $item)
  or die "Could not open file '$item' $!";

while (my $test = <$sh1>) {
  chomp $test;

  next if($test =~ m/`include "(fptp_base_test).svh"/);

  if($test =~ m/`include "(fptp_.*).svh"/)
  {
      chomp $test;
      print "$1\n";
      $runsim = "simulate_$1.log";
      my $testname = join("/","$sim","$1","$runsim");
      $testdir = $1;

      while (1) {
       if (-e $testname) {
         print "$runsim.log is created\n";
         last;
       }

     }


    open(my $rh,  $testname)
     or die "Could not open file '$testname' $!";

      $run=0;
         
      while (1) { 
        while (my $row = <$rh>) {
         chomp $row;
           if($row =~ m/$sim_log_end_pattern/)
                { print "$row\n"; $run = 1; $row = <$rh>;}
        }
      if($run == 1) {

        last;

       }

      }

    close($rh);

    ######Processing runsim.log files #################
   
    open(my $ph,  $testname)
     or die "Could not open file '$testname' $!";

     print "Processing $testname \n";


     $a = "failed";
     $b = "failed";

     while(my $row = <$ph>) {
      chomp $row;
 
        if($row =~ m/UVM_ERROR :    0/) {
          $a = "passed";
          print "Found 0 UVM_ERROR in $testname \n";
        }


        if($row =~ m/UVM_FATAL :    0/  ) {
          $b = "passed";
          print "Found 0 UVM_FATAL in $testname \n";
          last;
        }

        if($row =~ m/NOTE: automatic random seed used:(\s*)(\d*)/){
           $seed = $2;
        }


    }


    if($a eq "passed" && $b eq "passed") {

         $result = "passed"."\n";
      }
      else {

         $result = "failed"."\n";
      }


      if($count == 0) {   
       $data .= "<tr><td>Testcase Name</td><td>Seed value</td><td>Status</td></tr>"; 
       $count++;
      }

      if($a eq "passed" && $b eq "passed")
      {
       $data .= "<tr><td>$testdir</td><td>$seed</td><td>$result</td></tr>";
      }
      else
      {
       $data .= "<tr><td>$testdir</td><td>$seed</td><td><font size=\"3\" color=\"#FF0000\">$result</td></tr>";
      }



  }
 }
}

###########################################################
# Regression result will be sent in the mail as mentioned in 
# $mysender and $myreceiver
# Uncomment the exiting mail id and update it accordinlgy 
###########################################################
    $data .= "</table>";
    $data .= "<p> Result Dir - $scripts/../sim/ </p>";
    $data .= "<p> GIT Revision - $git_rev </p>";

my $sender = 'drajarat@ecsmtp-altera.sc.intel.com';
my $receiver = 'dinesh.babu.rajarathinam@altera.com,ipsita.das@altera.com';
my $mail_host = 'smtp.intel.com';
my $msg_body ="Attached is a file";
#
################## Post processing for email 
##
if($variant eq "100G") {
my $msg = MIME::Lite->new(
    From    => $sender,
    To      => $receiver,
    # Cc      => $cc_receiver,
    Subject => "Regression results for FPTP NON_ANLT 100G UVM simulations - Test pkg: $sanitytests",
  #  Data    => $msg_body,
   Type    =>"multipart/mixed",
);
$msg->attach(Type         => 'text/html',
             Data         => $data 
             );

#$msg->attach('Type'     => 'application/octet-stream',
#             'Encoding' => 'base64',
#              Path      => "outfile.txt"
#          );

MIME::Lite->send('smtp',$mail_host , Timeout=>60);
$msg->send();
}
elsif ($variant eq "50G"){
my $msg = MIME::Lite->new(
    From    => $sender,
    To      => $receiver,
    # Cc      => $cc_receiver,
    Subject => "Regression results for FPTP NON_ANLT 50G UVM simulations - Test pkg: $sanitytests",
  #  Data    => $msg_body,
   Type    =>"multipart/mixed",
);
$msg->attach(Type         => 'text/html',
             Data         => $data 
             );

#$msg->attach('Type'     => 'application/octet-stream',
#             'Encoding' => 'base64',
#              Path      => "outfile.txt"
#          );

MIME::Lite->send('smtp',$mail_host , Timeout=>60);
$msg->send();
}
elsif ($variant eq "25G"){
my $msg = MIME::Lite->new(
    From    => $sender,
    To      => $receiver,
    # Cc      => $cc_receiver,
    Subject => "Regression results for FPTP NON_ANLT 25G UVM simulations - Test pkg: $sanitytests",
  #  Data    => $msg_body,
   Type    =>"multipart/mixed",
);
$msg->attach(Type         => 'text/html',
             Data         => $data 
             );

#$msg->attach('Type'     => 'application/octet-stream',
#             'Encoding' => 'base64',
#              Path      => "outfile.txt"
#          );

MIME::Lite->send('smtp',$mail_host , Timeout=>60);
$msg->send();
}
elsif ($variant eq "10G"){
my $msg = MIME::Lite->new(
    From    => $sender,
    To      => $receiver,
    # Cc      => $cc_receiver,
    Subject => "Regression results for FPTP NON_ANLT 10G UVM simulations - Test pkg: $sanitytests",
  #  Data    => $msg_body,
   Type    =>"multipart/mixed",
);
$msg->attach(Type         => 'text/html',
             Data         => $data 
             );

#$msg->attach('Type'     => 'application/octet-stream',
#             'Encoding' => 'base64',
#              Path      => "outfile.txt"
#          );

MIME::Lite->send('smtp',$mail_host , Timeout=>60);
$msg->send();
}







