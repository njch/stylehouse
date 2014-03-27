package Dump;
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
        spans2jquery => sub {
            my $self = shift;
            for my $s (@{$self->spans}) {
                $s->{right} = delete $s->{left};
            }
        }});
    return $self;
}

1;
