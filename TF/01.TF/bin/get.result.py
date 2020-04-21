#!/usr/bin/env python
# -*- coding: utf-8 -*-
import argparse
import os
import sys

parser = argparse.ArgumentParser(description="qu can")
parser.add_argument( '--g2t',required=False, help='ref_genome.gtf.gene2transcript.txt')
parser.add_argument( '--tmp',required=True, help='the file end of tmp ')
parser.add_argument( '--detail',required=True, help='ouput file fasta')
parser.add_argument( '--family',required=True, help='ouput file fasta')
parser.add_argument( '--Species',required=False, help='ouput file fasta')
args = parser.parse_args()

def getfamily(listgoat):
    listgoat = listgoat.strip().split("\t")
    des = str(listgoat[2])
    faml = des.strip().split("|")[1]
    geneid = str(listgoat[0])
    dic2.setdefault(faml,[]).append(geneid)


dic2 = {}
#dic2.setdefault(key,[]).append(value)
#dic.setdefault('a',[]).append(2)
#gou zao zi dian
#dic.setdefault(key,{})[value] =1
dic1 = {}
if args.g2t:
    with open(args.g2t) as g2t:
        for line in g2t:
            lines = line.strip().split("\t")
            dic1[lines[1]] = lines[0]

with open(args.tmp) as tmp,open(args.detail,"w") as det,open(args.family,"w") as fam:
    det.write("Query-Name\tHit-Name\tHIt-Description\tE-Value\tScore\tIdentical\tSimilar\t"\
                 "Match_Length\tQuery_Length\tQuery_start\tQuery_End\tHit_Length\tHit_start\tHit_End\n")
    fam.write("family\tnum\tgene\n")
    if not args.Species:
        for line in tmp:
            if "Query-Name" not in line:
                lines = line.strip().split("\t")
                goatgene = str(lines[0])
                listgoat = [goatgene,]
                listgoat.extend(lines[1:-3])
                listline = "\t".join(listgoat)+"\n"
                getfamily(listline)
                det.write(str(listline))
        for i in dic2.keys():
            len_num = len(dic2[i])
            gene_list = ";".join(dic2[i])
            pyprint = str(i)+"\t"+str(len_num)+"\t"+gene_list+"\n"
            fam.write(pyprint)
    else:
        for line in tmp:
            if "Query-Name" not in line:
                if args.Species in line:
                    lines = line.strip().split("\t")
                    goatgene = str(lines[0])
                    listgoat = [goatgene,]
                    listgoat.extend(lines[1:-3])
                    listline = "\t".join(listgoat)+"\n"
                    getfamily(listline)
                    det.write(str(listline))
        for i in dic2.keys():
            len_num = len(dic2[i])
            gene_list = ";".join(dic2[i])
            pyprint = str(i)+"\t"+str(len_num)+"\t"+gene_list+"\n"
            fam.write(pyprint)







