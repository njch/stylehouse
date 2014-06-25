package Way;
use Mojo::Base 'Mojolicious::Controller';
use Scriptalicious;
use File::Slurp;
use JSON::XS;
use YAML::Syck;
use Texty;

has 'hostinfo';
sub new {
    my $self = bless {}, shift;
    shift->($self);

    $self->{_ghostname} = shift;
    $self->{_wayfile} = shift;
    if (my $from = shift) {
        for my $i (keys %$from) {
            $self->{$i} = $from->{$i};
        }
    }
    else {
        $self->load_wayfile();
    }
        
    return $self;
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
sub load_wayfile {
    my $self = shift;
    unless ($self->{_wayfile}) {
        delete $self->{hostinfo};
        say "$self->{_ghostname} has no wayfile !".ddump($self);
    }
    my $cont = $self->{hostinfo}->slurp($self->{_wayfile});
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
            map { $_->{_way} ||= $self; $_; }
            map { $self->spawn($_) }
            @{$self->{chains}}
        ];
    }
}
sub spawn {
    my $self = shift;
    my $from = shift || $self;
    return new Way($self->{hostinfo}->intro,
        $self->{_ghostname}, $self->{_wayfile}, $from
    );
}

1;

