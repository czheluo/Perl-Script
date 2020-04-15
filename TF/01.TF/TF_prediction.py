#!/bin/env python
# -*- coding: utf-8 -*-
#__author__ = 'zhenyu.lu'
#__time__ = '2019/7/19'
from multiprocessing import Pool
import argparse
import subprocess
import os

parser = argparse.ArgumentParser()
parser.add_argument('-fa', required=True, help='ref_genome.gtf.exon.fa for plant and ...')
parser.add_argument('-kind', required=True, help='plant or annimal')
parser.add_argument('-g2t', required=True, help='ref_genome.gtf.gene2transcript.txt')
parser.add_argument('-species', required=False, help='Species')
args = parser.parse_args()

fa = os.path.abspath(args.fa)
g2t = os.path.abspath(args.g2t)
workpath = os.getcwd()

plantdb = "/mnt/ilustre/centos7users/meng.luo/Pipeline/RNA/Pipeline/TF/db/PlantTFDB-all_TF_pep.fas"

annimaldb = "/mnt/ilustre/centos7users/meng.luo/Pipeline/RNA/Pipeline/TF/db/all_64_species_transcription_factors.fasta"

def split(fa):
    job1 = 'python /mnt/ilustre/centos7users/meng.luo/Pipeline/RNA/Pipeline/TF/bin/split_fa.py -i {fa} -n 2000 -o osplit'.format(fa=fa)
    subprocess.call(job1,shell=True)

def getxls(argslist):
    db,n=argslist
    if not os.path.exists("split{n}.fa".format(n=n)):
        os.makedirs("split{n}.fa".format(n=n))
    os.chdir("split{n}.fa".format(n=n))
    
    job1= 'perl //mnt/ilustre/centos7users/meng.luo/Pipeline/RNA/Pipeline/TF/bin/run_blast.pl -r '\
          ' {db}  -i ../osplit{n}.fa -rt pro -it dna -o unigene_vs_PlantTFDB-all_TF.{n}.xls'.format(n=n,db = db)
    subprocess.call(job1,shell=True)
    os.chdir(workpath)

def getfile1(g2t):
    job2 = 'python /mnt/ilustre/centos7users/meng.luo/Pipeline/RNA/Pipeline/TF/bin/get.result.py  --g2t {g2t} '\
            '--tmp unigene_vs_PlantTFDB-all_TF.1.xls.detail.xls  --detail detail.xls --family  family.xls'.format(g2t=g2t)
    subprocess.call(job2,shell=True)

def getfile2(g2t,species):
    job2 = 'python /mnt/ilustre/centos7users/meng.luo/Pipeline/RNA/Pipeline/TF/bin/get.result.py  --g2t {g2t} '\
            '--tmp unigene_vs_PlantTFDB-all_TF.1.xls.detail.xls --detail detail.xls --family  family.xls --Species "{species}"'.format(g2t=g2t,species=species)
    subprocess.call(job2,shell=True)

split(fa)

listall = "".join(os.listdir(os.getcwd()))
countor = listall.count("osplit")
print countor
if args.kind=="plant":
    db = plantdb
elif args.kind=="annimal":
    db = annimaldb

argslist=[]
for i in range(countor):
    argslist.append((db,i+1))

print argslist

if args.kind=="plant":
    pool=Pool(countor)
    pool.map(getxls,argslist)
    pool.close()
    subprocess.call("cat */unigene_vs_PlantTFDB-all_TF.*.xls.detail.xls > unigene_vs_PlantTFDB-all_TF.1.xls.detail.xls ",shell=True)
        subprocess.call("perl /mnt/ilustre/centos7users/meng.luo/Pipeline/RNA/Pipeline/TF/bin/get.TF.fa.pl -int gene.fa -tf detail.xls -out TF.fa  ",shell=True)
	if args.species:
        species = args.species
        getfile2(g2t,species)
    else: 
        getfile1(g2t)

if args.kind=="annimal":
    pool=Pool(countor)
    pool.map(getxls,argslist)
    pool.close()
    subprocess.call("cat */unigene_vs_PlantTFDB-all_TF.*.xls.detail.xls > unigene_vs_PlantTFDB-all_TF.1.xls.detail.xls ",shell=True)
	if args.species:
        species = args.species
        getfile2(g2t,species)
    else:
        getfile1(g2t)





