#!/usr/bin/perl

use strict;
use warnings;

#adding the ip list
my $arg = shift @ARGV or die "Usage: $0 HSSI_10G=1 | HSSI_25G=1 | HSSI_50G=1 | HSSI_200G=1\n";

my ($feature, $value) = split(/=/, $arg);

die "Invalid format. Use like HSSI_25G=1\n"
    unless defined $feature && defined $value;

my %lines_to_add = (
    'HSSI_10G'  => "set_global_assignment -name IP_FILE ../src/ip/qsys_top/hssi_ss_10G/hssi_ss_10G.ip",
    'HSSI_25G'  => "set_global_assignment -name IP_FILE ../src/ip/qsys_top/hssi_ss_25G/hssi_ss_25G.ip",
    'HSSI_50G'  => "set_global_assignment -name IP_FILE ../src/ip/qsys_top/hssi_ss_50G/hssi_ss_50G_PAM4.ip",
    'HSSI_100G' => "set_global_assignment -name IP_FILE ../src/ip/qsys_top/hssi_ss_100G/hssi_ss_100G_PAM4.ip",
);


die "Unknown feature: $feature. Use HSSI_25G | HSSI_50G | HSSI_200G\n"
    unless exists $lines_to_add{$feature};

my $filename = "ip_list.tcl";  
my $line_num = 7;  

open my $fh, '<', $filename or die "Could not open '$filename': $!";
my @lines = <$fh>;
close $fh;

splice(@lines, $line_num - 1, 0, $lines_to_add{$feature} . "\n");

open my $out, '>', $filename or die "Could not write '$filename': $!";
print $out @lines;
close $out;

print "Inserted at line $line_num in $filename\n";

#converting .tcl to .f
my $text= '$DESIGN_DIR';
my $text1= '../';
#IP LIST
open(my $in,  "<", "ip_list.tcl") or die "Couldn't open ip_list.tcl: $!";
open(my $out, ">", "ip_list.f")   or die "Couldn't open ip_list.f: $!";

while (my $line = <$in>) {
    chomp $line;

    my $char = substr($line, 28, 1);

    if ($char eq "I") {
        substr($line, 0, 36) = $text1;
    }
    else {
        substr($line, 0, 38) = $text1;
    }

    print $out "$line\n";
}

close $in;
close $out;

print "Converted ip_list.tcl → ip_list.f successfully\n";
