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


#Produce scatter plot of coverage vs GC content
args <- commandArgs(TRUE)
file <- args[1]

data <- read.delim(file, skip=1, header=F)
data[,1] <-NULL

data <- subset(data,data[,1]>20)    #Remove low coverage contigs


outfile=paste(file, "pdf", sep = ".")
pdf(outfile)
title <- paste0(file, "\n", "Contig coverage vs GC content")

smoothScatter(data, nrpoints = 1, xlab = 'Coverage', 
              ylab = 'GC Content', main=title)



dev.off()