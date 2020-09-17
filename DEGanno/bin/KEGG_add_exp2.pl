#!/mnt/ilustre/centos7users/dna/.env/bin/perl -w
use strict;
use warnings;
use Carp;
use Bio::SearchIO;
use Getopt::Long;
use DBI qw(:sql_types);
use SOAP::Lite;
#use autodie;
use Try::Tiny;
use LWP::Simple;
use LWP::UserAgent;
use HTML::TreeBuilder;
#use URI::Escape;
use Math::Round qw(:all);
#use HTML::Template;
use HTML::Manipulator;
# use lib "/mnt/lustre/share/apps/annotation/PerlLib/";
#use PBS::Host;


my %opts;
my $VERSION="2.0";
GetOptions( \%opts,"i=s", "format=s","o=s","maxEvalue=f","minIdentity=i","log=f","org=s","fresh!","exp=s","exptype=s","rank=i","database=s","QminCoverage=i","HminCoverage=i","use_proxy!","proxy_server=s","server=i","parse_id!", "h!");

my $usage = <<"USAGE";
       Program : $0
       Version : $VERSION
       Contact : liubinxu
       Lastest modify:2015-1-9
       Discription:parse blast to genes databse result and get kegg pathway info and map
       				please install perl model: bioperl DBI DBD::SQLite SOAP::Lite autodie Try::Tiny
       Usage :perl $0 [options]
		-i*		blastn.out		blast to genes database output,can use wildcard character in bash,like '*_blast.out',but must use '' when using  wildcard character     
		-format		blastformat		the format of blast output
		kobas	kobas2 anntation file											 wise       Genewise -genesf format
		-exp		expressfile
		-line		
		
		-type	1|2
			1 only diffexpression gene
			2 gene with logFC > 1
		

		
		-o dir			output dir,defualt kegg_out under current dir                 
        -org organism		organism name of three letters ,list in http://www.genome.jp/kegg/catalog/org_list.html ,like hsa
        default:ko
        also can use:map
		
		-thre		1			
        -fresh					fresh database from network
                -database	database path		default:/home/db/kegg/kegg.db
                -use_proxy	whether use http proxy
		-proxy_server		http proxy server address default:http://101.168.10.1:8888/


                -h					Display this usage information
                * 					must be given Argument
                exmaple:perl $0 -i 'unfinish_*.out' -format blastxml -minIdentity 70
USAGE

die $usage if ((!$opts{i})||$opts{h});
$opts{format}=$opts{format}?$opts{format}:"kobas";
$opts{o}=$opts{o}?$opts{o}:"./kegg_out";
$opts{org}=$opts{org}?$opts{org}:"ko";
$opts{thre}=$opts{thre}?$opts{thre}:1;
#$opts{exptype}=$opts{exptype}?$opts{exptype}:"edgeR";
#$opts{database}=$opts{database}?$opts{database}:"/home/db/kegg/kegg.db";
unless($opts{database}){
	# if(-f "/state/partition1/kegg/kegg.db"){
		# $opts{database}="/state/partition1/kegg/kegg.db";
	#}else{
		$opts{database}="/mnt/ilustre/app/rna/database/kegg/kegg.new.db";
	# }
}

my $local_img_dir = "/mnt/ilustre/users/bingxu.liu/workspace/annotation/kegg";

$opts{proxy_server}=$opts{proxy_server}?$opts{proxy_server}:"http://101.168.10.1:8888/";

$opts{maxEvalue}=$opts{maxEvalue}?$opts{maxEvalue}:"1e-6";
$opts{minIdentity}=$opts{minIdentity}?$opts{minIdentity}:75;
$opts{HminCoverage}=$opts{HminCoverage}?$opts{HminCoverage}:30;
$opts{rank}=$opts{rank}?$opts{rank}:"10";
unless(-f $opts{database}){
	warn("Database not exists,Create new ...\n");
	$opts{fresh}=1;
}

my $ua =LWP::UserAgent->new();
$ua->timeout(20);
if($opts{use_proxy}){
        my $host=PBS::Host->new({hostname=>'101.168.10.80'});
        if($host->checkstat() eq 'alive'){
                $ua->proxy('http',$opts{proxy_server});
        }else{
                $ua->proxy('http',"http://101.168.10.81:8888/");
        }       
}



