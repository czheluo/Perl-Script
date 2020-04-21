#! /usr/bin/perl -w
use strict;
use warnings;
use Carp;
use FindBin;
use List::Util qw/sum/;
use lib ("/data/users/liubinxu/workspace");

use Getopt::Long;
my %opts;
my $VERSION="1.0";
GetOptions( \%opts,"r=s","i=s","rt=s","it=s","o=s","sort=s","anno=s","e=s","cpu=i","h!");

my $usage = <<"USAGE";
       Program : $0
       Version : $VERSION
       Contact:
       Lastest modify:2011-11-22
       Discription:parse gmap output (defualt format) and output table admin gtf file 
       Usage :perl $0 [options]
                -r		ref_fasta            refrence file |fasta format ,always the result of Trinity
                -i		target_file
		-rt		refrence type		     pro|dna		  
		-it		input file type		     pro|dna
		-o		output file
		-sort		sort line		     cov_hit|cov_query
		-e		evlue 			     default 1e-5
		-cpu		10
#		-cov_genes	expression file gene expression file
#		-cov_trans	expression file isoforms expression file
#               -min_cov	min coverage	bewteen 0~1 
#		-read_lens	the illumina read length 
#		-read_type	pair or single
                -h                              Display this usage information
                
                
USAGE



die $usage if ( !( $opts{r} && $opts{i} && $opts{rt} && $opts{it} ) || $opts{h} );

my $ref = $opts{r};
my $input = $opts{i};

my $out = $opts{o}?$opts{o}:"blast.result.xls";
my $cpu = $opts{cpu}?$opts{cpu}:10;

my $BIN_DIR="$FindBin::RealBin";
my $sort = $opts{sort}?$opts{sort}:"cov_hit";
my $e_value = $opts{e}?$opts{e}:"1e-5";




# foreach (keys(%trans_lengths)){
	# print $_."\t".$trans_lengths{$_}."\n";
# }

#open (GENE, $opts{cov_genes}) or die "Error: Couldn't open $opts{cov_genes}\n";
my %gene_cov;
my @sample_name;
my $cmd;

if ( (-e $ref.".phr") && (-e $ref.".pin") && ( -e $ref.".psq" ) ){
	
}else{
	
	if ($opts{rt} eq "pro"){
		$cmd = "perl $BIN_DIR/fasta_change.pl $ref ref.fa ; formatdb -p T -i ref.fa";
	}elsif($opts{rt} eq "dna"){
		$cmd = " perl $BIN_DIR/fasta_change.pl $ref ref.fa ; formatdb -p F -i ref.fa";
	}else{
		die "fasta type $opts{rt} wrong !\n"
	}
	$ref = "ref.fa";
	&process_cmd($cmd);
}
$cmd = " perl $BIN_DIR/fasta_change.pl $input query.fa";
&process_cmd($cmd);
$input = "query.fa";

if( $opts{rt} eq "pro" && $opts{it} eq "pro"){
	$cmd = "blastall -p blastp -d $ref -i $input -F 'm s' -o $out -e $e_value -v 20 -b 20 -a $cpu";	
}elsif( $opts{rt} eq "pro" && $opts{it} eq "dna" ){
	$cmd = "blastall -p blastx -d $ref -i $input -F 'm s' -o $out -e $e_value -v 20 -b 20 -a $cpu";
}elsif( $opts{rt} eq "dna" && $opts{it} eq "dna" ){
	$cmd = "blastall -p blastn -d $ref -i $input -F 'm s' -o $out -e $e_value -v 20 -b 20 -a $cpu";
}elsif( $opts{rt} eq "dna" && $opts{it} eq "pro"){
	$cmd = "blastall -p tblastn -d $ref -i $input -F 'm s' -o $out -e $e_value -v 20 -b 20 -a $cpu";
}

&process_cmd($cmd);

$cmd = " perl $BIN_DIR/Blast2table -format 10 -expect 1E-5 -top $out > $out.temp";

&process_cmd($cmd);

open (TEMP, "<$out.temp") or die "cannot open $out.temp !\n";
open(RESULT,">$out.xls") or die "cannot open $out.xls !\n";
open(RESULT_DE,">$out.detail.xls") or die "annot open $out.detail.xls !\n";

print RESULT "Query-Name\tHit-Name\tHit-Description\tE-Value\tIdentical\tSimilar\tQuery_Coverage\tHit_Coverage\tFlag\n";
print RESULT_DE "Query-Name\tHit-Name\tHIt-Description\tE-Value\tScore\tIdentical\tSimilar\tMatch_Length\tQuery_Length\tQuery_start\tQuery_End\tHit_Length\tHit_start\tHit_End\tQuery_Frame\tHit_Frame\tFlag\n";

close RESULT;
close RESULT_DE;

open (TEMP_RESULT, ">result.temp") or die "cannot open result.temp !\n";
open (TEMP_RESULT_DE, ">result_de.temp") or die "cannot open result_de.temp !\n";
while(<TEMP>){
	chomp;
	my @arr=split/\t/;
	my $flag=$arr[8]<$arr[9]? "+":"-";
	my $cov_query;
	my $cov_hit;
	if($arr[8]<$arr[9]){
		$cov_query = substr(100*($arr[9]-$arr[8]+1)/$arr[7], 0, 5);
	}else{
		$cov_query = substr(100*($arr[8]-$arr[9]+1)/$arr[7], 0, 5);
	}
	$cov_hit = substr(100*($arr[14]-$arr[13]+1)/$arr[12], 0, 5);
	
	print TEMP_RESULT $arr[5]."\t".$arr[11]."\t".$arr[16]."\t".$arr[1]."\t".$arr[3]."\t".$arr[4]."\t".$cov_query."%\t".$cov_hit."%\t".$flag."\n"; 
	print TEMP_RESULT_DE $arr[5]."\t".$arr[11]."\t".$arr[16]."\t".$arr[1]."\t".$arr[0]."\t".$arr[3]."\t".$arr[4]."\t".$arr[2]."\t".$arr[7]."\t".$arr[8]."\t".$arr[9]."\t".$arr[12]."\t".$arr[13]."\t".$arr[14]."\t".$arr[10]."\t".$arr[15]."\t".$flag."\n";
	
}
close TEMP_RESULT;
close TEMP_RESULT_DE;

if($sort eq "cov_query"){
	$cmd = "cat result.temp |sort -n -r -k 7 >> $out.xls;
	cat result_de.temp >> $out.detail.xls"	;
	&process_cmd($cmd);
}else{
	$cmd = "cat result.temp |sort -n -r -k 8 >> $out.xls;
	cat result_de.temp >> $out.detail.xls" ;
	&process_cmd($cmd);	
}



sub process_cmd {
    my ($cmd) = @_;
    print "CMD: $cmd\n";
    my $ret = system($cmd);
    if ($ret) {
        die "Error, cmd: $cmd died with ret ($ret) ";
    }
    return;
}
