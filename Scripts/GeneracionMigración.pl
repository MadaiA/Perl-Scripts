#!/usr/bin/perl

##Partiendo de la consulta SQL
#
#select TABLE_SCHEMA, TABLE_NAME,COLUMN_NAME, ORDINAL_POSITION from information_schema.columns 
#where TABLE_SCHEMA = 'Mac'
#Order by TABLE_NAME,ORDINAL_POSITION

use warnings;
use strict;
use Data::Dumper qw(Dumper);
use autodie qw(:all);

my $path = '..\Data\GeneracionMigracion\\';
my $filename = $path.'ConsultaGeneracionMigracion.txt';
print "\n------------------------------------------------------------------------------------START\n"; 
open(FH, '<:encoding(UTF-8)', $filename) or die "Could not open file '$filename' $!";

my @row = <FH>;
close(FH);

#Gets Table squema of file
$row[0] =~ /([\w]+)\t([\w]+)\t([\w]+)/;
my $table_squema = $1;

#Gets the number of attributes per table 2-D array.     
my @clean_row = &attributesTable(@row);
# print Dumper \@clean_row;

my $current_table_old = "-";
my $printing_save_file;

#Make a SqlQuery for all tables who have table and table_OLD
for(my $TABLE_ELEMENT =0 ; $TABLE_ELEMENT<=$#clean_row; $TABLE_ELEMENT++){
    my $current_table = $clean_row[$TABLE_ELEMENT];

    for(my $TABLE_ELEMENT_OLD =0 ; $TABLE_ELEMENT_OLD<=$#clean_row; $TABLE_ELEMENT_OLD++){
        my $old_element = substr $clean_row[$TABLE_ELEMENT_OLD], -4, 4;

        if($old_element eq "_OLD"){$current_table_old = substr $clean_row[$TABLE_ELEMENT_OLD], 0, -4;} 
        else{$current_table_old = "-";}      
        
        if($current_table eq $current_table_old){
            # print $TABLE_ELEMENT.$current_table." === ".$TABLE_ELEMENT_OLD.$current_table_old."_OLD\n";           
            $printing_save_file .= "\n\n--Numero de registros que se van a migrar en la tabla ".$table_squema.".".$current_table."\n"."select \@filasModificadas = count(*)\nfrom ".$table_squema.".".$current_table_old."_OLD\n"."\nPRINT N\'Numero de registros que se van a migrar en la tabla ".$table_squema.".".$current_table." de la tabla ".$table_squema.".".$current_table_old."_OLD : \' + convert(varchar, \@filasModificadas)\n"."insert into ".$table_squema.".".$current_table." (".lc($clean_row[$TABLE_ELEMENT+1]).")\n"."select ".lc($clean_row[$TABLE_ELEMENT_OLD+1])."\n"."from ".$table_squema.".".$current_table_old."_OLD\n\n";            

            $clean_row[$TABLE_ELEMENT] = "";
            $clean_row[$TABLE_ELEMENT+1] = "";
            $clean_row[$TABLE_ELEMENT_OLD] = "";
            $clean_row[$TABLE_ELEMENT_OLD+1] = "";
        }
    }
}



#Clean the array. 
# print Dumper \@clean_row;
my @clean_table = &cleanArray(@clean_row);