my $dbh = DBI->connect("dbi:SQLite:dbname=$opts{database}","","",{AutoCommit => 1});
my $check=$dbh->prepare("select count(*) from sqlite_master where type='table' and name='pathway_".$opts{org}."'");

$check->execute();
my @row_ary  = $check->fetchrow_array;
if ($row_ary[0]<=0){
	$opts{fresh}=1;
	warn("Local database has no info of this organism,getting from kegg network ...\n");
}

if($opts{format} eq 'kobas' && $opts{org} ne 'ko'){
	$check=$dbh->prepare("select count(*) from sqlite_master where type='table' and name='gene_pathway_".$opts{org}."'");

	$check->execute();
	my @row_ary  = $check->fetchrow_array;
	if ($row_ary[0]<=0){
		$opts{fresh}=1;
		warn("Local database has no info of this organism,getting from kegg network ...\n");
	}	
}

&freshdatabase($opts{org}) if($opts{fresh});

my %expression;
my %exp_label;
my %ko_exps;

open(EXP,"< $opts{exp}") || die "can not open $opts{exp}";
my $head=1;
while(<EXP>){
      chomp;
      my @line = split (/\t/,$_);
      my $add = $#line - 7;
      # if($opts{exptype} eq "cufflink"){
	      # $add = 1;
      # }
	  
      if($head == 1){
	      $head=0;
	      $exp_label{id}=$line[0];
	      #$exp_label{count1}=$line[1+$add];
	      #$exp_label{count2}=$line[2+$add];
	      $exp_label{fpkm1}=$line[1+$add];
	      $exp_label{fpkm2}=$line[2+$add];	      
      }else{
		if ($line[6+$add] eq "no"){
			next;
		}
	    #$expression{$line[0]}{count1} = $line[1+$add];
	    #$expression{$line[0]}{count2} = $line[2+$add];
	    $expression{$line[0]}{fpkm1} = $line[1+$add];
	    $expression{$line[0]}{fpkm2} = $line[2+$add];
	    $expression{$line[0]}{fc} = $line[3+$add];	
		
	    # print $expression{$line[0]}{fc}."\n";

      }      
}
close EXP;
my @file= glob $opts{i};
warn("Input blast result files:\n");
warn(join("\n",@file)."\n");
#my %hash;
my $pathway = &getpathways($opts{org});
my $kos =&getpathwaykos($opts{org});

my %seqkos;

