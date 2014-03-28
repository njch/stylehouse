package Direction;
use Mojo::Base 'Mojolicious::Controller';
use Scriptalicious;
use Texty;

has 'cd';
has 'app';
has 'hostinfo';

sub new {
    my $self = bless {}, shift;
    $self->cd(shift);
    $self->hostinfo(shift->hostinfo);
    my @etc = map { s/\n$//s; $_ } capture("ls", "-lh", $self->cd);
    my $text = new Texty($self, [@etc], { view => "view" });
    return $self;
}

sub event {
    my $self = shift;
    my $tx = shift;
    my $event = shift;
    my $texty = shift; # texty has triggers, brings events back to here
    say "Thanksyou: ".anydump($event);
}

1;
