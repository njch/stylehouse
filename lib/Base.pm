package Base;
use Scriptalicious;
use JSON::XS;
use YAML::Syck;
use File::Slurp;
use Time::HiRes 'usleep';
use FindBin '$Bin';
use HTML::Entities;


sub hostinfo {
    my $self = shift;
    return $self->{hostinfo};
}
sub hi {
    my $self = shift;
    return $self->{hostinfo};
}

sub ddump {
    my $thing = shift;
    return join "\n",
        grep !/^     /,
        split "\n", Dump($thing);
}

sub random_colour_background {
    my ($rgb) = join", ", map int rand 255, 1 .. 3;
    return "background: rgb($rgb);";
}

1;
