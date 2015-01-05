package T;
our $H;
use strict;
use warnings;
use utf8;
use lib 'lib';
use feature 'say';
sub new {
    my $T = shift;
    $T->{i} = $T->{A}->{u}->{i}; # MAINT
    $T->{i}->{T} = $T;
    $T->{R} = $T->{A}->fiu('G')->{R};
    $T->{name} = shift;
    $T->commit(shift);

    $T
}

sub pi {
    my $T = shift;
    "T $T->{name} x".scalar(@{$T->{L}})." ".$T->{i}->pi(); 
}

sub b {
    my $T = shift;
    die "HELLO!!";
    $T->{R}->du({ O=>$T, i=>$T->{i} })
}

sub commit {
    my $T = shift;
    my $mes = shift;
    $T->{L} ||= []; 
    $mes ||= "init" if !@{$T->{L}}; 
    $mes ||= "?";
    my $L = {
        B => $T->b,  
        mes => $mes,  
    };
    push @{$T->{L}||=[]}, $L;
    $T->{HEAD} = $T->{L}->[-1]; 
    # reduce middle L # TODO J geology
}

sub diflim {
    my $T = shift;
    my $lim = shift;
    my $d = $T->diff($lim);


        for my $h (values %$d) {
            for my $k (keys %$h) {
                my $hk = $k;
                $k =~ s/^\Q$lim\E(\S)/$1/;
                die "$k not from $hk" unless $k;
                $h->{$k} = delete $h->{$hk};
            }
        }

        $d
}

sub diff {
    my $T = shift;
    my $lim = shift;
    my $N = $T->b;
    my $Z = {%{$T->{HEAD}->{B}}};
    my $d = {};
    while (my ($k, $Nv) = each %$N) {
        my $not = !exists $Z->{$k};
        my $Zv = delete $Z->{$k};  

        next unless $k =~ /^\Q$lim\E\S/;

        if ($not) {
            $d->{create}->{$k} = $Nv;
        }
        elsif ($Zv ne $Nv) {
            $d->{dif}->{$k} = $Nv;
        }
    }
    $d->{left} = $Z;
    $d->{new} = {%{$d->{create}||{}},%{$d->{dif}||{}}};
    $d;
}

9;

