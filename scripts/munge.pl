#!/usr/bin/perl

my $filename=$ARGV[0];

my $chapter=$ARGV[1];

my $section=$ARGV[2];

if( ! $filename || ! $chapter || ! $section ) {
  print "bad usage\n";
  exit 1;
}

open my $fh, '<', $ARGV[0] or die "error opening $filename: $!";
my $data = do { local $/ = undef; <$fh> };

$data =~ s{<body>.*?<hr />}{<body>}sg;
$data =~ s{<hr />.*?</body>}{</body>}sg;

$data =~ s!<a id="e([^"]*)">([^<]*)</a>!<a id="c${chapter}e${section}d$1"></a><a id="cll_chapter$chapter-section$section-example$1"></a>$2!sg;
$data =~ s{<a href="../([^/]*)/#e([^"]*)">}{<a href="chapter$chapter-section$1-example$2">}sg;

$data =~ s!<a id="y([^"]*)">([^<]*)</a>!<a id="y$1"></a><a id="cll_yacc-$1"></a>$2!sg;
$data =~ s{<a href="(../[0-9]+/)?#y([^"]*)">}{<a href="yacc-$2">}sg;

$data =~ s!<a id="b([^"]*)">([^<]*)</a>!<a id="b$1"></a><a id="cll_bnf-$1"></a>$2!sg;
$data =~ s{<a href="(../[0-9]+/)?#b([^"]*)">}{<a href="bnf-$2">}sg;

$data =~ s{<a href="../([^/]+)/">}{<a href="chapter$chapter-section$1">}sg;
$data =~ s{<a href="../([^/]+)/([^/]+)/?">}{<a href="chapter$1-section$2">}sg;

$data =~ s{<h4 id="([^"]*)">}{<h4><a id="$1"></a>}sg;

$data =~ s{<h2>.*?</h2>}{}sg;
$data =~ s{<a href="../../([0-9]+)/1/">}{<a href="chapter$1">}sg;

print $data;
