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

##############################################################
#Parses Blast output to a format usable by R
##############################################################

use strict;
use warnings;

use Data::Dumper;


# Process with R script:
# file <- "blast.txt.parsed.txt"
# data <- read.delim(file, header=F)
# plot(data[1:2], col=data[,3], pch=16)


unless(@ARGV){
	die "Please specify file(s) to process.\n";
}

foreach my $file (@ARGV){

		open(IN, '<', $file) or die "Could not open $file : $!";

		my $outfile = "$file.parsed.txt";
		open( OUT, '>', $outfile) or die "Could not write to $outfile : $!";


		
		my $coverage;
		my $gc;
		
		while(<IN>){
			my $line = $_;
			chomp $line;

	

			if($line =~ /^Query= CONTIG_(.+)/){
				($coverage, $gc) = split(/_/, $1);
				print "$coverage\t$gc\n";

			}

			if($line =~ /^Sequences producing significant alignments:/){
				scalar <IN>;
				my $organism = scalar <IN>;
				$organism = (split(/\s/, $organism))[2] . '_' . (split(/\s/, $organism))[3];
				print "$organism\n";
				print OUT "$coverage\t$gc\t$organism\n";


			}
			

		}

	
		close IN or die "Could not close filehandle 'IN' on file '$file' : $!";
		close OUT or die "Could not close filehandle on $outfile : $!";

	
}




print "Processing Complete\n";

exit (0);