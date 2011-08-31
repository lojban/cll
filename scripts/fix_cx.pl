while(<>) {

#  s{,}{:}g;
#  s{ \(quick-tour version\)}{: quick-tour version}g;
#  s{\(}{}g;
#  s{\)}{}g;
  my $orig=$_;

  if( m{<([cle]x) "([^>]*)">\s+XE\s+"([^"]*)"(.*)} ) {
    my $type=$1;
    my $first=$2; my $second = $3;
    my $rest=$4;
    if( $first ne $second ) {
      use String::Diff;
      my $diff=String::Diff::diff_merge($first, $second,
        remove_open => '<del>',
        remove_close => '</del>',
        append_open => '<ins>',
        append_close => '</ins>',
      );

      $diff =~ s{<del>,</del><ins>:</ins>}{:}g;
      $diff =~ s{<del>,</del><ins>s:</ins>}{s:}g;
      $diff =~ s{<ins>:</ins> <del>\(</del>quick-tour version<del>\)</del>}{: quick-tour version}g;
      $diff =~ s{<ins>,</ins> <del>\(</del>quick-tour version<del>\)</del>}{: quick-tour version}g;
      $diff =~ s{<ins>, example</ins>}{: example}g;
      $diff =~ s{<ins>: example</ins>}{: example}g;
      $diff =~ s{<ins>e, exampl</ins>}{e: exampl}g;
      $diff =~ s{<ins>le, examp</ins>}{le: examp}g;
      $diff =~ s{<del>\.</del>}{.}g;
      $diff =~ s{<del>"</del>}{&quot;}g;
      $diff =~ s{<del>”</del>}{&quot;}g;
      $diff =~ s{<del>s,</del><ins>:</ins>}{s:}g;
      $diff =~ s{<del>ing,</del><ins>s:</ins>}{s:}g;
      $diff =~ s{<del>es,</del><ins>:</ins>}{es:}g;
      $diff =~ s{<del>,</del><ins> of</ins>}{ of}g;
      $diff =~ s{<del>,</del><ins> abstraction:</ins>}{ abstraction:}g;
      $diff =~ s{<ins>: English word</ins>}{: English word}g;
      $diff =~ s{<del>,</del><ins>\(s\):</ins>}{s:}g;
      $diff =~ s{<del>,</del><ins>\(s\):</ins>}{s:}g;
      $diff =~ s{<del>,</del> selma'o<del> catalog</del>}{: selma'o catalog}g;
      $diff =~ s{<del>, selma'o catalog</del>}{: selma'o catalog}g;
      $diff =~ s{<del>,</del> <ins>selma'o: </ins>terminator for<del>, selma'o catalog</del>}{ selma'o: terminator for: selma'o catalog}g;
      $diff =~ s{<del>,</del> <ins>selma'o: </ins>terminator for: selma'o catalog}{ selma'o: terminator for: selma'o catalog}g;
      $diff =~ s{<del>s</del>}{s}g;
      $diff =~ s{<del>,</del><ins>\(s\):</ins>}{s:}g;
      $diff =~ s{<del>,</del><ins> selma'o:</ins>}{ selma'o:}g;

      my $diff2 = $diff;
      $diff2 =~ s{<ins>:</ins>}{:}g;
      if( $diff2 !~ m{<ins>} && $diff2 !~ m{<del>} ) {
        $diff = $diff2;
      }

      my $diff2 = $diff;
      $diff2 =~ s{<ins>s:</ins>}{s:}g;
      if( $diff2 !~ m{<ins>} && $diff2 !~ m{<del>} ) {
        $diff = $diff2;
      }

      if( $diff =~ m{<ins>} || $diff =~ m{<del>} ) {
#    print "diff: $diff\n";
        print qq{<$type "$first"> XE "$second"\n$rest\n};
      } else {
        print qq{<$type "$diff"> XE "$diff"\n$rest\n};
      }
    } else {
      print qq{<$type "$first"> XE "$second"\n$rest\n};
    }
  } else {
    print;
  }
}
