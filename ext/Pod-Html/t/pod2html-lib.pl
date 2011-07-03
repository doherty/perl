require Cwd;
require Pod::Html;
require Config;
use File::Spec::Functions  ':ALL';

sub convert_n_test {
    my($podfile, $testname, @p2h_args) = @_;

    my $cwd = Cwd::cwd();
    my ($vol, $dir) = splitpath($cwd, 1);
    my $relcwd = substr($dir, length(File::Spec->rootdir()));
	
    my $new_dir  = catdir $cwd, "t";
    my $infile   = catfile $new_dir, "$podfile.pod";
    my $outfile  = catfile $new_dir, "$podfile.html";
    
    # To add/modify args to p2h, use @p2h_args
    Pod::Html::pod2html(
        "--infile=$infile",
        "--outfile=$outfile",
        "--podpath=t",
        "--htmlroot=/",
        "--podroot=".catpath($vol,$cwd,''),
        @p2h_args,
    );


    my ($expect, $result);
    {
	local $/;
	# expected
	$expect = <DATA>;
	$expect =~ s/\[PERLADMIN\]/$Config::Config{perladmin}/;
	$expect =~ s/\[RELCURRENTWORKINGDIRECTORY\]/$relcwd/g;
	if (ord("A") == 193) { # EBCDIC.
	    $expect =~ s/item_mat_3c_21_3e/item_mat_4c_5a_6e/;
	}

	# result
	open my $in, $outfile or die "cannot open $outfile: $!";
	$result = <$in>;
	close $in;
    }

    ok($expect eq $result, $testname) or do {
    	warn "\nExpected:\n$expect\n\nResult:\n$result\n\n";
    };

    # pod2html creates these
    1 while unlink $outfile;
}

1;
