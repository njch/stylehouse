package Way;
use Mojo::Base 'Mojolicious::Controller';
use Scriptalicious;
use File::Slurp;
use JSON::XS;
use YAML::Syck;
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
    $nw->from($self);
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
              /parser \(line (\d+), column (\d+)\)/;
        say <<'';
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

        my @file = read_file($self->{_wayfile});
        my $xx = 1;
        for (@file) {
          if ($x - 8 < $xx && $xx < $x + 5) {
            if ($xx == $x) {
              print "HERE > $_";
              say "HERE > ".join("", (" ")x$y)."^";
            }
            else {
              print "       $_";
            }
          }
          $xx++;
        }
        die "! YAML load $self->{_wayfile} failed: "
        .($@ ? $@ : "got: ".($w || "~"));
    }
    # merge the ways into $self
    for my $i (keys %$w) {
        $self->{$i} = $w->{$i};
    }
    if ($self->{chains}) {
        $self->{chains} = [
            map { $self->spawn($_) }
            @{$self->{chains}}
        ];
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

1;

