package Hostinfo;
use Mojo::Base 'Mojolicious::Controller';
use Scriptalicious;

my $data = {};
has 'obyuuid' => sub { {} };
has 'controllery';

use UUID;
use Scalar::Util 'weaken';

sub data {
    my $self = shift;
    return $data
}

sub make_uuid {
    UUID::generate(my $uuid);
    UUID::unparse($uuid, my $stringuuid);
    $stringuuid =~ s/^(\w+)-.+$/$1/s;
    return $stringuuid
}
# take a Texty that wants to go on the screen
# it has a owner, give them the events? 
sub screenthing {
    my $self = shift;
    my $thing = shift;

    # put an ID on it from ClassnameUUID of the Texty->owner;
    # controller makes div? spans are texty things?
    # events find texty, find owner
    if (ref $thing eq "Texty") {
        my $tuuid = make_uuid();
        my $ouuid = make_uuid();
        my ($oname) = $thing->owner =~ /^(\w+)/;
        my $oid = "$oname-$ouuid";
        my $tid = "Texty-$tuuid"; # could stack the ownership like Texty-UUID-Direction-UUID
        $thing->id($tid);
        # $thing->owner->id($oid) 
        $self->app->log->info("$oid created screen thing $tid");
    }
    else {
        die "no $thing";
    }
    
    if ($thing->hooks->{skip_hostinfo}) {
        return;
    }
    
    my $things = $self->set('screen/things ||=', []);
    push @$things, $thing;

}

sub tx {
    my $self = shift;
    $self->get("screen/tx");
}

sub event_id_thing_lookup {
    my $self = shift;
    my $event = shift;
    my $things = $self->get('screen/things');
    die "nothing...". $self->dump() unless @$things;

    my $id = $event->{id};
    $id =~ s/^(\w+\-\w+).+$/$1/;

    my ($thing) = grep { $id eq $_->{id} } @$things;

    return $thing;
}


sub get {
    my ($self, $i) = @_;
    $data->{$i};
}
sub set {
    my ($self, $i, $d) = @_;
    $self->app->log->info("Hosting info: $i -> ".($d||"~"));
    if ($i =~ s/ \|\|\=$//s) {
        $data->{$i} ||= $d;
    }
    else {
        $data->{$i} = $d;
    }
    return $d;
}
sub dump {
    my $dump = join "\n", grep { !/^          /sgm } split /\n/, anydump($data);
    return $dump if shift;
    say $dump;
}

1;
