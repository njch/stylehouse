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

sub hostinfo {
    my $self = shift;
    $self;
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

sub intro {
    my $self = shift;
    my $new = shift;
    my ($name) = split '=', ref $new;
    if (my $exist = $self->get($name)) {
        say "$name already in hostinfo, new value:";
        say "Existing: ".$self->thedump($exist);
        say "New: ".$self->thedump($new);
    }
    $self->set($name, $new);
    say "Registered name for ".ref $new;
    if ($new->can("dumphooks")) {
        my @otherhooks = $new->dumphooks;
        my $ourhooks = $self->get('dumphooks');
        push @$ourhooks, @otherhooks;
    }
}

sub dump {
    my $self = shift;
    my $dump = $self->thedump($data);
    return $dump if shift;
    say $dump;
}

sub thedump {
    my $self = shift;
    my $thing = shift;
    my $hooks = $self->get('dumphooks');
    push @$hooks, {
        ref => "HASH",
        getlines => sub {
            my $thing = shift;
            my $hooks = shift;
            my $d = shift;
            my @ks = keys %$thing;
            my @sub;
            for my $k (@ks) {
                push @sub, "$k => ", dumpdeal($thing->{$k}, $hooks, $d+1)
            }
            return ("THIS $thing", @sub);
        },
    }, {
        ref => "Lyrico",
        getlines => sub {
            my $thing = shift;
            my $hooks = shift;
            my $d = shift;
            say "DOING A THING WITH $thing";
            my @ks = keys %$thing;
            my @sub;
            for my $k (@ks) {
                push @sub, "$k => ", dumpdeal($thing->{$k}, $hooks, $d+1)
            }
            #return ('<span style="'.random_colour_background().'>'.$thing.'</span>', @sub);
            say "$self";
            return new Texty($self, ["$thing: ", @sub], { leave_spans => 1 });
        },
    };
    my @rdump = dumpdeal($thing, $hooks);

    return join "\n", @rdump;
}
sub dumpdeal {
    my $thing = shift;
    my $hooks = shift;
    my $depth = shift;
    $depth = 1;
    my @lines;
    my $ignore;

    my $dohook = sub {
        my $h = shift;
        my $d;
        if ($h->{getlines}) {
            push @lines, $h->{getlines}->($thing, $hooks, $depth);
        }
        else {
            say "                   NO SOLUTION?";
        }
    };
    my $scanhooks = sub {
        for my $h (@$hooks) {
            if ($h->{ref}) {
                if (ref $thing eq $h->{ref}) {
                    $dohook->($h) && return 1;
                    last;
                }
            }
        }
    };
    unless ($scanhooks->()) {
        push @lines, "? $thing";
    }
    s/^/('  ')x$depth/e for @lines;
    return @lines;
}
1;
