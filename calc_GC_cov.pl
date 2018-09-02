#!/usr/bin/perl

###################################################################################
###################################################################################
##This file is Copyright (C) 2018, Steven Wingett (steven.wingett@babraham.ac.uk)##
##                                                                               ##
##                                                                               ##
##This file is part of GoldMine.                                                 ##
##                                                                               ##
##GoldMine is free software: you can redistribute it and/or modify               ##
##it under the terms of the GNU General Public License as published by           ##
##the Free Software Foundation, either version 3 of the License, or              ##
##(at your option) any later version.                                            ##
##                                                                               ##
##GoldMine is distributed in the hope that it will be useful,                    ##
##but WITHOUT ANY WARRANTY; without even the implied warranty of                 ##
##MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the                  ##
##GNU General Public License for more details.                                   ##
##                                                                               ##
##You should have received a copy of the GNU General Public License              ##
##along with GoldMine.  If not, see <http://www.gnu.org/licenses/>.              ##
###################################################################################
###################################################################################

####################################################################
#Perl Script to calculate the coverage (number of times occurring)
#and GC content of FASTA contigs (created by Velvet)
#Also creates a contig file to be used by Blast
####################################################################

use strict;
use warnings;

use Data::Dumper;

print "Determining coverage and GC content of contigs...\n";

unless(@ARGV){
	die "Please specify file(s) to process.\n";
}

foreach my $file (@ARGV){

		print "Processing $file\n";

		open(IN, '<', $file) or die "Could not open $file : $!";
		my %contigs;    #%{contig_sequence} = coverage
		my $sequence = '';
		my $coverage;
		
		while(<IN>){
			my $line = $_;
			chomp $line;

			if( substr($line, 0, 1) eq '>' ){    #Header line for FASTQ read
				if($sequence ne ''){
					$contigs{$sequence} = $coverage unless($sequence eq '');    #$sequence will be '' if first FASTA sequence
					$sequence = '';    #Reset
				}
				$coverage = ( split(/_cov_/, $line) )[-1];
			}else{
				$sequence .= $line;
			}	
		}
		$contigs{$sequence} = $coverage;    #Add last sequence

		close IN or die "Could not close filehandle 'IN' on '$file' : $!";

		#Report coverage and GC content of output and create contigs for blast
		my $outfile = "$file.cov_gc.txt";
		open( COV_GC, '>', $outfile) or die "Could not write to $outfile : $!";
		print COV_GC "Sequence\tCoverage\tGC\n";

		$outfile = "$file.blast_contigs.fa";
		open(CONTIGS, '>', $outfile ) or die "Could not write to '$outfile' : $!";


		foreach my $sequence (keys %contigs){
			my $cov = $contigs{$sequence};
			my $length = length($sequence);
			my $gc = calc_GC($sequence) / $length;

			print COV_GC "$sequence\t$cov\t$gc\n";

			my $contig_to_blast = contig4blast($sequence, $cov);

			if($contig_to_blast){
				print CONTIGS '>CONTIG_' . $cov . '_' . "$gc\n";
				print CONTIGS "$contig_to_blast\n" ;   #If 0, do not blast
			}
		}

		close COV_GC or die "Could not close filehandle on $outfile: $!";
		close CONTIGS or die "Could not close filehandle on '$outfile' : $!";
}

print "Processing Complete\n";

exit (0);



###########################################################
#Subroutines
###########################################################


#Subroutine: contig4blast
#Takes a contig and a coverage value from Velvet and returns
#a contig up to 1 kb in length, if it passes the appropriate
#thresholds
sub contig4blast{
	my($seq, $coverage) = @_;
	my $length = length($seq);

	if($coverage > 20 and $length > 100){

		if($length > 1000){    #Trim seq in middle
			my $middle = int($length / 2);
			my $start = $middle - 500;
			$seq = substr($seq, $start, 1000);    #substr has 0 offset
		}

		return "$seq"
	}
	return 0;    #Not suitable for Blast
}




#Subroutine: calc_GC
#Calculates the GC content of a sequence
sub calc_GC{
	my $seq = $_[0];
	my $nos_GC = $seq =~ tr/GCgc//;
	return $nos_GC;
}










