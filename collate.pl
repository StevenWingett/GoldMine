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



#######################################################################################
#Takes a list of GoldMine folder names, extracts the relevent information and writes 
#a summary file in the current working directory.  The summary file presents the results
#of mapping the contigs using Blast.  The score works as follows:
#1) Process each mapped contig in turn
#2) Identify the alignments with the lowest e values
#3) If the alignment is unique to a single species, increment the score of this species by 1
#######################################################################################

use strict;
use warnings;

use Data::Dumper;


#Check input ok
unless (@ARGV){
    die "Please specify contig folder(s) to process.\n";
}
my @folders = deduplicate_array(@ARGV);

#Process files
print "Collating results:\n";
foreach my $folder (@folders){

	$folder =~ s/\/$//;
	my $file = "$folder/blast.txt";
	print "\t$folder\n";

	my $fh_in = cleverOpen($file); 
	my $summary_file = "$folder.summary_results.txt";
	open (SUMMARY, '>', $summary_file) or die "Could not open filehandle on '$summary_file' : $!";
	print SUMMARY "Species\tScore\n";

	my %species_identified;   # %{species} = score
	
	while(<$fh_in>){
		my $line = $_;
		
		if($line =~ /^Sequences producing significant alignments:/){    #This is what need processing
			scalar <$fh_in>;    #Ignore blank line
				
			my $blast_data = '';
			while(1){	
				#print "$line\n";
				my $line = scalar <$fh_in>;
				if($line =~ /^\s*$/){
					last;
				} else {
					$blast_data .= $line;	
				}
			}
			extractSpecies($blast_data, \%species_identified);
			
		} else {
			next;
		}	
		chomp $line;
	}
	close $fh_in or die "Could not close '$file' filehandle : $!";
	

	foreach my $species (sort { $species_identified{$b} <=> $species_identified{$a} } keys %species_identified) {
		print SUMMARY "$species\t$species_identified{$species}\n";
	}
	
	close SUMMARY or die "Could not close filehandle on '$summary_file' : $!";
	
}	

print "Processing complete.\n";

exit (0);





#####################################################################
#Subroutines
#####################################################################

sub extractSpecies {
	my @blast_data = split(/\n/, $_[0]);   #Convert to array
	my $species_identified_ref = $_[1];
	my %unique_species;
	my $e_value;

	foreach my $alignment (@blast_data){
		my @alignment_elements = split(/\s+/, $alignment);
		my $species = "$alignment_elements[1] $alignment_elements[2]";

			
		if( defined $e_value and ($e_value ne $alignment_elements[-1]) ){   #Higher e-value - filter the data
			last;
		} else {
			$e_value = $alignment_elements[-1];
			$unique_species{$species} = '';
		}
	}

	#Update the species hash accordingly
	if(scalar (keys %unique_species) == 1){
		foreach my $species (keys %unique_species){
			${$species_identified_ref}{$species}++;
		
		}
	}

}



#######################
##Subroutine "cleverOpen":
##Opens a file with a filhandle suitable for the file extension
sub cleverOpen{
  my $file  = shift;
  my $fh;
  
	if( $file =~ /\.bam$/){
		open( $fh, "samtools view -h $file |" ) or die "Couldn't read '$file' : $!";  
	}elsif ($file =~ /\.gz$/){
		open ($fh,"zcat $file |") or die "Couldn't read $file : $!";
	} else {
		open ($fh, $file) or die "Could not read $file: $!";
    }
  return $fh;
}




#Sub: deduplicate_array
#Takes and array and returns the array with duplicates removed
#(keeping 1 copy of each unique entry).
sub deduplicate_array{
	my @array = @_;
	my %uniques;

	foreach (@array){
		$uniques{$_} = '';	
	}
	my @uniques_array = keys %uniques;
	return @uniques_array;
}

