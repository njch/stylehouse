package Form;
use Mojo::Base 'Mojolicious::Controller';
use Scriptalicious;
use File::Slurp;
use JSON::XS;
use Texty;


has 'hostinfo';
has 'view' => sub { {} };

sub new {
    my $self = bless {}, shift;
    shift->($self);

    return $self;
}

sub menu {
    my $self = shift;
    my $menu = {};

    $menu->{is} = sub { $self->inject_space };

    return $menu;
}

# everything that exists on the screen is part of the experience
# the useful way our brains work is injecting space into ideas, or just being
sub inject_space {
    my $self = shift;
    my $geo = shift;

    my $space = $self->hostinfo->get_goya(); # it's almost never a concept you get to play with on its own
    @$space = grep { $_->{view}->{owner} =~ /Dumpo/ } @$space;
    say scalar(@$space)." spaces";
    my $junk;
    my $min = {};
    my $max = {};
    for my $span (@$space) {
        for my $ang (qw{ top }) {
            my $value = $span->{$ang};

            push @{ $junk->{$ang}->{$value} ||= [] }, $span;

            if (!$max->{$ang} ||
                $max->{$ang} < $value) {
                $max->{$ang} = $value;
            }
            if (!$min->{$ang} ||
                $min->{$ang} > $value) {
                $min->{$ang} = $value;
            }
        }
    }

    my $amp = 1.2;
    my $q = 0.5;

    my $synthspace = sub {
        my $angle = shift;
        my $span = shift;
        my $min = $min->{$angle};
        my $max = $max->{$angle};
        my $half = $max / 2;

        my $gone = $span->{$angle} - $min;
        my $way = $gone / $max; # way is the tiny thing
        my $spec = 0.5 - $way;
        $spec *= -1 if $spec < 0;
        my $qfactor = $spec + $q;
        my $mag = $spec ** $qfactor;

        my $move = $mag * $amp;

#        $qfactor = -$q if $way < $half;
#        my $x = $qfactor * $way * $q;
#        $way += $x;
        
        my $blah = int($mag * 50);
        my $bar = $blah." ".join "", "D" x $blah;
        say "\t$bar";

        $span->{"old_$angle"} = $span->{$angle};
        $span->{$angle} += $way + $min;
       # my $c = $changes->{$span->id} ||= {};
       # $c->{$angle} = $way; # but you had to gethere
    };

    for my $angle (qw{ top }) {
        #$changes->{$angle} ||= [];
        for my $span (@$space) {
            $synthspace->($angle => $span);
        }
    }
    # stuff that we do...
}

sub vastspans {
    my $array_of_spans;
    return map { @$_ } @$array_of_spans;
}

sub event {
    my $self = shift;
    my $event = shift;
    #blah
}

1;
