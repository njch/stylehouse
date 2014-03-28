package Direction;
use Mojo::Base 'Mojolicious::Controller';
use Scriptalicious;
use Texty;

has 'cd';

sub new {
    my $self = bless {}, shift;
    $self->cd(shift);
    my @etc = map { s/\n$//s; $_ } capture("ls", "-lh", $self->cd);
    my $text = new Texty($self, [@etc]);
    return $self;
}

sub event {
    my $self = shift;
    my $event = shift;
    my $texty = shift; # texty has triggers, brings events back to here
    say "Thanksyou: ".anydump($event);
}

1;
