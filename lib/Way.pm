package Way;
use utf8;
use Scriptalicious;
use feature 'say';
use File::Slurp;
use JSON::XS;
use YAML::Syck;
$YAML::Syck::ImplicitUnicode = 1;

our $H;
sub new {
    my $self = bless {}, shift;
    shift->($self);
    delete $self->{hostinfo};

    $self->{G} = shift;
        
    return $self;
}
sub spawn {
    my $self = shift;
    my $from = shift || $self;
    my $nw = $self->{G}->nw();
    $nw->from($from);
    $nw;
}
sub name {
    my $self = shift;
    $self->{name} = shift;
    $self;
}
sub from {
    my $w = shift;
    my $s = shift;
    for my $k (keys %$s) {
        next if $k eq "uuid" || $k eq "G"; # or Li or Lo or who knows what # SCHEMAS # MERGINESS
        my $t = $w->{$k};
        my $f = $s->{$k};
        
        $f = { %$t, %$f } if $t && $k =~ /^(B|S)$/;
        
        $w->{$k} = $f;
    }
    return $w;
}
sub load {
    my $self = shift;
    $self->{_wayfile} = shift if @_;
    $self->{_wayfile} || die;
    my $w = load_yaml($self->{_wayfile});
    $self->init_way($w);
    
}
sub load_yaml {
    my $yamlfile = shift;
    my $yaml = $H->slurp($yamlfile);
    my $w = eval { Load($yaml) };
    if ($@ || !$w || ref $w ne 'HASH' || $@) {
        say $@;
        my ($x, $y) = $@ =~
              /parser \(line (\d+), column -?(\d+)\)/;
              
        my @file = split "\n",  $yaml;
        my $xx = 1;
        my $vision = SYCK();
        for (@file) {
          if ($x - 8 < $xx && $xx < $x + 5) {
            if ($xx == $x) {
              $vision .= "HERE > $_\n";
              $vision .= "HERE > ".join("", (" ")x$y)."^\n";
            }
            else {
              $vision .= "       $_\n";
            }
          }
          $xx++;
        }
        die "! YAML load $yamlfile failed: "
        .($@ ? $@ : "got: ".($w || "~"))
        ."\n\n".$vision;
    }
    $w
}

sub SYCK { <<'';
                             _..._                   
                          .-'_..._''.                
                        .' .'      '.\    .          
       .-.          .- / .'             .'|          
        \ \        / /. '             .'  |          
         \ \      / / | |            <    |          
       _  \ \    / /  | |             |   | ____     
     .' |  \ \  / /   . '             |   | \ .'     
    .   | / \ `  /     \ '.          .|   |/  .      
  .'.'| |//  \  /       '. `._____.-'/|    /\  \     
.'.'.-'  /   / /          `-.______ / |   |  \  \    
.'   \_.'|`-' /                    `  '    \  \  \   
          '..'                       '------'  '---' 

}
sub init_way {
    my $self = shift;
    my $w = shift;

    # merge the ways into $self
    for my $i (keys %$w) {
        $self->{$i} = $w->{$i};
    }
    for my $a ("chains", "tractors") { # TODO leveridge A into way
        next unless $w->{$a};
        my $as = [];
        for my $c (@{$self->{$a}}) {
            $c = $self->spawn($c);
            push @$as, $c;
        }
        $self->{$a} = $as;
    }
    for my $d ("dials") {
        next unless $self->{$d};
        while (my ($k, $v) = each %{$self->{$d}}) {
            $self->{G}->{$k} = $v;
        }
    }
}
sub pint {
    my $w = shift;
    
    my $K = $w->{K}        if defined $w->{K} && !defined $w->{k};
    my $p = $w->{G}->w('print',{},$w)
        if (defined $w->{print} || $w->{Gw}) && Ghost::wish(G=>$w->{G});
    my $B;
    if ($w->{B} && !$p) {
        if (join(",", sort keys %{$w->{B}}) eq "Lu,ui") {
            $B = "Lui*=(".$w->{B}->{ui}->pint();
        }
        $B ||= Ghost::slim(50,30,Ghost::ki($w->{B}))        
    }
    my $s = "$K↯$p".($B?"↯$B":"");
    return $s;
}
sub pi {
    my $w = shift;
    $w->pint
}
sub find {
    my $self = shift;
    my $point = shift;
    my @path = split /\/|\./, $point;
    my $h = $self->{hooks} || $self;
    $h = $self if @_;
    for my $p (@path) {
        $h = $h->{$p};
        unless ($h) {
            return undef;
        }
    }
    return $h
}
sub LioO {
    my $w=shift;
    my $O = shift;
    die "w.K has no Li!" unless $w->{Li};
    my @a = Ghost::findO($O => $w->{Li}->{o});
    wantarray ? @a : shift @a;
}

1;

