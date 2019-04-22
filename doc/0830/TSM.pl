
#!/usr/bin/perl -w
use strict;
use warnings;
my $BEGIN_TIME=time();
use Getopt::Long;
my ($fin,$fout,$min);
use Data::Dumper;
use FindBin qw($Bin $Script);
use File::Basename qw(basename dirname);
my $version="1.0.0";
GetOptions(
	"help|?" =>\&USAGE,
	"i:s"=>\$fin,
	"o:s"=>\$fout,
	"m:s"=>\$min,
			) or &USAGE;
&USAGE unless ($fout);

open IN,$fin;
open OUT,">$fout";
while (<IN>) {
	chomp;
	next if ($_ =~ /#/);
	my ($pri,@seq)=split(/\,/,$_);
	
	print OUT " $pri\n @seq\n";
}

close IN;
close OUT;

#######################################################################################
print STDOUT "\nDone. Total elapsed time : ",time()-$BEGIN_TIME,"s\n";
#######################################################################################
sub USAGE {#
        my $usage=<<"USAGE";
Contact:        meng.luo\@majorbio.com;
Script:			$Script
Description:
	fq thanslate to fa format
	eg:
	perl $Script -i -o -k -c

Usage:
  Options:
	"i:s"=>\$fin,                                                                                                                                                                        
    "o:s"=>\$fout,
	"m:s"=>\$min,
  -h         Help

USAGE
        print $usage;
        exit;
}
