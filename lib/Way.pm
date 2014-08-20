package Way;
use Mojo::Base 'Mojolicious::Controller';
use Scriptalicious;
use File::Slurp;
use JSON::XS;
use YAML::Syck;
$YAML::Syck::ImplicitUnicode = 1;
use Texty;

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
    my $self = shift;
    my $from = shift;
    for my $i (keys %$from) {
        die "Diff ghost way from ing"
            if $i eq "G" && $self->{G} ne $from->{G};
        $self->{$i} = $from->{$i};
    }
    $self;
}
sub load {
    my $self = shift;
    $self->{_wayfile} = shift if @_;
    unless ($self->{_wayfile}) {
        delete $self->{hostinfo};
        say "$self->{_ghostname} has no wayfile !".Hostinfo::ddump($self);
    }
    my $cont = $H->slurp($self->{_wayfile});
    my $w = eval { Load($cont) };
    
    
    if ($@ || !$w || ref $w ne 'HASH' || $@) {
        say $@;
        my ($x, $y) = $@ =~
              /parser \(line (\d+), column -?(\d+)\)/;
              
        my @file = split "\n",  read_file($self->{_wayfile});
        my $xx = 1;
        my $vision = SYCK();
        for (@file) {
          if (1 || $x - 8 < $xx && $xx < $x + 5) {
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
        die "! YAML load $self->{_wayfile} failed: "
        .($@ ? $@ : "got: ".($w || "~"))
        ."\n\n".$vision;
    }
    
    $self->init_way($w);
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
    for my $a ("chains", "tractors") {
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
sub find {
    my $self = shift;
    my $point = shift;
    my @path = split '/', $point;
    my $h = $self->{hooks} || $self;
    for my $p (@path) {
        $h = $h->{$p};
        unless ($h) {
            return undef;
        }
    }
    return $h
}
sub accum {
    my $self = shift;
    my $ere = shift;
    my $at = shift;
    push @{$self->gest($ere, [])}, $at;
}
sub gest {
    my $self = shift;
    my ($k, $v) = @_;
    my $w = $self;
    my @moves = split '/', $k;
    until (@moves == 1) {
        my $m = shift @moves;
        $w = $w->{$m};
    }
    my $m = shift @moves;
    $w->{$m} ||= $v
}


1;

