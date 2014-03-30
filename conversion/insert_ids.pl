#!/usr/bin/perl

use strict;
use warnings;

my $filein=$ARGV[0];
my $fileout=$ARGV[1];
my $num=$ARGV[2];

open( my $fhin, '<', $filein ) or die $!;
open( my $fhout, '>', $fileout ) or die $!;
open( my $rands, '<', 'scripts/random-ids' ) or die $!;

my $randnum=0;

my $rand;

while( 1 ) {
  $rand = <$rands>;
  chomp($rand);
  if( $randnum == $num ) {
    last;
  }
  $randnum++;
}

while(<$fhin>)
{
  while( m{RANDOM} ) {
    s/RANDOM/$rand/;
    $rand = <$rands>;
    chomp($rand);
    $randnum++;
  }

  print $fhout $_;
}

print $randnum;
