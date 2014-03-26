package Hostinfo;
use Mojo::Base 'Mojolicious::Controller';
use Scriptalicious;

my $data = {};
has 'obyuuid' => sub { {} };

use UUID;
use Scalar::Util 'weaken';

sub data {
    my $self = shift;
    return $data
}

sub make_uuid {
    UUID::generate(my $uuid);
    UUID::unparse($uuid, my $stringuuid);
    return $stringuuid
}

sub screenthing {
    my $self = shift;
    my $thing = shift;
    my $uuid = make_uuid();
    my ($ownername) = $thing->owner =~ /^(\w+)/;
    $uuid =~ /^(\w+)-/;
    my $id = "$ownername-$1";
    $thing->id($id);
    my $screenthing = {
        thing => $thing,
        id => $id,
    };
    my $things = $self->set('screen/things ||=', []);
    push @$things, $screenthing;

}

sub dispatch_event {
    my $self = shift;
    my $event = shift;
    my $things = $self->get('screen/things');
    $self->dump() unless @$things;
    my $id = $event->{id};
    $id =~ s/^(\w+\-\w+).+$/$1/;
    my ($thing) = grep { $id eq $_->{id} } @$things;
    $self->dump() && die "urgh $id" unless $thing;
    $thing->{thing}->event($event);
}


sub get {
    my ($self, $i) = @_;
    $data->{$i};
}
sub set {
    my ($self, $i, $d) = @_;
    if ($i =~ s/ \|\|\=$//s) {
        $data->{$i} ||= $d;
    }
    else {
        $data->{$i} = $d;
    }
    say $i." -> ".$d;
    return $d;
}
sub dump {
    say join "\n", grep { !/^          /sgm } split /\n/, anydump($data);
}

1;
