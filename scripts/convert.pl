#!/usr/bin/perl
use strict;
use warnings;

# Check if correct number of arguments are passed
if (@ARGV != 1) {
	die "Usage: $0 input.tex\n";
}

my ($input_file) = @ARGV;

my $output_file = $input_file;
$output_file =~ s/\.tex/.mdx/;

my $chapter = $input_file;
$chapter =~ s/notes\/\w*?\/chapters\/(.*?).tex/\u$1/;
$chapter =~ s/-/ /g;

# Open input and output files
open(my $in, '<', $input_file) or die "Cannot open $input_file: $!";
open(my $out, '>', $output_file) or die "Cannot open $output_file: $!";

print $out "---
title: $chapter
---";

while (my $line = <$in>) {
	# Remove \n from EOL
	chomp $line;

	# Convert chout env
	$line =~ s/\\begin\{chout\}/<div style="text-align: center">/;
	$line =~ s/\\end\{chout\}/<\/div>/;

	# Convert LaTeX section headings to Markdown headers
	next if $line =~ /\\chapter/;
	$line =~ s/\\section\{(.+?)\}/## $1/;
	$line =~ s/\\section\*\{(.+?)\}/## $1/;
	$line =~ s/\\subsection\{(.+?)\}/### $1/;
	$line =~ s/\\subsection\*\{(.+?)\}/### $1/;

	$line =~ s/\\textbf\{(.+?)\}/**$1**/g;
	$line =~ s/\\textit\{(.+?)\}/*$1*/g;

	# Remove LaTeX comment lines (lines starting with %)
	next if $line =~ /^\s*%/;

	# Remove citations
	$line =~ s/\\cite\{.+?\}//g;
	$line =~ s/\\ref\{.+?\}//g;
	$line =~ s/\\label\{.+?\}//g;

	# Custom macros redefinition
	$line =~ s/\\defined\{(.*?)\}/**$1**/gs;

	print $out "$line\n";
}

# Close the files
close($in);
close($out);

print "Conversion complete!\n";