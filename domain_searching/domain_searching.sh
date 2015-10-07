#!/bin/bash
#$ -l hostname="n13*"

# 1) move into a directory to work in
cd /home/pt40963/nucleotide_binding/cDNS_files

#make one nt fasta with all nt seq in it
cat *.fa > all_nt.fasta
 
#convert the nt fasta file into amino acids

# 2) to use this script -i IN.fasta -o out_translated.fasta 
python translate_sequences.py -i all_nt.fasta -o all_pep.fasta

#make a directory for the amino acid work. Keep this separte to the nt work
mkdir amino_acid_file


#move this file
mv all_pep.fasta ./amino_acid_file

#move into this directory
cd amino_acid_file

# 3) use hmmsearch to identify any domains of interest. Hmm has to be in your path, or give it the full path to the binaries. 
# usage:
#hmmsearch --cut_ga (gathering threshold) --domain table out (we need it formatted like this) out_file_name   pfam_definition  in  amino_acid_file
hmmsearch --cut_ga --domtblout p.ensembl.20150928_vs_SBP.hmm.out SBP.hmm all_pep.fasta

####################################################################################################################################################################################################################
# 4) extract the domains from the sequences, using the table generated by hmmsearch
python get_DOMAIN_region_i_want_from_fasta_amino_acid.py -i all_pep.fasta --hmm p.ensembl.20150928_vs_SBP.hmm.out -o p.ensembl.20150928_vs_SBP.hmm.DOMAIN_ONLY_only.fasta


# 5) Aligned with muscle. - download the binary, your path will not be the same as mine!
/home/pt40963/Downloads/muscle3.8.31_i86linux64 -in p.ensembl.20150928_vs_SBP.hmm.DOMAIN_ONLY_only.fasta -out p.ensembl.20150928_vs_SBP.hmm.DOMAIN_ONLY_only.aligned

/home/pt40963/Downloads/muscle3.8.31_i86linux64 -in p.ensembl.20150928_vs_SBP.hmm.DOMAIN_ONLY_only.aligned -out p.ensembl.20150928_vs_SBP.hmm.DOMAIN_ONLY_only.aligned.refined.fasta -refine

#5b) can align back to the hmm profile used, e.g. SBP.hmm

# Usage: hmmalign [-options] <hmmfile> <seqfile>

hmmalign SBP.hmm p.ensembl.20150928_vs_SBP.hmm.DOMAIN_ONLY_only.fasta -o p.ensembl.20150928_vs_SBP.hmm.DOMAIN_ONLY_only.stockholm

# 5c) convert that stockholme file to fasta - use the file 

python convert_stock_to_fasta.py 

####################################################################################################################################################################################################################
#6) now we need to get the nt seq of the domains to back translate those onto the AA alignment


python /home/pt40963/misc_python/sequence_manipulation/domain_searching/get_DOMAIN_region_I_want_from_fasta_Nucleotide.py -i ../all_nt.fasta --hmm p.ensembl.20150928_vs_SBP.hmm.out -o test_nt.out

#6b) remove those smaller domains sequences that will alter the aligmnet - this can be done at the AA or nt part of method:
# -l is min length of seq allowed to be printed out the the file. 

python /home/pt40963/misc_python/sequence_manipulation/domain_searching/rewrite_as_fasta.py -i test.out -l 70 -o test_min_len70.out



####################################################################################################################################################################################################################
#7) back translate the nt domain seq on the aligned proteins sequences

# 
python Align_back_translate_Aug2014.py


