#!/usr/bin/perl -w
use strict;
use warnings;
my $BEGIN_TIME=time();
use Getopt::Long;
my ($fin,$fout,$anno);
use Data::Dumper;
use FindBin qw($Bin $Script);
use File::Basename qw(basename dirname);
my $version="1.0.0";
GetOptions(
	"help|?" =>\&USAGE,
	"int:s"=>\$fin,
	"anno:s"=>\$anno,
	"out:s"=>\$fout,
			) or &USAGE;
&USAGE unless ($fout);
open In,$fin;
my %genid;
while (<In>) {
	chomp;
	next if (/symbol/);
	my ($d6,$d7)=split/\s+/,$_,2;
	$genid{$d6}=1;
}
close In;
open AN,$anno;
my %stat;
my @idss;
while (<AN>) {
	chomp;
	if (/GENE/){
		my ($id,$type,$idsss)=split/\s+/,$_,3;
		@idss=split/\s+/,$idsss;	
		#print $id,$type,"\n";
		#print $idss[1];die;
	}
	my ($id,$type,$samples)=split/\s+/,$_,3;
	my @samples=split/\s+/,$samples;
	
	#@print Dumper @samples;die;
	#print Dumper $samples[0];die;
	for (my $i=0; $i<@samples ;$i++) {
		if ((exists $genid{$id}) && ($samples[$i] > 0) && ($type eq "snp")) {
			$stat{$id}{$idss[$i]}{snp}++;
			print "$id\t$type\n";
		}elsif((exists $genid{$id}) && ($samples[$i] > 0) && ($type eq "indel")){
			$stat{$id}{$idss[$i]}{indel}++;
			print "$id\t$type\n";
		}elsif((exists $genid{$id}) && ($samples[$i] eq 0) && ($type eq "snp")){
			$stat{$id}{$idss[$i]}{snp}+=0;
			print "$id\t$type\n";
		}elsif((exists $genid{$id}) && ($samples[$i] eq 0) && ($type eq "indel")){
			$stat{$id}{$idss[$i]}{indel}+=0;
			print "$id\t$type\n";
		}else{
			next;
			#$stat{$id}{$idss[$i]}{snp}="NA";
			#$stat{$id}{$idss[$i]}{indel}="NA";
		}
	}
}
close AN;
#print Dumper \%stat;die;
open Out1,">$fout/snp.result";
open Out2,">$fout/indel.result";
#my (,@out2,$sams);
foreach my $ids (sort keys %stat) {
	#print $ids;
	my (@out1,@out2);
	foreach my $sams (sort keys %{$stat{$ids}}) {
		#print $sams;die;
		#push @out1,join("\t",$sams);
		push @out1,join("\t",$stat{$ids}{$sams}{snp});
		push @out2,join("\t",$stat{$ids}{$sams}{indel});
	}
	#print Dumper @out1;die;
	print Out1 join("\t",$ids,@out1),"\n";
	print Out2 join("\t",$ids,@out1),"\n";
}
close Out;
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

	eg: perl perl.model.pl -int gene.tpm.used.xls -anno snp_annotation_statistics.xls -out result
	

Usage:
  Options:
	"int:s"=>\$fin,
	"anno:s"=>\$anno,
	"out:s"=>\$fout,
	-h         Help

USAGE
        print $usage;
        exit;
}
