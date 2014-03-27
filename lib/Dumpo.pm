package Dumpo;
use Mojo::Base 'Mojolicious::Controller';
use Scriptalicious;
use Texty;

has 'cd';
has 'app';

sub new {
    my $self = bless {}, shift;
    my %p = @_;
    $self->app($p{app});

    my $dump = $self->app->hostinfo->dump("dontsay");
    my $text = new Texty($self, [split("\n", $dump)], 'hodu', {
        spans_to_jquery=> sub {
            my $self = shift;
            for my $s (@{$self->spans}) {
                $s->{right} = "0";
                $s->{value} =~ s/^(\s+)(\S+): (.+)$/$3 :$2 $1/s;
                $s->{value} =~ s/^(\s+)- (.+)$/$2 -$1/s;
            }
        }});
    return $self;
}

1;
