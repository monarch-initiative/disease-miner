#!/usr/bin/perl -w

use strict;

my @RELS = qw(
arises_from
caused_by
composed_of
derive_from
derived_from
derives_from
has_material_basis
has_symptom
has_symptomrecurring
is_a
is_located
located_in
results_in
results_in_formation_
results_in_formation_of
transmitted_by
);

# with spaces:
push(@RELS,
     'characterized by',
     'caused by',
     'leading to'
    );

my $ann = 0;
my $dictf;
while ($ARGV[0] =~ /^\-/) {
    my $opt = shift @ARGV;
    if ($opt eq '-a') {
        $ann = 1;
    }
    elsif ($opt eq '-d') {
        $dictf = shift @ARGV;
    }
    else {
        die $opt;
    }
}
my @terms = ();
if ($dictf) {
    open(F,$dictf);
    while (<F>) {
        chomp;
        push(@terms, $_);
    }
    close(F);
}

my $sx = join('|',@RELS);
my %sh = map {($_=>1)} @RELS;

while (<>) {
    chomp;
    s@hasmaterial@has_material@g;
    s@ _material_basis_in@ has_material_basis_in@g;
    s@has_material_basis_in@has_material_basis@g;
    s@derive_from@derived_from@g;
    my ($id,$n,$def) = split(/\t/,$_);

    my @s = split(/($sx)/,$def);

    my $k = 'defgenus';
    my %xh = ();
    foreach (@s) {
        if ($sh{$_}) {
            s/ /_/g;
            $k = $_;
        }
        else {
            push(@{$xh{$k}}, $_);
        }
    }
    if (@s>1) {
        #print join("\n  ", @s)."\n" if @s>1;
        print "$id\n$n\n";
        foreach my $k (keys %xh) {
            my @vals = @{$xh{$k} || []};
            @vals = map {stem($_)} @vals;
            @vals = sort @vals;
            print "  $k = [\n";
            my $i=0;
            foreach my $v (@vals) {
                print "    $v\n";
                $i++;
                if ($ann) {
                    annot($id,$n,$def,$k,$i,$v);
                }
            }
            print "  ]\n";
        }
    }
}

exit 0;

sub annot {
    my ($id,$n,$def,$k,$i,$v) = @_;
    $id =~ s/:/_/g;
    my $dir = "ann/$id";
    my $base = "$dir/$k-$i";
    if (! (-d $dir)) {
        system("mkdir -p $dir");
    }
    open(F, ">$base.info");
    print F "id: $id\n";
    print F "name: $n\n";
    print F "k: $k\n";
    print F "v: $v\n";
    print F "def: $def\n";
    close(F);
    #system("echo $id $n // $k = $v // $def > $base.info");
    my $out = "$base.out";
    system("echo \\# key: $k > $out ");
    system("echo \\# id: $id >> $out ");
    system("annotator.pl -c \"$v\" >> $out");
}


sub stem {
    my $w = shift;
    if (!@terms) {
        return $w;
    }
    foreach my $t (@terms) {
        my $pl = $t."s";
        if ($w =~ /$pl/x) {
            #die "$w";
            print STDERR " FROM $w ==> ";
            $w =~ s/$pl/$t/x;
            print STDERR " $w\n";
            #die "fixed to $w";
        }
    }
    return $w;
}
