package View;
use Mojo::Base 'Mojolicious::Controller';
use Scriptalicious;
use Texty;

has 'hostinfo';
has 'owner';
has 'id';
has 'others';

sub new {
    my $self = bless {}, shift;
    shift->($self);

    $self;
}
sub pos {
    my $self = shift;
    my $i = 0;
    return grep { $_ eq $self || $i++ && 0 } @{$self->others}
}
sub text {
    my $self = shift;
    $self->{text} ||= Texty->new(@_);
}

1;
