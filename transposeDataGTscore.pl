#!/usr/bin/perl

use warnings;
use strict;
use Getopt::Std;
use Data::Dumper;

# kill program and print help if no command line arguments were given
if( scalar( @ARGV ) == 0 ){
  &help;
  die "Exiting program because no command line options were used.\n\n";
}

# take command line arguments
my %opts;
getopts( 'hi:o:', \%opts );

# if -h flag is used, or if no command line arguments were specified, kill program and print help
if( $opts{h} ){
  &help;
  die "Exiting program because help flag was used.\n\n";
}

# parse the command line
my( $in, $out ) = &parsecom( \%opts );

my @inLines;
my @newHeader;
my %hash;

&filetoarray( $in, \@inLines );

# capture header
my @header = split( /\s+/, shift( @inLines ) );

# parse data into hash
foreach my $line( @inLines ){
	my @data = split( /\s+/, $line );
	my $locusName = shift( @data );
	push( @newHeader, $locusName );
	for( my $i=0; $i<@data; $i++ ){
		$data[$i] =~ s/,//g;
		$hash{$header[$i]}{$locusName} = $data[$i];
	}

}

open( OUT, '>', $out ) or die "Can't open $out: $!\n\n";

# make a new header line with locus names and print to file
my @sortedHeader = sort( @newHeader );
unshift( @sortedHeader, "Sample" );

my $newheaderstring = join( "\t", @sortedHeader );
print OUT $newheaderstring, "\n";

foreach my $ind( sort keys %hash ){
	print OUT $ind;
	foreach my $locus( sort keys %{$hash{$ind}} ){
		print OUT "\t", $hash{$ind}{$locus};
	}
	print OUT "\n";
}

close OUT;

#print Dumper( \%hash );
#print Dumper( \@sortedHeader );

exit;

#####################################################################################################
############################################ Subroutines ############################################
#####################################################################################################

# subroutine to print help
sub help{
  
  print "\ntransposeData.pl is a perl script developed by Steven Michael Mussmann\n\n";
  print "To report bugs send an email to mussmann\@email.uark.edu\n";
  print "When submitting bugs please include all input files, options used for the program, and all error messages that were printed to the screen\n\n";
  print "Program Options:\n";
  print "\t\t[ -h | -i | -o ]\n\n";
  print "\t-h:\tDisplay this help message.\n";
  print "\t\tThe program will die after the help message is displayed.\n\n";
  print "\t-i:\tSpecify the input file.\n\n";
  print "\t-o:\tSpecify the output file name.\n";
  print "\t\tIf no name is provided, \".transposed.tsv\" will be appended to the input file name.\n\n";
  
}

#####################################################################################################
# subroutine to parse the command line options

sub parsecom{ 
  
	my( $params ) =  @_;
	my %opts = %$params;
  
	# set default values for command line arguments
	my $in = $opts{i} || die "No input file specified.\n\n"; #used to specify input file name.
	my $out = $opts{o} || "$in"  ; #used to specify output file name.

	# fix output file name if default output name is used
	if( $in eq $out ){
		my @temp = split( /\./, $out );
		if( scalar( @temp ) > 1 ){
			pop( @temp );
		}
		push( @temp, "transposed" );
		push( @temp, "tsv" );
		$out = join( ".", @temp );
	}
	
	return( $in, $out );

}

#####################################################################################################
# subroutine to put file into an array

sub filetoarray{

  my( $infile, $array ) = @_;

  # open the input file
  open( FILE, $infile ) or die "Can't open $infile: $!\n\n";

  # loop through input file, pushing lines onto array
  while( my $line = <FILE> ){
    chomp( $line );
    next if($line =~ /^\s*$/);
    push( @$array, $line );
  }

  # close input file
  close FILE;

}

#####################################################################################################
