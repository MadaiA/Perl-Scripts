# https://leninmhs.wordpress.com/2012/03/28/archivo-de-texto-en-perl/
#####
##Añadir al final una columna más con la descripción del concepto contable

use strict;
use warnings;
use Data::Dumper qw(Dumper);
use Time::localtime;
 
my $filename = 'origen.csv';
unlink "salida.csv";
my @resultado;

open(my $fh, '<:encoding(UTF-8)', $filename) or die "Could not open file '$filename' $!";
print "\n------------------------------------------------------------------------------------START\n"; 
my @row = <$fh>;
close($fh);

## Limpiar linea de texto con el siguiente patrón
my @clean_row = &cleantext(@row); 

## Procesar texto separando concepto contable y copiando la estructura raiz
for(my $NUMERO_FILA = 0; $NUMERO_FILA<=$#clean_row; $NUMERO_FILA++){
	$clean_row[$NUMERO_FILA] =~ s/(.*;)(.*)/$1^$2/g;		
	my @new_row = split /[\^]/, $clean_row[$NUMERO_FILA];						
	@resultado = &separar_conceptos(@new_row);

	print "Descomponiendo y procesando texto ... ".$NUMERO_FILA."/".$#clean_row."\n";

	open(ARCHIVO_FINAL,">>:encoding(UTF-8)", "salida.csv") || die "No se puede abrir el archivo\n";
	for(my $NUMERO_LINEA = 0; $NUMERO_LINEA <= $#resultado; $NUMERO_LINEA++){
		#Armar el arhivo
		if($#resultado == 0 || $NUMERO_LINEA == $#resultado){
			print ARCHIVO_FINAL "$resultado[$NUMERO_LINEA]";
		}
		else{
			print ARCHIVO_FINAL "$resultado[$NUMERO_LINEA]"."\n";
		}
	}
	close(ARCHIVO_FINAL);
}

print "\n\nArchivo guardado como: salida.csv";
print "\n--------------------------------------------------------------------------------------END\n"; 
print "Programed by: marteaga\@logiciel-ec.com\n";
print "***Formula de excel para agregar la descripcion del destino contable";



#####################
## FUNCIONES	
#


sub cleantext {
	my @new_row = @_;	
	for (my $NUMERO_FILA = 0; $NUMERO_FILA <= $#new_row; $NUMERO_FILA++) {
		$new_row[$NUMERO_FILA] =~ s/;(\+|`|\+\+|\+`|`\+|\s\+)/;/g; 
		$new_row[$NUMERO_FILA] =~ s/C\+(D|F|R|S|V)\+/C\@$1\+/g;
	}
	return @new_row;	
}

sub separar_conceptos{
	my @separar = @_;	
	my @conceptos = split /\+/, $separar[1];	
	my @resultado;

	# Match con conceptos tipos S+D; C+R etc
	for (my $ELEMENTO = 0; $ELEMENTO <= $#conceptos; $ELEMENTO++){				
		if ($conceptos[$ELEMENTO] =~ m/\w@\w/g){			
			$conceptos[$ELEMENTO] =~ s/@/+/g;			
			push(@resultado, "$separar[0];$conceptos[$ELEMENTO]");
		}

		elsif($conceptos[$ELEMENTO] =~ m/[\w\d\s]+-[\w\d\s]+/g){			
			$conceptos[$ELEMENTO] =~ s/([\w\d\s]+)-([\w\d\s]+)/$1+$2/g;			
			my @concepto_negativo = split /\+/, $conceptos[$ELEMENTO];
			push(@resultado, "$separar[0];$concepto_negativo[0]");
			push(@resultado, "$separar[0];$concepto_negativo[1]");
		}
		else{					
			push(@resultado, "$separar[0];$conceptos[$ELEMENTO]");
		}
	}
	return @resultado;	
}