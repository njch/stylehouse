package Hostinfo;
use Mojo::Base 'Mojolicious::Controller';
use Scriptalicious;
use IO::Async::Loop::Mojo;
use IO::Async::Stream;

my $data = {};

has 'console';

use UUID;
use Scalar::Util 'weaken';
use View;

sub tx { shift->get("screen/tx") }

sub hostinfo { shift }

sub data { $data }

# make a number bigger than the universe...
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

    my $id = ref $thing;
    if ($id =~ /View/) {
        $id .= "-".ref $thing->owner;
    }
    my $uu = make_uuid();

    $thing->id("$id-$uu");
    

    if (!$self->get('screen/things')) {
        $self->set('screen/things', []);
    }
    my $things = $self->get('screen/things');
    
    push @$things, $thing;
}


sub load_views { # state from client
    my $self = shift;
    my $js = shift;
    my @divs;
    for my $divid (@divs) {
        $self->set('screen/views/'.$divid, []);
    }
}

# build its own div or something

        # something new
        # but closest to the nature of a program: a viewport with trustworthy language
        # then popular views can get names
        # but the latest innovations at the view can be streamed in
        # it's feeding an idea about the way of the view
        # gathering by ideas for progress
        # instead of solidity
sub get_view { # TODO create views and shit
    my $self = shift;
    my $other = shift;
    my $viewid = shift;

    my ($divid) = $viewid =~ /^(.+)_?/;

    my $views = $self->get('screen/views/'.$divid);
    unless ($views) {
        $views = $self->set('screen/views/'.$divid, []);

    }

    my $view = new View( $self->intro,
        $other,
        $viewid,
        $views,
    );


    # add together
    push @$views, $view;

    # store it on the App
    my $oname = defined $other ? ref $other : "undef";
    if ($other->can("ports")) {
        unless ($other->ports) {
            $other->ports({});
        }
        $other->ports->{$viewid} = $view;
    }

    return $view;
}

# this is where human attention is (before this text was in the wrong place)
# it's a place things flow into sporadically now
# but it's a beautiful picture of the plays of whatever
sub get_goya {
    my $self = shift;

    my $stuff = $self->grep('screen/views');

    my @goya;
    for my $k (keys %$stuff) {
        my $views = $stuff->{$k};
        for my $view (@$views) {
            if (exists $view->{text}) {
                my $text = $view->{text};
                push @goya, { view => $view, thing => $text, span => $text->tuxts };
            }
            else {
                say "something other than text has popped up"
            }
        }
    }
    return \@goya;
}

sub grep {
    my $self = shift;
    my $regex = shift;
    return {
        map { $_ => $data->{$_} }
        grep /$regex/,
        keys %$data
    };
}

sub send {
    my $self = shift;
    my $message = shift;

    if (length($message) > $self->tx->max_websocket_size) {
        die "Message is bigger (".length($message).") than max websocket size=".$self->tx->max_websocket_size
            ."\n\n".substr($message,0,180)."...";
    }

    if ($message =~ /\n/) {
        warn "Message contains \\n";
    }

    my $short = $message if length($message) < 400;
    $short ||= substr($message,0,70)." >SNIP<";
    
    say "Websocket SEND: ". $short;

    my $tx = $self->tx;
    $tx->send({text => $message});
}
sub loop {
    my $self = shift;
    $self->{loop} ||= IO::Async::Loop::Mojo->new();
}
sub stream_file {
    my $self = shift;
    my $filename = shift;
    my $linehook = shift;
    say "stream_file: $filename";
    open(my $handle, "$filename");
    $self->stream_handle($handle, $linehook);
}
sub stream_handle {
    my $self = shift;
    my $handle = shift;
    my $linehook = shift;

    my $stream = IO::Async::Stream->new(
        read_handle  => $handle,

        on_read => sub {
            my ( $self, $buffref, $eof ) = @_;

            while( $$buffref =~ s/^(.*\n)// ) {
                $linehook->($1);
            }

            if( $eof ) {
                $linehook->($$buffref);
            }

            return 0;
        },
    );
    $self->loop->add($stream);
}


sub event_id_thing_lookup {
    my $self = shift;
    my $event = shift;
    my $things = $self->get('screen/things');
    return say "nothing...". $self->dump()  unless $things;

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

sub thedump {
    my $self = shift;
    my $thing = shift;
    my $dumpo = $self->get('Dumpo');
    unless ($dumpo) {
        say "---pre dumpo @_";
    }
    $dumpo->thedump($thing, $self); # owner: $self
}
sub intro {
    my $self = shift;
    return sub {
        my $other = shift;
        $other->hostinfo($self);
        $self->duction($other);
    };
}

sub duction {
    my $self = shift;
    my $new = shift;
    my ($name) = split '=', ref $new;
    if (my $exist = $self->get($name)) {
        my $oldname = $name."_old";
        unless ($self->get($oldname)) {
            $self->set($oldname, []);
        }
        my $old = $self->get($oldname);
        push @$old, $exist;
    }
    $self->set($name, $new);
    if ($new->can("dumphooks")) {
        my @otherhooks = $new->dumphooks;
        my $ourhooks = $self->get('dumphooks');
        push @$ourhooks, @otherhooks;
    }
    my $apps = $self->get('apps');
    $apps ||= {};
    $apps->{$name} = $new;
    $self->set('apps', $apps);
}
1;
