#!/usr/bin/perl -w
use strict;
use warnings;
my $BEGIN_TIME=time();
use Getopt::Long;
my ($fin,$fout,$fa,$genus,$rr,$asv);
use Data::Dumper;
use FindBin qw($Bin $Script);
use File::Basename qw(basename dirname);
my $version="1.0.0";
GetOptions(
	"help|?" =>\&USAGE,
	"int:s"=>\$fin,
	"r:s"=>\$rr,
	"asv:s"=>\$asv,
	"family:s"=>\$fa,
	"genus:s"=>\$genus,
	"out:s"=>\$fout,
			) or &USAGE;
&USAGE unless ($fout);
$fin=ABSOLUTE_DIR($fin);
open FA,$fa;
my %mfs;
while (<FA>) {
	chomp;
	next if($_ =~ "modules");
	my ($mo,$fam,$r,$p)=split/\t/,$_;
	#next if($r<0.29);
	next if($p>0.01);
	my $mf=join("-",$mo,$fam);
	$mfs{$mf}=join("\t",$r,$p);
}
close FA;
open GE,$genus;
my %mgs;
while (<GE>) {
	chomp;
	next if($_ =~ "modules");
	my($mo,$ge,$r,$p)=split/\t/,$_;
	#next if($r<0.29);
	next if($p>0.01);
	my $mg=join("-",$mo,$ge);
	$mgs{$mg}=join("\t",$r,$p);
}
close GE;
open In,$asv;
my $files=join("","pair_R_pvalue.reult",$rr,".xls");
open Out,">$fout/$files";
my %mods;
while (<In>) {
	chomp;
	next if($_ =~ "modules");
	my($module,$asv,$r,$p,$fa,$gen)=split/\t/,$_;
	#my($module,$asv,$r,$alls)=split/\s/,$_,3;
	#$alls =~ s/\r//g;
	#print $alls;die;
	next if(abs($r)<$rr);
	#next if($p>0.01);
	next if($p =~ "NA");
	#print $p;die;
	$gen=~s/\r//g;
	my $mf=join("-",$module,$fa);
	my $mg=join("-",$module,$gen);
	#$mods{$module}{$asv}=join("\t",$r,$p,$fa,$gen);
	if (exists $mfs{$mf} && !exists $mgs{$mg}) {
		print Out "$module\t$asv\t$r\t$p\t$fa\t$mfs{$mf}\t$gen\tNA\tNA\n";
	}elsif(!exists $mfs{$mf} && exists $mgs{$mg}){
		print Out "$module\t$asv\t$r\t$p\t$fa\tNA\tNA\t$gen\t $mgs{$mg}\n";	
	}elsif(exists $mfs{$mf} && exists $mgs{$mg}){
		print Out "$module\t$asv\t$r\t$p\t$fa\t$mfs{$mf}\t$gen\t $mgs{$mg}\n";	
	}else{
		print Out "$module\t$asv\t$r\t$p\t$fa\tNA\tNA\t$gen\tNA\tNA\n";
	}
	#$mods{$module}{$asv}=$alls;
}
close Out;
close In;
open AS,"<$fout/$files";
my %mods;
while (<AS>) {
	chomp;
	my($module,$asv,$alls)=split/\t/,$_,3;
	$module=~s/ME//g;
	#print $module;die;
	$mods{$module}{$asv}=$alls;
}
close AS;
#print Dumper %mods;die;
my $fil=join("","pair.result",$rr,".xls");
open OUT,">$fout/$fil";
print OUT "modules\tASV\tr\tp\tfamily\tr\tp\tgenus\tr\tp\tGO\tdescription\tp_bonferroni\ttype\tgenes\tgene numbers\tRich factor\n";
my @files=glob("$fin/*.xls");
foreach my $file (@files) {
	my $fna=basename($file);
	my ($mod,undef)=split/\./,$fna,2;
	open IN,"<$fin/$fna";
	while (<IN>) {
		chomp;
		#next if($_ =~ "id");
		#print $_;#die;
		my @all=split/\t/,$_;
		next if($all[0] eq "id");
		#print "$all[6]\n";#die;
		next if($all[6]>0.01);
		#print "$mod\n";
		foreach my $modu (sort keys %mods){
			if (exists $mods{$mod}) {
				foreach my $asvs (sort keys %{$mods{$modu}}){
					my @rs=split/\//,$all[3];
					my @rp=split/\//,$all[4];
					my $rf=$rs[0]/$rp[0];
					print OUT "$mod\t$asvs\t$mods{$modu}{$asvs}\t$all[0]\t$all[2]\t$all[6]\t$all[7]\t$all[8]\t$rs[0]\t$rf\n";
				}
			}
		}
	}
	close IN;
}
close OUT;

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

	eg:perl $Script -family pair_R_pvalue.family.xls -genus pair_R_pvalue.genus.xls -asv pair_R_pvalue.ASV.txt  -out ./ -int GO/ -r 0.1
	
Usage:
  Options:
	-int input file name
	-out output file name 
	-h         Help

USAGE
        print $usage;
        exit;
}
