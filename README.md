#Overview
GoldMine is a bioinformatics pipeline for identifying the genomic origin of FASTQ reads.  The tool uses [Velvet](https://www.ebi.ac.uk/~zerbino/velvet/) to assemble FASTQ reads into contigs, which are then subsequently mapped to a range of reference genomes using [Blast](https://blast.ncbi.nlm.nih.gov/Blast.cgi).


#Intended Use
GoldMine should be used when the genomic origin of a sample is unknown and cannot be reasonably guessed.  This problem is typically encountered when a large proportion of reads do not map to expected (or anticipated) reference genomes and, consequently, the source of the putative contamination needs to be identified.


#When GoldMine should not be used
Successfully creating contigs is only possible for small (e.g. bacterial) genomes.  GoldMine will not therefore identify reads derived from large (e.g. human) genomes.  We recommend using FastQ Screen, however, to validate the origin of reads from a pre-specified panel of anticipated reference genomes. 


#Output
GoldMine writes the assembled contigs and Blast results to a folder named [input filename].contigs.  The software produces a graph showing the distribution of %GC content vs coverage for the contigs.  In general, contigs from different genomic sources should cluster together on this plot. 

The script also generates a summary report listing a candidate source or sources of origin of the FASTQ Reads.  GoldMine generates the summary score by processing each mapped contig in turn.  For each contig, the tool extracts the alignments with the lowest Blast E values.  If those alignments are derived from a single species, the GoldMine score of that species is incremented by 1.  The summary file shows the results of processing all the mapped contigs.  


#Installation
Before running GoldMine there are a few pre-requisites that will need to be installed:

1. We recommend running GoldMine on a Linux system, in which the programming language Perl should already be installed.

2. Install the Perl module HTTP::Request::Common.  Ensure that your computer can access the internet since GoldMine performs online Blast searches.

3. Install a recent version of [R](https://www.r-project.org), if not already installed by default.  Add 'R' to your path.

4. Install [Velvet](https://www.ebi.ac.uk/~zerbino/velvet) and add 'velveth' to your path.

5. Actually installing GoldMine is very simple. Download the tar.gz distribution file and then do:

  `tar xvzf goldmine_v0.x.x.tar.gz`

 You will see a folder called goldmine_v0.x.x has been created and the program executable file 'goldmine' is inside that. You can add the program to your path either by linking the program into: usr/local/bin or by adding the program installation directory to your search path.


#Running the program
To confirm GoldMine functions correctly on your system please download the [Test Dataset](https://www.bioinformatics.babraham.ac.uk/projects/goldmine/goldmine_test_dataset.tar.gz). The file 'goldmine_test_dataset.fastq.gz' contains reads in Sanger FASTQ format.

1. Extract the tar archive before processing:  
   `tar xvzf goldmine_test_dataset.tar.gz`

2. Run GoldMine:

 `goldmine goldmine_test_dataset.fastq.gz`

 The expected GoldMine summary results have been included in the Test Dataset tar archive.

Full documentation for the GoldMine options can be obtained by running:

`goldmine --help`


#Availability
[Git Repository](https://github.com/StevenWingett/GoldMine.git)

[Homepage](https://stevenwingett.github.io/GoldMine)

GoldMine is distributed with a GNU General Public License (version 3).  

Steven Wingett, The Babraham Institute, Cambridge, UK
