#!/usr/bin/perl

use strict;
use warnings;

use IO::File;

# THIS SCRIPT IS CRAZY.  You almost certainly don't want or need to
# be running it.  See README-conversion for what it does.

$|=1;

my $skip=$ARGV[0] ? $ARGV[0] : 0;
print "skip chapters: $skip\n";

sub crunchstring {
  my ( $string ) = @_;


  print "string before: $string\n";

# Clean out old index bits
    $string =~ s{<!-- ^^ [^>]*? -->}{}g;
    $string =~ s{<indexterm type="general">.*?</indexterm>}{}g;
    $string =~ s{<pre>.*?</pre>}{}g;
    $string =~ s{<dt>[a-z']+:\s+<dd>}{}g;
    $string =~ s{\s*<xref linkend="[^"]*" />}{}g;
    $string =~ s{\s*<a href=[^>]*>\s*(Section|Chapter|Examples?)?\s*[0-9.]+</a>}{}g;
    $string =~ s{\s*<a href=[^>]*>\s*(Section|Chapter|Examples?)?\s*[0-9.]+}{}g;
    $string =~ s{</a>}{}g;
    
    $string =~ s{[0-9]+\.[0-9]+\).*}{}g;

  print "string after 1: $string\n";


      # Clean out the cx/XE bits
      foreach my $cx ($string =~ m{<[cle]x\s+"([^>]*)">}g) {
        my $cx_regex=$cx;
#        $cx_regex =~ s{[,:]}{.}g;
#        $cx_regex =~ s{ \(quick-tour version\)}{...?quick-tour version.?}g;
        $cx_regex =~ s{\(}{.}g;
        $cx_regex =~ s{\)}{.}g;
        $cx_regex =~ s{\+}{.}g;
        $cx_regex =~ s{\^}{.}g;
        $cx_regex =~ s{\&}{.}g;
#        $cx_regex =~ s{"}{.*?}g;
#        $cx_regex =~ s{”}{.*?}g;
        print "cx_regex: $cx_regex\n";
        #print "cx_regex string: $string\n";
        $string =~ s{<[cle]x\s+"$cx_regex">\s+XE\s+"$cx_regex"}{}g;
      }

#      # Clean out the ex/XE bits
#      foreach my $ex ($string =~ m{<ex\s+"([^>]*)">}g) {
#        my $ex_regex1=$ex;
#        $ex_regex1 =~ s{[,:]}{.}g;
#        my $ex_regex2="$ex: example";
#        $ex_regex2 =~ s{[,:]}{.}g;
#        print "ex_regex1: $ex_regex1\n";
#        print "ex_regex2: $ex_regex2\n";
#        $string =~ s{<ex\s+"$ex_regex1">\s+XE\s+"$ex_regex2"\s+}{}g;
#      }


    $string =~ s{\&amp;}{\&}g;
    $string =~ s{"}{}g;
    $string =~ s{'}{}g;
    $string =~ s{\[.{1,4}\]}{}g;
    $string =~ s{<[^>]*>}{}g;
    $string =~ s{Examples [0-9?]+.[0-9?]+ through [0-9?]+.[0-9?]+}{Example X through Example Y}g;
    $string =~ s{Examples [0-9?]+.[0-9?]+ and [0-9?]+.[0-9?]+}{Example X and Example Y}g;
    $string =~ s{Example [0-9?]+.[0-9?]+}{Example X}g;
    $string =~ s{[^[:ascii:]]}{}g;
    $string =~ s{^\s*[0-9.]+[a-z]?\)\s*}{}g;
    $string =~ s{\s+}{ }g;
    $string =~ s{^\s+}{}g;
    $string =~ s{\s+$}{}g;

  print "string after: $string\n";

    return $string;
}
my $cdcontent;

open my $fh, "<", "orig/catdoc.out.indexing" or die $!;
{
  local $/; # enable localized slurp mode
  $cdcontent = <$fh>;
}
close $fh;

$cdcontent =~ s{<p>(.*?)(?=<p>)}{my $foo = $1; $foo =~ s(\n)()g; "<p>$foo</p>\n";}esg;

my $chapfh;
my $chapcontent;
my $chapter=0;
my $para=0;
my $chapline='';
my $chapcontline;
my $cdline;
my $chapoutfh;
my $lastchaplinenum=0;

$cdline = $cdcontent;
$cdline =~ s{\n.*}{}s;

#while( <$catdoc> ) {
while( 1 ) {
  #print "cdline: $cdline\n";

  if( $cdline =~ m{<h2>} ) {
    if( $chapfh ) {
      while( <$chapfh> ) {
        $chapline=$_;
        if( $chapfh && $lastchaplinenum != $chapfh->input_line_number() ) {
          print $chapoutfh $chapline;
          print "outputing chapline: $chapline";
          $lastchaplinenum = $chapfh->input_line_number();
        }
      }
    }

    if( $chapfh ) { close $chapfh; }
    if( $chapoutfh ) { close $chapoutfh; }

    $para=0;
    $chapter++;

    if( $chapter == 21 ) {
      print "Chapter 21 reached; stopping.\n";
      exit 0;
    }

    $skip--;
    goto ADVANCE if( $skip gt 0 );

    print "opening $chapter.xml\n";
    open $fh, "<", "$chapter.xml" or die $!;
    {
      local $/; # enable localized slurp mode
      $chapcontent = <$fh>;
    }
    close $fh;

    $chapcontent =~ s{<para>(.*?)</para>}{my $foo = $1; $foo =~ s(\n)()g; "<para>$foo</para>\n";}esg;

    $chapfh = IO::File->new( "$chapter.xml", "r" ) or die $!;

    $lastchaplinenum=0;

    open $chapoutfh, ">", "$chapter.xml.new" or die $!;
  }

  goto ADVANCE if( $skip gt 0 );

  if( $cdline =~ m{<p>} && $cdline !~ m{<h[0-9]>} ) {

    my $cdshort = crunchstring( $cdline );

    goto ADVANCE if( $cdshort =~ m{^\s*$} && $cdline !~ m{<[cel]x} );


    #print "cdshort: $cdshort\n";

    my $chapshort;
    my $chapcontshort;

    use Text::LevenshteinXS qw(distance);

    my $ratio=0;

    while( 1 ) {
      if( $chapcontent !~ m{\n}s ) {
        last;
      }

      $chapcontent =~ s{^[^\n]*\n}{}s;

      $chapcontline = $chapcontent;
      $chapcontline =~ s{\n.*}{}s;

      print "testing chapcontline: $chapcontline\n";
      if( $chapcontline =~ m{<para>} ) {
        while( <$chapfh> ) {
          $chapline = $_;
          #print "chapline: $chapline\n";
          if( m{<para>} ) {
            last;
          } else {
            if( $chapfh && $lastchaplinenum != $chapfh->input_line_number() ) {
              print $chapoutfh $chapline;
              print "outputing chapline: $chapline";
              $lastchaplinenum = $chapfh->input_line_number();
            }
          }
        }

        #print "new chapcontline: $chapcontline\n";

        #print "new chapline: $chapline\n";

        $chapshort = crunchstring( $chapline );

        $chapcontshort = crunchstring( $chapcontline );
      } else {
        next;
      }

      my $dist=distance( $chapcontshort, $cdshort );
      my $length=( ( length $chapcontshort ) + ( length $cdshort ) );
      $ratio=($dist / $length);
      if( $ratio < 0.04 ) {
        print "------------- cdshort for distance:\n      cd: $cdshort\n------------- chapcontshort for distance:\n      ch: $chapcontshort\n";
        print "distance: $dist ; length: $length ; ratio: $ratio -- SUCCEEDED\n";
        last;
      } else {
        print "------------- cdshort for distance:\n      cd: $cdshort\n------------- chapcontshort for distance:\n      ch: $chapcontshort\n";
        print "distance: $dist ; length: $length ; ratio: $ratio -- FAILED\n";
      }

      if( $chapfh && $lastchaplinenum != $chapfh->input_line_number() ) {
        print $chapoutfh $chapline;
        print "outputing chapline: $chapline";
        $lastchaplinenum = $chapfh->input_line_number();
      }
    }

    if( $ratio > 0.04 ) {
      print "No match found for the following strings; bailing.\n";
      print "------------- cdshort for distance:\n      $cdshort\n------------- chapcontshort for distance:\n      $chapcontshort\n";
      exit 1;
    }

    #print "------------- cdline: $cdline\n------------- chapline: $chapline\n------------- chapcontline: $chapcontline\n";
#goto ADVANCE;

#FIXME: TODO: also output example titles for future processing; see "Clean out the ex/XE bits" above
    foreach my $cx ($cdline =~ m{<cx\s+"([^"]*)">}g) {
      print "cx: $cx\n";
      my $indexterm=qq{<indexterm type="general">};
      my $type='primary';

      foreach my $cxpart (split( /\s*[:,]\s*/, $cx, 3 ) ) {
        $indexterm .= qq{<$type>$cxpart</$type>};
        if( $type eq 'secondary' ) {
          $type='tertiary';
        }
        if( $type eq 'primary' ) {
          $type='secondary';
        }
      }
      $indexterm .= qq{</indexterm>};
      $chapline =~ s{<para>}{<para> $indexterm };

      print "new chapline: $chapline";
    }
    foreach my $ex ($cdline =~ m{<ex\s+"([^"]*)">}g) {
      print "ex: $ex\n";
      my $indexterm=qq{<indexterm type="example-imported">};
      my $type='primary';

      foreach my $expart (split( /\s*[:,]\s*/, $ex, 3 ) ) {
        $indexterm .= qq{<$type>$expart</$type>};
        if( $type eq 'secondary' ) {
          $type='tertiary';
        }
        if( $type eq 'primary' ) {
          $type='secondary';
        }
      }
      $indexterm .= qq{</indexterm>};
      $chapline =~ s{<para>}{<para> $indexterm };

      print "new chapline: $chapline";
    }
    foreach my $lx ($cdline =~ m{<lx\s+"([^"]*)">}g) {
      print "lx: $lx\n";
      my $indexterm=qq{<indexterm type="lojban-word">};
      my $type='primary';

      foreach my $lxpart (split( /\s*[:,]\s*/, $lx, 3 ) ) {
        $indexterm .= qq{<$type>$lxpart</$type>};
        if( $type eq 'secondary' ) {
          $type='tertiary';
        }
        if( $type eq 'primary' ) {
          $type='secondary';
        }
      }
      $indexterm .= qq{</indexterm>};
      $chapline =~ s{<para>}{<para> $indexterm };

      print "new chapline: $chapline";
    }
  }

  ADVANCE:

  if( $chapfh && $lastchaplinenum != $chapfh->input_line_number ) {
    print $chapoutfh $chapline;
    print "outputing chapline: $chapline";
    $lastchaplinenum = $chapfh->input_line_number;
  }

  $cdcontent =~ s{^[^\n]*\n}{}s;

  $cdline = $cdcontent;
  $cdline =~ s{\n.*}{}s;

}
