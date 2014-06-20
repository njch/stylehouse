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

    $self->{wayofthe} = shift;
    $self->{file} = shift;
    $self->load_wayfile();

    return $self;
}
sub find {
    my $self = shift;
    my $point = shift;
    my @path = split '/', $point;
    my $h = $self->{hooks};
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
    my $cont = $self->{hostinfo}->slurp($self->{file});
    my $w = eval { Load($cont) };
    if (!$w || ref $w ne 'HASH' || $@) {
        say $@;
        my ($x, $y) = $@ =~
            /parser \(line (\d+), column (\d+)\)/;
        say "$x and $y";
        my @file = read_file($self->{file});
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
        die "! YAML load $self->{file} failed: "
            .($@ ? $@ : "got: ".($w || "~"));
    }
    # merge the ways into $self
    for my $i (keys %$w) {
        $self->{$i} = $w->{$i};
    }
    if ($self->{chains}) {
        for my $c (@{$self->{chains}}) {
            $c->{way} ||= $self;
        }
    }
}
sub spawn {
    my $self = shift;
    return new Way($self->{hostinfo}->intro,
        $self->{wayofthe}, $self->{file}
    );
}

1;

