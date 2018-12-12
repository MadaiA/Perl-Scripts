#!/usr/bin/perl

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

        perl linkRoto.pl [-(dp) <bar>] [-v] [-h]

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
            perl .\\linkRoto.pl -v -d ..\\\\Data -p \.sql\$

    Warning:
    This script was tested only in windows OS. 
    For the other UNIX distros is necesary change the path structure. 
    This \\ for this /

USAGE
#
######################################################


my $directory;
my $path;
my $verbose;
my $help;
my $pattern;

##Get options
GetOptions ("directory=s"   => \$directory,  # string            
            "pattern=s"  => \$pattern,  #string
            "verbose"  => \$verbose,   # flag
            "help|?" => \$help)               
  or die("Error in command line arguments\nPlease type perl $0 -h for help.\n\n");
if($help){print("$USAGE");exit 0;}

##Program start
print("Program STARTED....\n");

# Reading the directory
if(!$directory){$directory = "./Export_HTML";}
if($verbose){printf("Opening the directory %s ....\n",($directory ne "")?$directory:$directory);}
find \&process_file, $directory;


sub process_file
{
    if(!$pattern){$pattern  = '\.html$|\.htm$';} 
    # my $pattern = "\.css";
    my $file = $File::Find::name if /$pattern/;
    my $filepath = $file if $file;  
    if (!$filepath) {return;} 
    if($verbose) {print "Analizing file $filepath ....\n";}        

    #Get the filename    
    my ($filename) = $filepath =~ /(?:\..+\/)(.*)/;
    #print "$filename\n";
    
    # Opening the file
    open(my $fh, '<:encoding(UTF-8)', $filename)  or die "Could not open file '$filename' $!";    

    my $LINE = 0;
    my @match_text;
    while (my $row = <$fh>)     
    {
        $LINE +=1;
        if($row =~ /(?:.*)(<a>.*<\/a>)/)
        {          
            push @match_text, "$LINE:\t $1\n";
        }
    }    
    close $fh;
    # If verbose, print all coincidences
    if($verbose){printf "There are $#match_text broke links...\n";}

    # Save the file with all coincidences
    if ($#match_text >= 0)
    {
        #Adding title
        if($verbose){print "Saving information...\n";}
        unshift @match_text, "$filepath\n";
        my $filename = '..//report.txt';
        open(my $fh, '>>', $filename) or die "Could not open file '$filename' $!";
        print $fh "@match_text\n";
        close $fh;
        if($verbose){print "Information saved...\n";}
    }    
}

print("\nProgram FINISH....\n");





=for
opendir (DIR, $path) or die $!;
  while (my $file = readdir(DIR)) {
       # We only want files
        next unless (-f "$path/$file");

        # Use a regular expression to find files ending in .html
        next unless ($file =~ m/\.html$|\.hmt$perldoc File::Find/);

        print "$file\n";
    }
closedir(DIR);
=cut