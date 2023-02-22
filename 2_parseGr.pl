$treefile=$ARGV[0];
$pars_seq_name="0"; # 0 for first, 1 for last

$current_date = `date +"%Y-%m-%d"`;
chomp (my @current_date_els=split(/-/,$current_date));
$year=$current_date_els[0];
$month=$current_date_els[1];
$day=$current_date_els[2];
$lessthaningroup=16;
$place_add=0;
$exhaustive_print=0;
$number_of_idletters=2;
$relaxed=0;

$todayfromJesus=int($year*365+$month*30.4+$day);
if ($exhaustive_print >0)
{
print "Today:$year-$month-$day\tFROM JESUS:$todayfromJesus\n\n";
}
open IN, "<$treefile";
chomp (my @infile_lines=<IN>);
close IN;


%total_percentages=();
%place_directions=();
$trans_count=0;
%all_pairs=();
%pairs=();
%used=();
for ($gr=2;$gr<$lessthaningroup;$gr++)
{
for ($i=0;$i<@infile_lines;$i++)
{
	$inline=$infile_lines[$i];
	if(($inline=~m/^>/)&&($inline!~m/^>>/))
	{
		$sequence_line=$infile_lines[$i+1];
		chomp (my @inline_els=split(/\t/,$inline));
		chomp (my @seqline_els=split(/\s/,$sequence_line));			

		$nrtaxa=@seqline_els;
#print "nrtaxa:$nrtaxa\n";		
#		if($nrtaxa <6)   ####change accordingly!!
		if(($nrtaxa eq $gr)&&($nrtaxa >1))	
		{
			%sequences=();
			$tcount=0;
#			$place="";
			%seq_days=();			
if ($exhaustive_print >0)
{	
print "TAXA:$nrtaxa\n@seqline_els\n";
}
			foreach $seq(@seqline_els)
			{	
				$place="";
				$tcount++;	
				chomp (my @seq_els=split(/-/,$seq));
				$taxID=$seq_els[$pars_seq_name];						
#				$sequences{$taxID}++;		
				chomp (my @defdate_els=split(/_/,$seq));				
				if ($place_add >0)
				{
					$place=pop(@defdate_els); ################ CHECH if place at the end!!!
				}
				$fulldate=pop(@defdate_els);
				chomp (my @date_els=split(/-/,$fulldate));
				$year=$date_els[0];
				$yeardays=$date_els[0]*365;
				$monthdays=$date_els[1]*30.4;
				$days=$date_els[2];
				$fromJesus=int($yeardays+$monthdays+$days);					
				$ID_place="$taxID"."_$place";

				$seq_days{$fromJesus}{$seq}="$taxID";	

			}

			@keys_sorted=sort(keys(%seq_days));
#			%place_directions=();
if ($exhaustive_print >0)
{
print "keys_sorted:@keys_sorted\n";
}
			@keys_sorted_seqs=();
			foreach $ks(@keys_sorted)
			{
				foreach $subject (keys %{ $seq_days{$ks} })
				{
					push(@keys_sorted_seqs,$subject);	
				} 	
			}				
###print "@seqline_els\n";
if ($exhaustive_print >0)
{
print "@keys_sorted_seqs\n";
}
			for ($sk=0;$sk<@keys_sorted_seqs-1;$sk++)
			{
				$last_el=@keys_sorted_seqs-2;
				$keys_sorted_seq=$keys_sorted_seqs[$sk];				
				$keys_sorted_seq_next=$keys_sorted_seqs[$sk+1];
				chomp (my @keys_sorted_seq_els=split(/-/,$keys_sorted_seq));
				chomp (my @keys_sorted_seq_next_els=split(/-/,$keys_sorted_seq_next));
				$val_place=$keys_sorted_seq_els[0];
				$next_val_place=$keys_sorted_seq_next_els[0];			
				$trans="$val_place>$next_val_place";
				$tespair="$keys_sorted_seq>$keys_sorted_seq_next";
if ($exhaustive_print >0)
{
print "$tespair\t$trans\n";
}
				if ((($relaxed eq 1)&&(not exists $pairs{$tespair}))||(($relaxed eq 0)&&(not exists $used{$keys_sorted_seq_next})))
				{
					$place_directions{$trans}++;
					$trans_count++;
					$pairs{$tespair}++;
					$used{$keys_sorted_seq_next}++;	
					$sequences{$val_place}++; 
					if ($sk eq $last_el)
					{
						$sequences{$next_val_place}++;
					}	 
				}
			}	
			

			@seq_keys_sorted=sort(keys %sequences);
if ($exhaustive_print >0)
{
print "seq_keys_sorted:@seq_keys_sorted\n";
}
		}	
	}
}
}

$total_unique_pairs=keys(%pairs);
@unique_pairs=sort(keys(%pairs));

print "total_unique_pairs:$total_unique_pairs\n";
if ($exhaustive_print >0)
{
	foreach $pair(@unique_pairs){print "$pair\n";}
}

#@keys_pers=keys(%total_percentages);
#foreach $key(@keys_pers)
#{
#	$keyval=$total_percentages{$key};
###print "$key:$keyval\n";
#}


%additives=();
foreach my $name(sort { $place_directions{$b} <=> $place_directions{$a}} keys %place_directions)
{
	chomp (my @name_els=split(/>/,$name));
	$name_el1=$name_els[0];
	$name_el2=$name_els[1];
	$val=$place_directions{$name};
#$val_norm=$val/$trans_count;
	$val_norm=$val/$total_unique_pairs;

	chomp (my @name1_els=split(//,$name_el1));
	chomp (my @name2_els=split(//,$name_el2));

	if ((@name1_els eq $number_of_idletters )&&(@name2_els eq $number_of_idletters)) ######## IF STATE ID IS NOT XX- CHANGE!!!!!
	{
#printf "%-8s %s\n", $name,$val_norm;
printf "%-8s %s\n", $name,$val;
	}

	$additives{$name_el1}+=$val_norm;
	$additives{$name_el2}+=$val_norm;
	if ($name_el1 eq $name_el2)
	{
		$samegrowing{$name_el1}+=$val;
		$samegrowing_norm{$name_el1}+=$val_norm;
	}else
	{	
		$incoming{$name_el2}+=$val;
		$incoming_norm{$name_el2}+=$val_norm;
		$outcoming{$name_el1}+=$val;
		$outcoming_norm{$name_el1}+=$val_norm;
	}
}	

@keys_adds=keys(%additives);
foreach $ka(sort { $additives{$b} <=> $additives{$a} } keys %additives)
{
	$kaval=$additives{$ka};
if ($exhaustive_print >0)
{
print "$ka quality ADDS for lessthaningroup $lessthaningroup:$kaval\n";
}
}

@same_keys=keys(%samegrowing);

foreach $samkey(@same_keys)
{
	$income=$incoming{$samkey};
	$outcome=$outcoming{$samkey};
	$same=$samegrowing{$samkey};
	$total=$income+$outcome+$same;
	print "samkey:$samkey\tincom:$income\tout:$outcome\tsame:$same\ttotal:$total\n";

}





