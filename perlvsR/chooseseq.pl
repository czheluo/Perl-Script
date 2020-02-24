#!/usr/bin/perl -w
use strict;
use warnings;
use Carp;
use Getopt::Long;
my %opts;
my $VERSION="1.0";
GetOptions( \%opts,"v!","h!");
if(@ARGV < 2 || $opts{h}) {
    print STDERR "chooseseq.pl <ref.fa> <DE.list>\n";
    print STDERR "chooseseq.pl -v <fasta> <list>\n";
    exit;
}

my $fas = shift;
my $list = shift;
my %id;
my %fas;

open (FAS, "<$fas") or die;
my $name = "";
while(<FAS>) {
    chomp;
    if(/^>(\S*)/) {
	$name = $1;	
	$id{$name} = $_;
	$fas{$name} = "";
    } else {
		if($name ne "") {
	   	 $fas{$name} .= $_."\n";
		}
    }
}
close(FAS);

open (LIST, "<$list") or die;
my %list;
while(<LIST>) {
    chomp;
	$list{$_}=1;
	my $s = $_;
	if(exists($fas{$s})){
			print "$id{$s}\n";
			print "$fas{$s}";
	}else{
	}
} 
close LIST;
