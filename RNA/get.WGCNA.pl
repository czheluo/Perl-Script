#!/usr/bin/perl -w
use strict;
use warnings;
my $BEGIN_TIME=time();
use Getopt::Long;
my ($fin,$node,$edge,$fout);
use Data::Dumper;
use FindBin qw($Bin $Script);
use File::Basename qw(basename dirname);
my $version="1.0.0";
GetOptions(
	"help|?" =>\&USAGE,
	"int:s"=>\$fin,
	"node:s"=>\$node,
	"edge:s"=>\$edge,
	"out:s"=>\$fout,
			) or &USAGE;
&USAGE unless ($fout);
open NO,$node;
my %ids;
while (<NO>) {
	chomp;
	next if(/^id/);
	my($id,undef,undef,undef,undef,$modeul,undef)=split/\s+/,$_;
	push @{$ids{$modeul}},join("\n",$id);
}
close NO;
#print Dumper  %ids;die;
foreach my $chr (sort keys %ids) {
	open Out,">$fout/$chr.list";
	print Out join("\n",@{$ids{$chr}}),"\n";
	close Out;
}


#######################################################################################
print STDOUT "\nDone. Total elapsed time : ",time()-$BEGIN_TIME,"s\n";
#######################################################################################
sub ABSOLUTE_DIR #$pavfile=&ABSOLUTE_DIR($pavfile);
{
	my $cur_dir=`pwd`;chomp($cur_dir);
	my ($in)=@_;
	my $return="";
	if(-f $in){
		my $dir=dirname($in);
		my $file=basename($in);
		chdir $dir;$dir=`pwd`;chomp $dir;
		$return="$dir/$file";
	}elsif(-d $in){
		chdir $in;$return=`pwd`;chomp $return;
	}else{
		warn "Warning just for file and dir \n$in";
		exit;
	}
	chdir $cur_dir;
	return $return;
}
sub USAGE {#
        my $usage=<<"USAGE";
Contact:        meng.luo\@majorbio.com;
Script:			$Script
Description:

	eg: perl -int filename -out filename 
	
Usage:
  Options:
	"int:s"=>\$fin,
	"node:s"=>\$node,
	"edge:s"=>\$edge,
	"out:s"=>\$fout,
	-h         Help

USAGE
        print $usage;
        exit;
}
