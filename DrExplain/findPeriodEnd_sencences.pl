#!/usr/bin/perl

# Program for detecting period of file at end of sentences.
# The sentences being proceses must be writed in only one row.
# This program junk when the paragrap have "end line" (Enter - keyboard)
# Pattern (.*[\w\n\s]$)

use warnings;
use strict;
use Data::Dumper qw(Dumper);
use autodie qw(:all);
use Getopt::Long;
use Pod::Usage;
use File::Find qw(find);

########################################################
# USAGE
#
my $USAGE =<<USAGE;
    Usage:

        perl detectSentences.pl [-(dp) <bar>] [-v] [-h]

        where:
           
            directory:  --directory or -d     [string]
                        Is the path or directory for analice the information. 
                        Use if you need excecute this in other archive.

                        -d ..\\\\Data\\\\Path
            
            pattern:    --patern or - p [string]
                        Is the regex patern that match with the file

                        -p \\.html\$|\\.htm\$|\\.txt\$

            verbose:    --verbose or -v
                        Use this for verbose

            help:       --help or -h or -?
                        Prints out this helpful message

    Example:    
            perl .\\detectSentences.pl -v -d ..\\\\Data -p \.sql\$

    Warning:
    This script was tested only in windows OS. 
    For the other UNIX distros is necesary change the path structure. 
    This \\ for this /

USAGE
#
######################################################


my $filename;
my $path;
my $verbose;
my $help;
my $pattern;
my @final_text;

##Get options
GetOptions ("filename=s"   => \$filename,  # string            
            "pattern=s"  => \$pattern,  #string
            "verbose"  => \$verbose,   # flag
            "help|?" => \$help)               
  or die("Error in command line arguments\nPlease type perl $0 -h for help.\n\n");
if($help){print("$USAGE");exit 0;}

##Program start
print("Program STARTED....\n");

if(!$filename){$filename = ".//textManual.process"}

 # Opening the filename
    open(my $fh, '<:encoding(UTF-8)', $filename)  or die "Could not open file '$filename' $!";    

    my $LINE = 0;
    my @match_text;
    while (my $row = <$fh>)     
    {
        $LINE +=1;
        if($row =~ /(.*[\.:]$)|(.*[\w\n\s]$)/ && $row ne "\n") #regex that match information inside de documents
        {            
            if($2){            push @match_text, "$LINE:\t $2";            }
        }
    }    
    close $fh;
    # If verbose, print all coincidences
    if($verbose){printf "There are $#match_text incorrect sentences...\n";}

    # Save the file with all coincidences
    $filename = './/reportSentences.txt';
    if ($#match_text >= 0)
    {        
        #Adding title
        if($verbose){print "Saving information...\n";}
        unshift @match_text, "$filename\n";
       
        push @final_text, "@match_text\n";
        if($verbose){print "Information saved...\n";}
    }    
  
    open($fh, '>', $filename) or die "Could not open file '$filename' $!";
    print $fh "@final_text";
    close $fh;

    print("\nProgram FINISHED....\n");
