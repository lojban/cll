#!/usr/bin/perl

local $/=undef;
my $string = <STDIN>;
close STDIN;

$string =~ s{<programlisting\s*[^>]*>([^<]+)</programlisting>}{
#print "1: $1\n";

my $matched=0;
my $crap='';
foreach my $line (split /\n/, $1) {
$line =~ s{^\s+}{};
$line =~ s{\s+$}{};
if( $line =~ m{^.+\s\s\s\s+\S+.*\s\s\s\s+.+$} ) {
$matched=1;
my $newline = $line;
$newline =~ s{^(.+\S+)\s\s\s\s+(\S+)\s\s\s\s+(.+)$}{<cmavo-entry><cmavo>\1</cmavo><selmaho>\2</selmaho><description>\3</description></cmavo-entry>};
$crap .= $newline;
};
};
if( $matched ) {
"<cmavo-list>\n".
"$crap\n".
"</cmavo-list>\n";
} else {
$&;
}
}egs;

print $string;
