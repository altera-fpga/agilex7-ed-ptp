#!/usr/bin/perl
use strict;
use warnings;

my $arg = shift @ARGV or die "Usage: $0 HSSI_25G=1 | HSSI_50G=1 | HSSI_100G=1 | HSSI_200G=1\n";

my ($feature, $value) = split(/=/, $arg);

die "Invalid input format. Use like HSSI_25G=1\n"
    unless defined $feature && defined $value;

my %params = (
    'HSSI_10G'  => [
        "set_global_assignment -name VERILOG_MACRO FTILE_PTP_HSSI_10G_25G",
        "set_global_assignment -name VERILOG_MACRO FTILE_PTP_HSSI_10G",
        "set_global_assignment -name VERILOG_MACRO MAC_SRD_CFG_25G"
    ],
    'HSSI_25G'  => [
        "set_global_assignment -name VERILOG_MACRO FTILE_PTP_HSSI_10G_25G",
        "set_global_assignment -name VERILOG_MACRO FTILE_PTP_HSSI_25G",
        "set_global_assignment -name VERILOG_MACRO MAC_SRD_CFG_25G"
    ],
    'HSSI_50G'  => [
        "set_global_assignment -name VERILOG_MACRO FTILE_PTP_HSSI_50G_AUI1_PAM4",
        "set_global_assignment -name VERILOG_MACRO MAC_SRD_CFG_25G"
    ],
    'HSSI_100G' => [
        "set_global_assignment -name VERILOG_MACRO FTILE_PTP_HSSI_100G_GAUI2_PAM4",
        "set_global_assignment -name VERILOG_MACRO MAC_SRD_CFG_25G"
    ],
);

die "Unknown feature: $feature. Use HSSI_25G | HSSI_50G | HSSI_100G | HSSI_200G\n"
    unless exists $params{$feature};

my %lists = (
    'HSSI_10G'  => [
        "set_global_assignment -name IP_FILE ../src/ip/qsys_top/hssi_ss_10G/hssi_ss_10G.ip"
    ],
    'HSSI_25G'  => [
        "set_global_assignment -name IP_FILE ../src/ip/qsys_top/hssi_ss_25G/hssi_ss_25G.ip"
    ],
    'HSSI_50G'  => [
        "set_global_assignment -name IP_FILE ../src/ip/qsys_top/hssi_ss_50G/hssi_ss_50G_PAM4.ip"
    ],
    'HSSI_100G' => [
        "set_global_assignment -name IP_FILE ../src/ip/qsys_top/hssi_ss_100G/hssi_ss_100G_PAM4.ip"
    ],
);

my $filename = "../../synth/top.qsf";

my @replace_lines = (50, 51, 52);   # replace these 3 lines
my $list_line     = 396;            # insert extra line here

open my $fh, '<', $filename or die "Could not open '$filename': $!";
my @lines = <$fh>;
close $fh;

splice(@lines, $list_line, 0, map { "$_\n" } @{ $lists{$feature} });

for my $i (0 .. $#replace_lines) {
    my $line_idx = $replace_lines[$i] - 1;  # arrays are 0-based

    # Ensure file has enough lines
    if ($line_idx > $#lines) {
        push @lines, ("\n") x ($line_idx - $#lines);
    }

    if (defined $params{$feature}[$i]) {
        # Replace with actual macro line
        $lines[$line_idx] = $params{$feature}[$i] . "\n";
    } else {
        # If no line exists for this feature (like 100G's 3rd line), blank it
        $lines[$line_idx] = "\n";
    }
}

open my $out, '>', $filename or die "Could not write '$filename': $!";
print $out @lines;
close $out;

print "Updated $filename for $feature=$value (replaced lines @replace_lines and inserted at $list_line)\n";
