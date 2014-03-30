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
        #$self->app->log->info("$oid created screen thing $tid");
    }
    else {
        die "no $thing";
    }
    
    if ($thing->hooks->{skip_hostinfo}) {
        say "   ! ! ! ! ! !SKIPPING HOSTINFO for $thing->{id}";
        return;
    }
    
    if (!$self->get('screen/things')) {
        $self->set('screen/things', []);
    }
    my $things = $self->get('screen/things');
    
    push @$things, $thing;

}

sub send {
    my $self = shift;
    my $message = shift;
    if (length($message) > $self->tx->max_websocket_size) {
        die "Message is bigger (".length($message).") than max websocket size=".$self->tx->max_websocket_size
            ."\n\n".substr($message,0,180)."...";
    }
    say "Websocket SEND: $message";#.substr($message,0,70);
    my $tx = $self->tx;
    $tx->send({text => $message});
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
    $data->{$i} = $d;
    return $d;
}
sub unset {
    my ($self, $i) = @_;
    $self->app->log->info("Deleting info: $i (".($data->{$i}||"~").")");
    delete $data->{$i};
}
sub dump {
    my $dump = thedump($data);
    return $dump if shift;
    say $dump;
}

sub thedump {
    my $thing = shift;
    my @rdump = dumpdeal($thing);
    my @dump;
    while (0 && defined(my $line = shift @rdump)) {
        if ($line =~ /^(\s*).+?Mojo::Transaction::WebSocket/) {
            my $ind = $1;
            until (!@rdump || $rdump[0] =~ /^$ind\S+/) {
                shift @rdump;
            }
        }
        if ($line =~ /^(\s*).+?hostinfo: \S+ !!perl\/hash:Hostinfo/) {
            my $ind = $1;
            push @dump, "HOstinfo: ";
            until (1 || !@rdump || $rdump[0] =~ /^$ind\S+/) {
                shift @rdump;
            }
        }
        push @dump, $line;
    }

    return join "\n", @rdump;
}
use Data::Walk;

sub dumpdeal {
    my $thing = shift;
    my @lines;
    my $ignore;
    walk sub {
        if (0 && $ignore) {
            $ignore = 0 if $ignore > $Data::Walk::depth;
            return if $ignore;
        }
        if (ref $_ && $_ =~ /WebSocket/) {
            $ignore = $Data::Walk::depth + 1;
        }
        push @lines, join "", ("  " x $Data::Walk::depth)."$_";
    }, $thing;
    say join"\n", @lines;
    return @lines;
}
1;