#Make the SQLquery for the missing elements
if(@clean_table ne ('')){  
    if (prompt_yn("\n->EXISTEN TABLAS NO GENERADAS, DESEA VER LAS TABLAS FALTANTES?")){
        for(my $TABLE_ELEMENT=0 ; $TABLE_ELEMENT<=$#clean_table; $TABLE_ELEMENT+=2){
            print $clean_table[$TABLE_ELEMENT]."\n";
        }    
    }

    if (prompt_yn("\n->GENERAR SCRIPT DE MIGRACION DE TABLAS FALTANTES?")){
        my $isOLD = 0;
        for(my $TABLE_ELEMENT=0 ; $TABLE_ELEMENT<=$#clean_table; $TABLE_ELEMENT+=2){
            my $old_element = substr $clean_table[$TABLE_ELEMENT], -4, 4;
            if($old_element eq "_OLD"){$isOLD =1;}else{$isOLD=0;} 

        #print "\n*** $TABLE_ELEMENT - - $clean_table[$TABLE_ELEMENT]  ***\n";
        my $Table = ($isOLD == 1)? "<TABLE>" : $clean_table[$TABLE_ELEMENT];
        my $oldTable = ($isOLD == 1)? $clean_table[$TABLE_ELEMENT] : "<TABLE_OLD>";

        my $atributesTable = ($isOLD == 1)? "<Attributes>" : $clean_table[$TABLE_ELEMENT+1];
        my $old_atributesTable = ($isOLD == 1)? $clean_table[$TABLE_ELEMENT+1]: "<Attributes_OLD>";

        $printing_save_file .= "\n\n--Numero de registros que se van a migrar en la tabla ".$table_squema.".".$Table."\n"."select \@filasModificadas = count(*)\nfrom ".$table_squema.".".$oldTable."\n"."\nPRINT N\'Numero de registros que se van a migrar en la tabla ".$table_squema.".".$Table." de la tabla ".$table_squema.".".$oldTable.": \' + convert(varchar, \@filasModificadas)\n"."insert into ".$table_squema.".".$Table." (".lc($atributesTable).")\n"."select ".lc($old_atributesTable)."\n"."from ".$table_squema.".".$oldTable."\n\n";    
        }
    }  
}


#Save the file

my $filename_save = prompt("->WRITE A NAME FOR SAVING FILE:\n");
# open(my $fh, '>:encoding(UTF-8)', $path.filename_save) or die "Could not open file '$filename_save'";
open(my $fh, '>:encoding(UTF-8)', $path."test.sql") or die "Could not open file '$filename_save'";
print $fh $printing_save_file;
close $fh;
print "\n*** FILE SAVED IN $path$filename_save\n";

    # if (prompt_yn("Do you want to import another gene list file")){
    #      my $list2 = prompt("Give the name of the second list file:\n");
    #      # if (prompt_yn("Do you want to import another gene list file")){
    #      # ...
    # }


print "\n--------------------------------------------------------------------------------------END\n"; 
print"Programed by: marteaga\@logiciel-ec.com\n";


##################
### Functions
#

sub attributesTable{
    my @row = @_; 
    my @numberRows=();  

    for (my $FILA = 0; $FILA <=$#row; $FILA++){
        
        #If it has same tables get indices
        my @countSimilarRows=();
        $row[$FILA] =~ /([\w]+)\t([\w]+)\t([\w]+)/;
        my $actual_table = $2;

        for (my $FILA_B = 0; $FILA_B <=$#row; $FILA_B++){
            $row[$FILA_B] =~ /([\w]+)\t([\w]+)\t([\w]+)/;  

            if($actual_table eq $2){
                push(@countSimilarRows, $3)
            }
        }
        
        #Adding a record in Array
        if ($FILA+1 < $#row){
            $row[$FILA+1] =~ /([\w]+)\t([\w]+)\t([\w]+)/;        
            my $next_table = $2;
            if($actual_table ne $next_table){
                my $flatcountSimilarRows = join(",", @countSimilarRows);
                push(@numberRows,$actual_table,$flatcountSimilarRows);            
            }        
        }
        else{
            my $flatcountSimilarRows = join(",", @countSimilarRows);
            push(@numberRows,$actual_table,$flatcountSimilarRows); 
        }
    }
    return @numberRows;
}

sub cleanArray{
    my @clean_row = @_;    
    my $CONTADOR=0;
    while(1){    
        if($clean_row[$CONTADOR] eq ''){
            splice(@clean_row, $CONTADOR, 1);
            $CONTADOR = 0;
        }
        else{
            $CONTADOR += 1;
        }
        if($CONTADOR > $#clean_row){            
            last;
        }
    }
    return @clean_row;
}

sub prompt {
  my ($query) = @_; # take a prompt string as argument
  local $| = 1; # activate autoflush to immediately show the prompt
  print $query;
  chomp(my $answer = <STDIN>);
  return $answer;
}

sub prompt_yn {
  my ($query) = @_;
  my $answer = prompt("$query (Y/N): ");
  return lc($answer) eq 'y';
}