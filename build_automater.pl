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
die "Cannot find MANIFEST.configure.generated" unless -e 'MANIFEST.configure.generated';
# run Configure.pl

system("perl Configure.pl");

# run make

system("make");

# parse MANIFEST.generated
read_manifest('MANIFEST.generated');
# parse MANIFEST.configure.generated
read_manifest('MANIFEST.configure.generated');
# move binary files as well
move_binaries();

sub read_manifest {
  my $file = shift;
  open my $fh, '<', $file or die "Cannot open $file :$!\n";
  while (my $line = <$fh>) {
    # ignore comment lines
    next if $line =~ m/^#/;
    # remove extra info
    $line =~ s/\s.*$//g;
    move_file($line, $output_dir);
  }
}

sub move_file {
  my ( $file, $output_dir ) = @_;
  if ( -e $file ) {
    my $final_dir = dirname(File::Spec->catfile($output_dir, $file));
    if (! -d $final_dir) {
      make_path($final_dir);
    }
    move($file, $final_dir);
  }
}

sub move_binaries {
  my $exe = '';
  if ( -e 'parrot.exe') {
    $exe = '.exe';
  }
  my @files = qw/parrot miniparrot ops2c parrot-nqp parrot_config parrot_debugger pbc_disassemble pbc_dump pbc_merge pbc_to_exe/;

  foreach my $file (@files) {
    move_file($file . $exe, $output_dir);
  }
}

# TODO
# use GetOpt
# accept flags for args to pass onto config script
# accept flags for what to make
# document more in POD
# combine reading line from manifest and moving it
# flags for copying tests
# check return value from system commands