mkdir("$opts{o}","493") or die "Can't create dir at $opts{o}\n" unless( -e $opts{o});
open(KEGG, "> $opts{o}/kegg_table.xls") || die "Can't open $opts{o}/kegg_table.xls\n";
unless($opts{format} eq 'kobas'){
	print KEGG "Queryname\tHitname\tHit_discription\tevalue\tScore\ttopHSP_strand\tMax_identity\tQuery_length\ttopHSP_Query_converage\tHit_length\tmaxHSP_Hit_coverage\tkos\tecs\tpathway\n";
	foreach my $f (@file){
		warn("Parsing blast result file $f ...\n");
		my $searchio= Bio::SearchIO->new(-format => $opts{format},
									 -file => $f,
									 -best => 1,
									);
		while(my $result = $searchio->next_result){
				my $algorithm=$result->algorithm();
				die "Only support blastp and blastx result!\n" unless($algorithm=~/blastx|blastp/i);
				my $query_name=$result->query_name;
				if($opts{parse_id}||$query_name=~/^Query_\d+$/){
					$query_name=$result->query_description;
					$query_name=~/^\s*(\S+)/;
					$query_name=$1;				
				}else{
					$query_name=$result->query_name;
					$query_name=~/^\s*(\S+)/;
					$query_name=$1;
				}
				my $query_length=$result->query_length;
	
				my @quiery_ko;
			while(my $hit = $result->next_hit){
				last if $hit->rank() > $opts{rank};
				my $hit_length=$hit->length();
				my $score=$hit->score();
				my @paths;
				my @kos;
				my @ecs;
				my $hsp= $hit->hsp; #Bio::Search::HSP::HSPI
				my ($query_hsp_length,$hit_hsp_length);
				
					$query_hsp_length=$hsp->length('qeury');
					$hit_hsp_length=$hsp->length('hit');
					#print "$query_name\t$b\n";
	
				my ($query_coverage,$hit_coverage);
				$query_coverage=$query_hsp_length/$query_length;
				$hit_coverage=$hit_hsp_length/$hit_length;
				if($opts{'QminCoverage'}){
					next if $query_coverage <$opts{'QminCoverage'}/100;
				}
				if($opts{'HminCoverage'}){
					next if $hit_coverage <$opts{'HminCoverage'}/100;
				}
				if($opts{'maxEvalue'}){
					last if $hsp->evalue > $opts{'maxEvalue'};
				}
				my $identity=nearest(.01, $hsp->frac_conserved('total')*100);
	
				
				if($opts{'minIdentity'}){
					last if $identity < $opts{'minIdentity'};
				}
				$identity=$identity."%";
				
				#$hash{$result->query_name}{des}=$hit->description;
				my $des=$hit->description;
				#$hash{$result->query_name}{evalue}=$hsp->evalue;
				my $evalue=$hsp->evalue;
				#$hash{$result->query_name}{hitname}=$hit->name;
				my $hitname=$hit->name;
				#$hash{$result->query_name}{strand}=$hit->strand("query")==1?"+":"-";
				my $strand;
				if($algorithm=~/blastx/i){
					$strand=$hit->strand("query")==1?"+":"-";
				}else{
					$strand=" ";
				}
				
				
				while($des =~ /\s+(K\d{4,6})\s+/g ){
					#$hash{$result->query_name}{ko}=$1;
					my $ko=$1;
					push(@kos,$ko);	
					#print "$ko\n";			
					if(exists($kos->{"ko:".$ko})){
						foreach my $p (keys(%{$kos->{"ko:".$ko}})){
							#print "$p\n";	
							push(@paths,$p);
							push(@{$pathway->{$p}{'kos'}},"ko:".$ko);
							push(@{$pathway->{$p}{'seqs'}},$query_name);					
						}
					}else{
						warn("warn:$ko is not in all pathways in this organism $opts{org},if your database is newest, this is ok ... \n");
					}
				}
				
				while($des =~ /[\[\(](EC:[\d\.\-\s\,]+)[\]\)]/g){
					#$hash{$result->query_name}{ec}=$1;
					my $ec=$1;
					push(@ecs,$ec);
				}
				my $paths_ref=&uniq(\@paths);
				my $kos_ref=&uniq(\@kos);
				my $ecs_ref=&uniq(\@ecs);
				push(@quiery_ko,@$kos_ref);
				#print $result->query_name."\t".$hit->name."\t".$hash{$result->query_name}{ko}."\t".$hash{$result->query_name}{ec}."\t".$hit->description."\t".$hash{$result->query_name}{strand}."\t".$hsp->strand('hit')."\t".$hsp->evalue."\n";
				print KEGG "$query_name\t$hitname\t$des\t$evalue\t$score\t$strand\t$identity\t$query_length\t".sprintf("%.2f",$query_coverage*100)."%"."\t$hit_length\t".sprintf("%.2f",$hit_coverage*100)."%"."\t".join(";",@$kos_ref)."\t".join(";",@$ecs_ref)."\t".join(";",@$paths_ref)."\n";
				#print "$query_name\t$hitname\t$des\t$evalue\t$strand\t$identity\t".join(";",@$kos_ref)."\t".join(";",@$ecs_ref)."\t".join(";",@$paths_ref)."\n";
						
			}
			$seqkos{$query_name}=&uniq(\@quiery_ko);
		}
	}
}else{
	print KEGG "#Query\tKo id(Gene id)\tKo name(Gene name)\thyperlink\tPaths\n";
	foreach my $f (@file){
		open ANNOT, "< $f" or die "Error:Cannot open file  $f : $! \n";
		my $line=<ANNOT>;
		my $kobas_specie="ko";
		if($line=~/^##Species:\s+(\w{2,4})\s+/){
				$kobas_specie=$1;
		}elsif($line=~/^##ko\tKEGG Orthology/){
			$kobas_specie="ko";
		}
		die "The  species in kobas file  $f is $kobas_specie but your input is  $opts{org} \n! " if($kobas_specie ne $opts{org});
		while(<ANNOT>){
			chomp;
			next if(/^\s*#/);
			last if(/^\/\/\/\//);
			if(/^(\S*)\s+(.*)$/){
				my $query_name=$1;
				my $annot=$2;
				next if $annot=~/^None/;	
				#print $annot."\n";			
				my @a=split(/\|/,$annot);				
				my $ko=$a[0];
				my $ko_abr = $a[1];		
				my @paths;
				
				my @kos=split /,\s/,$ko_abr; ###20160524
				$seqkos{$query_name}=\@kos;	###20160524			
				#if($ko eq "K10691"){
				#	my $test="true";
					
				#}
				if(exists $expression{$query_name}){					
					my $logfc;
					if ( exists $expression{$query_name}{fc} ){
						$logfc = $expression{$query_name}{fc};
					}else{
						$logfc = log(($expression{$query_name}{fpkm1}+0.1)/($expression{$query_name}{fpkm2}+0.1));
					}
					if ($logfc eq "noTest"){
						$logfc = 0 ;
					}
					if(abs($logfc) > 10**15 ){
						$logfc = sprintf("%e",$logfc);
					}else{
						$logfc = sprintf("%.2f",$logfc);
					}
					
					
					if($logfc>$opts{thre}){
						#push(@kos,$ko);	
						if(exists $ko_exps{$ko}{up} && $ko_exps{$ko}{up} ne ""){
							$ko_exps{$ko}{up} .= ", ".$query_name." \($logfc\) ";
						}else{
							$ko_exps{$ko}{up} = $query_name." \($logfc\) ";
						}
					}elsif($logfc<-$opts{thre}){
						#push(@kos,$ko);	
						if(exists $ko_exps{$ko}{down} && $ko_exps{$ko}{down} ne ""){
							$ko_exps{$ko}{down} .= ", ".$query_name." \($logfc\) ";
						}else{
							$ko_exps{$ko}{down} = $query_name." \($logfc\) ";
						}
					}				
					
								
				
				#print $ko."\n";				
				
					
					my $koid;
					if($opts{format} eq 'kobas' && $opts{org} ne 'ko'){
						$koid=$ko;
					}else{
						$koid="ko:".$ko;
					}
					if(! exists $ko_exps{$ko}){
						next;
					}
					
					if (exists $ko_exps{$ko}{up} || exists $ko_exps{$ko}{down}){
						if(exists($kos->{$koid})){
							foreach my $p (keys(%{$kos->{$koid}})){
								#print "$p\n";	
								push(@paths,$p);
								push(@{$pathway->{$p}{'kos'}},$koid);
								push(@{$pathway->{$p}{'seqs'}},$query_name);					
							}
						}else{
							warn("warn:$ko is not in all pathways in this organism $opts{org},if your database is newest, this is ok ... \n");
						}
						my $paths_ref=&uniq(\@paths);
						print KEGG "$query_name\t$a[0]\t$a[1]\t$a[2]\t".join(";",@$paths_ref)."\n";
						
					}
				}			
			}
		}
		close ANNOT;
	}
}
close KEGG;



open(PATHWATY,"> $opts{o}/pathway_table.xls" ) || die "Can't open $opts{o}/pathway_table.xls\n";
print PATHWATY "PathWay\tPathway_definition\tnumber_of_seqs\tseqs_kos_list\tpathway_imagename\n";
warn("outputing Pathway table ...\n");

foreach my $p (keys(%$pathway)){
	next unless exists($pathway->{$p}{'kos'});
	my $kolist=&uniq(\@{$pathway->{$p}{'kos'}});
	my $pathway_id = $p;
	$pathway_id =~ s/^path://ig;
		
	my $pathfile = "http://www.kegg.jp/pathway/$pathway_id";

	#my $pathfile=&MarkPathway($p,$kolist);
	#print $pathfile."\n";
	my $imgname=&getimgname($p);
	my $htmlfile=&getimgname1($p);	
	#$filepath="./".$filepath unless($filepath=~/^\//);
	warn("Geting pathway image from  $pathfile  ...\n");
	#getstore($pathfile,$filepath);
	&savekegg($pathfile,$imgname,$htmlfile);
	my $seqlist=&uniq(\@{$pathway->{$p}{'seqs'}});
	my $seq_ko_list;
	foreach my $n (@$seqlist){
		$seq_ko_list.=$n."(".join(",",@{$seqkos{$n}}).");";
	}
	print PATHWATY "$p\t".$pathway->{$p}{'definition'}."\t".scalar(@$seqlist)."\t".$seq_ko_list."\t".$imgname."\n";
}

# close KOEXP;

close PATHWATY;
warn("All done!\n");
sub savekegg(){
	my $url=shift;
	my $img_name=shift;
	my $html_name=shift;
	
	my $img_file = $local_img_dir."/ko/".$img_name;
	my $html_file = $local_img_dir."/ko/".$html_name;
	#print "****\n$html_file\n";
	
	local $/;
	open (INPUT,"< $html_file");
	my $html_content = <INPUT>;
	#print "*********\n".$html_content;
	close INPUT;
	

	my $html=&formathtml1($html_content,$img_file);
	open (HTML,"> $opts{o}/$html_name") or die "Can't create file $opts{o}/$html_name\n";
	print HTML  $html;
	close HTML;
}

sub formathtml1(){
	my $htm =shift;
	my $imgname=shift;
	
	my $path = $imgname;
	
	$path =~ s/.*\///ig;
	
	my $htm_result='<html>
<head>
<meta http-equiv="content-type" content="text/html; charset=utf-8">
<title>'.$path.'</title>
<style type="text/css">
<!--
area {cursor: pointer;}
-->
</style>
<script type="text/javascript">
<!--
function showInfo(info) {
	obj = document.getElementById("result");
	obj.innerHTML = "<div style='."\'cursor: pointer; position: absolute; right: 5px; color: #000;\' onclick=\'javascript: document.getElementById".'(\"result\").style.display = \"none\";'."\' title=\'close\'>X</div>".'" + info;
	obj.style.top = document.body.scrollTop;
	obj.style.left = document.body.scrollLeft;
	obj.style.display = "";
}
//-->
</script>
</head>
<body>
<map name="'.$path.'">
';

	my @line = split(/\n/,$htm);
	
	open M, "> $opts{o}/pic.m" or die "Error:Cannot open file $path.m : \n";
	print M "ko=imread(\'$imgname\');
ko_red=ko(:,:,1);
ko_green=ko(:,:,2);
ko_blue=ko(:,:,3);

";
	
	foreach(@line){
			if ($_ =~ /area\sshape=([^\t]*)\tcoords=([^\t]*)\thref=([^\?]*)\?([^\"]*)"\ttitle=\"([^\"]*)\"/ ){
			#print "***\ntest\n***";
			my $shape = $1;
			my $position = $2;
			my $hyperef = $3;
			my $kos =  $4;
			
			print "$shape $position $hyperef $kos\n";
		
	
			my @ko= split(/\+/,$kos);
			my @up_kos=();
			my @down_kos=();			
			foreach(@ko){
				my $clean_ko =$_;
				#$clean_ko =~ s/\s.*//ig;
				#if($opts{org} ne "ko"){
				#	$clean_ko = $opts{org}.":".$clean_ko;
				#}
				if(exists $ko_exps{$clean_ko}{up}){
					my $html_ko = "<li>$clean_ko: $ko_exps{$clean_ko}{up}</li>";
					push(@up_kos,$html_ko);
				}
				if(exists $ko_exps{$clean_ko}{down}){
					my $html_ko = "<li>$clean_ko: $ko_exps{$clean_ko}{down}</li>";
					push(@down_kos,$html_ko);
				}
			}
			if (@up_kos || @down_kos){	
				my $line_area = "<area shape=\'$shape\' coords=\'$position\' onmouseover=\'javascript: showInfo(\"<ul>";
				if(@up_kos){
					$line_area .= '<li style=\"color: #f00;\">Up regulated<ul>'.join("",@up_kos).'</ul></li>';
				}
				if(@down_kos){
					$line_area .= '<li style=\"color: #0f0;\">Down regulated<ul>'.join("",@down_kos).'</ul></li>';
				}		
				$line_area .= "</ul>\");\' />";
				$htm_result.= $line_area."\n";		
			}
			
			if($shape ne "rect"){
				next;
			}
			
			my @pos=split(/,/,$position);
			my $co = 0;
			foreach(@pos){
				$pos[$co] += 1;
				$co +=1;
			}
			
			
			
			if(@up_kos && @down_kos){
				print M "for i\=$pos[1]:$pos[1]+1
for j\=$pos[0]:$pos[2]
ko_red(i,j)\=255; ko_green(i,j)\=0; ko_blue(i,j)\=0;
end
end

for i\=$pos[3]-1:$pos[3]
for j\=$pos[0]:$pos[2]
ko_red(i,j)\=0; ko_green(i,j)\=255; ko_blue(i,j)\=0;
end
end


for j\= $pos[0]:$pos[0]+1
for i\= $pos[1]:floor(($pos[3]+$pos[1])/2)
ko_red(i,j)\=255; ko_green(i,j)\=0; ko_blue(i,j)\=0;
end
for i\= floor(($pos[3]+$pos[1])/2):$pos[3]
ko_red(i,j)\=0; ko_green(i,j)\=255; ko_blue(i,j)\=0;
end
end


for j\= $pos[2]-1:$pos[2]
for i\= $pos[1]:floor(($pos[3]+$pos[1])/2)
ko_red(i,j)\=255; ko_green(i,j)\=0; ko_blue(i,j)\=0;
end
for i\= floor(($pos[3]+$pos[1])/2):$pos[3]
ko_red(i,j)\=0; ko_green(i,j)\=255; ko_blue(i,j)\=0;
end
end
";				
				
			}elsif(@up_kos){
				print M "for i\=$pos[1]:$pos[1]+1
for j\=$pos[0]:$pos[2]
ko_red(i,j)\=255; ko_green(i,j)\=0; ko_blue(i,j)\=0;
end
end

for i\=$pos[3]-1:$pos[3]
for j\=$pos[0]:$pos[2]
ko_red(i,j)\=255; ko_green(i,j)\=0; ko_blue(i,j)\=0;
end
end

for i\= $pos[1]:$pos[3]
for j\= $pos[0]:$pos[0]+1
ko_red(i,j)\=255; ko_green(i,j)\=0; ko_blue(i,j)\=0;
end
end

for i\= $pos[1]:$pos[3]
for j\= $pos[2]-1:$pos[2]
ko_red(i,j)\=255; ko_green(i,j)\=0; ko_blue(i,j)\=0;
end
end
";
				
			}elsif(@down_kos){
				print M "for i\=$pos[1]:$pos[1]+1
for j\=$pos[0]:$pos[2]
ko_red(i,j)\=0; ko_green(i,j)\=255; ko_blue(i,j)\=0;
end
end

for i\=$pos[3]-1:$pos[3]
for j\=$pos[0]:$pos[2]
ko_red(i,j)\=0; ko_green(i,j)\=255; ko_blue(i,j)\=0;
end
end

for i\= $pos[1]:$pos[3]
for j\= $pos[0]:$pos[0]+1
ko_red(i,j)\=0; ko_green(i,j)\=255; ko_blue(i,j)\=0;
end
end

for i\= $pos[1]:$pos[3]
for j\= $pos[2]-1:$pos[2]
ko_red(i,j)\=0; ko_green(i,j)\=255; ko_blue(i,j)\=0;
end
end
";
			
			}
			
		}
		
	}
	
	print M "ko_new=cat(3,ko_red,ko_green,ko_blue);
imwrite(ko_new, \'$opts{o}/$path\', \'png\');
";
	close M;
	
	system("/mnt/ilustre/app/rna/bin/matlab -nojvm -nodisplay <$opts{o}/pic.m 2>>err.log");
	#system("rm $opts{o}/$path.m");
	
	$htm_result.= "</map>
<img src=\'./$path\' usemap=\'#$path\' />
<div id=\'result\' style=\'position: absolute; width: 50%; border: 1px solid #000; background-color: #fff; filter: alpha(opacity=95); opacity: 0.95; font-size: 12px; padding-right: 20px; display: none;\' onmouseover=".'"javascript: this.style.filter = '."\'alpha(opacity=100)\'; this.style.opacity = 1;".'" onmouseout="javascript: this.style.filter ='."\'alpha(opacity=95)\'; this.style.opacity = 0.95;".'"'."></div>
</body></html>";
	
	# $htm =~ s/<img src\=\".*\" usemap\=\"#mapdata\" border\=\"0\" \/>/<img src\=\"$imgname\" usemap\=\"#mapdata\" border\=\"0\" \/>/g;
	# $htm =~ s///g;
	return $htm_result;
}

sub formathtml(){
	my($htm)=@_;
	$htm =~ s/\"\//\"http\:\/\/www.kegg.jp\//g;
	$htm =~ s/\'\//\'http\:\/\/www.kegg.jp\//g;
	return $htm;
}

sub getimgname(){
	my $path=shift;
	my @a=split(":",$path);
	return $a[1].".png";
}

sub getimgname1(){
	my $path=shift;
	my @a=split(":",$path);
	return $a[1].".html";
}

sub MarkPathway(){
	my $pathway_id = shift;
	my $list=shift;		
	#$list = SOAP::Data->type();
	#my $fg_list  = ['#ff0000'];
	#my $bg_list  = ['#ffff00'];
	
	$pathway_id =~ s/path://g ;
	
	my $color_result = "http://www.kegg.jp/kegg-bin/show_pathway?";
	$color_result .= $pathway_id;	
	
	
	#my $result = "http://rest.kegg.jp/";	
	#$result .= "get/";	
	#$result .= $pathway_id;
	foreach(@$list){
	  my $ko= $_;
	  $ko =~ s/ko://;	  
	  $color_result .='/'.$_.$ko_exps{$ko}{color};    
	}
	if (length ($color_result) > 4096){
	   $color_result = "http://www.kegg.jp/kegg-bin/show_pathway?".$pathway_id;
	}
	   #$color_result .= "/kgml"
	
	return $color_result;
	
	
	#$result .= "/kgml";
	
	
	
	
	
 	
#        try{
#		if($opts{server}==1){
#			 $result= $serv->get_html_of_marked_pathway_by_objects($pathway_id,$list);
#		}else{
#			 $result= $serv->KeggGetHtmlOfMarkedPathwayByObjects($pathway_id,$list);
#		}
#
#		if($result){
#			return $result;
#		}else{
#			warn("Server return error,retrying getting $pathway_id ...\n");
#			undef $serv;
#			$service= &serverref();
#			&MarkPathway($pathway_id,$list,$service);
#		}
#	}catch{
#		warn("Server connection serious error:$_,retrying getting $pathway_id ...\n");
#		$service= &serverref();
#		&MarkPathway($pathway_id,$list,$service);
#	}	
}

sub getpathways(){
	my $org=shift;
	my $pw=$dbh->prepare(<<SQL
select class,definition from pathway_$org;
SQL
			  );
	$pw->execute();
	my $ref = $pw->fetchall_hashref('class');
	$pw->finish;
	return $ref;
}

sub getpathwaykos(){
	my $org=shift;
	my %kolist;
	my $mm;
	if($opts{format} eq 'kobas' && $opts{org} ne 'ko'){
		$mm=$dbh->prepare(<<SQL
	select * from gene_pathway_$org;
SQL
			  );
	}else{
		$mm=$dbh->prepare(<<SQL
	select * from ko_pathway_$org;
SQL
			  );
	}
	
	$mm->execute();
	my $ref = $mm->fetchall_hashref('id');
	foreach my $ids ( keys(%$ref) ) {
			#push(@{$list->{$ref->{$id}->{'ko'}}},$ref->{$id}->{'pathway'});
			#print $ref->{$ids}->{'ko'}."\t".$ref->{$ids}->{'pathway'}." $ids\n";
			my $k=$ref->{$ids}->{'ko'};
			my $p=$ref->{$ids}->{'pathway'};
			$kolist{$k}{$p}=1;
	}
	$mm->finish;
	return \%kolist;
}


sub freshdatabase(){
	my $org=shift;
	warn("Freshing database from kegg netwok,please wating ...\n");
	$dbh->do(<<SQL
	drop table if exists pathway_$org;
SQL
 		 );
	$dbh->do(<<SQL
		 CREATE TABLE  pathway_$org( 
 			 id  INTEGER PRIMARY KEY ASC, 
			 class  varchar(50) NOT NULL,
			 definition	 varchar(10) NOT NULL
		 );
SQL
 );
 	$dbh->do(<<SQL
	CREATE INDEX IF NOT EXISTS i_pathway_$org\_class ON pathway_$org(class);
SQL
 		 );
 	my $insert;
    if($opts{format} eq 'kobas' && $opts{org} ne 'ko'){
    	$dbh->do(<<SQL
	drop table if exists gene_pathway_$org;
SQL
 		 );
 	$dbh->do(<<SQL
	 CREATE TABLE gene_pathway_$org( 
 			 id  INTEGER PRIMARY KEY ASC, 
			 pathway  varchar(50) NOT NULL,
			 ko	varchar(10) NOT NULL
	);
SQL
 		 );	 
	 $dbh->do(<<SQL
	 CREATE INDEX IF NOT EXISTS i_gene_pathway_$org ON gene_pathway_$org(pathway);
SQL
 		 );	
    }else{
    	  	$dbh->do(<<SQL
	drop table if exists ko_pathway_$org;
SQL
 		 );
 	$dbh->do(<<SQL
	 CREATE TABLE ko_pathway_$org( 
 			 id  INTEGER PRIMARY KEY ASC, 
			 pathway  varchar(50) NOT NULL,
			 ko	varchar(10) NOT NULL
	);
SQL
 		 );	 
	 $dbh->do(<<SQL
	 CREATE INDEX IF NOT EXISTS i_ko_pathway_$org ON ko_pathway_$org(pathway);
SQL
 		 );		 
		
		 
 	#$dbh->commit;
 
    }
 		$insert = $dbh->prepare(<<SQL
INSERT INTO pathway_$org(class,definition) VALUES (?,?);
SQL
);
	warn("getting pathway list ....\n");
 	my $pathway=&listpathways($org);
 	foreach my $p (@$pathway){
 		my $n=$p->{'entry_id'};
 		my $m=$p->{'definition'};
 		#print "$n $m \n";
 		$insert->execute($n,$m);
 	}
	#$dbh->commit;
	if($opts{format} eq 'kobas' && $opts{org} ne 'ko'){
		$insert = $dbh->prepare(<<SQL
INSERT INTO gene_pathway_$org(pathway,ko) VALUES (?,?);
SQL
); 
	}else{
		$insert = $dbh->prepare(<<SQL
INSERT INTO ko_pathway_$org(pathway,ko) VALUES (?,?);
SQL
); 
	}
	
	warn("getting kos list for each pathway ....\n");
	
	foreach my $p (@$pathway){
		warn("getting kos list for $p->{'entry_id'} ....\n");		
 		my $kos=&listkos($p->{'entry_id'});
 		foreach my $x (@$kos){
 			$insert->execute($p->{'entry_id'},$x);	
 		}
 	}
 	#undef $service;
 	#$dbh->commit;
}


#########################################
#list all pathways for organism
sub listpathways(){
    my $organism = shift;
	try{
		my $response=$ua->get("http://rest.kegg.jp/list/pathway/$organism");
		if($response->is_success){
			my $result=$response->decoded_content;
			my @lines=split(/\n+/,$result);
			my @a;
			foreach(@lines){
				if(/^(.+)\t+(.*)$/){
					my %h=('entry_id'=>$1,'definition'=>$2);
					push(@a,\%h);
				}
			}
			return \@a;
		}else{
			warn "Server response error:".$response->status_line."\n";
			warn("Server return error,retrying getting $organism ...\n");
			return &listpathways($organism);
		}
	}catch{		
		warn("Server connection serious error:$_,retrying getting $organism ...\n");
		return &listpathways($organism);
	}	
}

#####
#get all kos for a pathway
sub listkos(){
	my $pathway_id=shift;

	my $response;
        try{
		if($opts{org} =~ /^ko$|^map$/i){
			$response=$ua->get("http://rest.kegg.jp/link/ko/$pathway_id");
		
		}else{
			$response=$ua->get("http://rest.kegg.jp/link/genes/$pathway_id");
		}
		
		if($response->is_success){
				my $result=$response->decoded_content;
				my @lines=split(/\n+/,$result);
				my @a;
				foreach(@lines){
					if(/^(.+)\t+(.*)$/){
						push(@a,$2);
					}
				}
				return \@a;
		}else{
				warn "Server response error:".$response->status_line."\n";
				warn("Server return error,retrying  getting $pathway_id...\n");
				return &listkos($pathway_id);
		}		
	}catch{
		warn("Server connection serious error:$_,retrying  getting $pathway_id...\n");
		return &listkos($pathway_id);
    }
}

sub uniq {
	my $array      = shift;
	my %hash       = map { $_ => 1 } @$array;
	my @uniq_array = sort( keys %hash );
	return \@uniq_array;
}

