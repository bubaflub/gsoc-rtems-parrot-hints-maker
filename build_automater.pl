#!/usr/bin/perl

=head1 NAME

tools/build/build_automater.pl - Build parrot out of directory

=head1 SYNOPSIS

 % perl tools/build/build_automater.pl <output_dir>

=head1 DESCRIPTION

This script will run Parrot's F<Configure.pl>, build with make, and then copy the generated files into a specified directory.

=cut

use strict;
use warnings;
use Getopt::Long();
use File::Path qw(make_path);
use File::Spec qw(catfile);
use File::Basename qw(dirname);
use File::Copy qw(move);

# accept output dir
my $usage = "Usage: $0 <output_dir>";
die $usage unless @ARGV == 1;
my $output_dir = $ARGV[0];

die "No such dir: $output_dir" unless -d $output_dir;
die "Cannot find Configure.pl" unless -e 'Configure.pl';
die "Cannot find MANIFEST.generated" unless -e 'MANIFEST.generated';
# run Configure.pl

system("perl Configure.pl");

# run make

system("make");

# parse MANIFEST.generated
open my $fh, '<', 'MANIFEST.generated' or die "Cannot open MANIFEST.generated: $!\n";
my @files;
while (my $line = <$fh>) {
  # ignore comment lines
  next if $line =~ m/^#/;
  # remove extra info
  $line =~ s/\s.*$//g;
  push @files, $line;
}

# move all those files to output dir

foreach my $file (@files) {
  my $final_dir = dirname(File::Spec->catfile($output_dir, $file));
  if (! -d $final_dir) {
    make_path($final_dir);
  }
  move($file, $final_dir);
}

# TODO
# use GetOpt
# accept flags for args to pass onto config script
# accept flags for what to make
# document in POD
# combine reading line from manifest and moving it
# flags for copying tests
# check return value from system commands
