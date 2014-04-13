package Hostinfo;
use Mojo::Base 'Mojolicious::Controller';
use Scriptalicious;
use IO::Async::Loop::Mojo;
use IO::Async::Stream;

my $data = {};

has 'for_all';
has 'who'; # spawners of websocket activity

use UUID;
use Scalar::Util 'weaken';
use View;

sub send {
    my $self = shift;
    my $message = shift;

    if (length($message) > ($self->{tx_max} || 300000)) {
        die "Message is bigger (".length($message).") than max websocket size=".$self->{ts_max}
        # TODO DOS fixed by visualising {ts} and their sizes
            ."\n\n".substr($message,0,180)."...";
    }

    if ($message =~ /\n/) {
        warn "Message contains \\n";
    }

    my $short = $message if length($message) < 666;
    $short ||= substr($message,0,66*3)." >SNIP<";
    
    say "Websocket SEND: ". $short;

    # here we want to graph things out real careful because it is how things get around
    # the one to the many
    # apps can be multicasting too
    # none of these workings should be trapped at this level
    # send it out there and get the hair on it
    if (!$self->who) {
        # got a push from stylhouse
        push @{ $self->for_all }, $message;
        say "Websocket Multi Loaded: $short";
        return;
    }
    else {
        $self->god_send($message);
    }
}

sub god_send {
    my $self = shift;
    my $message = shift;
    my $god = shift;
    $god ||= $self->who;
    if (!$god) {
        say "NO INDIVIDUAL TO send $message";
    }
#    say anydump($god);
    $god->{tx}->send({text => $message});
}

sub send_all {
    my $self = shift;
    my $messages = $self->for_all;
    my $who = $self->who;
    $self->who(undef);
    for my $message (@$messages) {
        my $gods = $self->get('gods');
        for my $god (@$gods) {
            say "Am here";
            $self->god_send($messages, $god);
        }
    }
    $self->who($who);
}

sub new_god {
    my $self = shift;
    my $tx = shift;

    my $max = $tx->max_websocket_size;
    $self->{tx_max} ||= $max;
    unless ($max >= $self->{tx_max}) {
        $self->{tx_max} = $max; # TODO potential DOS
    }

    my $gods = $self->get('gods');
    $gods ||= [];
    $self->set(gods => $gods);

    my $new = { # upgrade to God?
        address => $tx->remote_address,
        max => $tx->max_websocket_size,
        tx => $tx,
    };
    say "$new->{address} appears";
    push @$gods, $new;
    $self->who($new);
}

sub god_enters {
    my $self = shift;
    my $tx = shift;
    # someone, anyone
    my $exist = $self->find_god($tx);
    if ($exist) {
        say "$exist->{address} returns";
        $self->who($exist);
    }
    else {
        $self->new_god($tx);
    }
}

sub find_god {
    my $self = shift;
    my $tx = shift;

    my ($god) = grep { $_->{tx} eq $tx } @{$self->get('gods')}; # vibe equator
    return $god || undef;
}

sub god_leaves {
    my $self = shift;
    my $tx = shift;
    if (!$tx) {
        # they're just leaving this request
        $self->who(undef);
        say "God leaves";
        return;
    }
    my $code = shift || "?";
    my $reason = shift || "?";

    say "Part: ".$tx->remote_address.": $code: $reason";
    say ddump($self->find_god($tx));

    my $gods = $self->get('gods');
    @$gods = grep { $_->{tx} ne $tx } @{$self->{tx}};
}

sub hostinfo { shift }

sub data { $data }

# make a number bigger than the universe...
sub make_uuid {
    UUID::generate(my $uuid);
    UUID::unparse($uuid, my $stringuuid);
    $stringuuid =~ s/^(\w+)-.+$/$1/s;
    return $stringuuid;
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
    my @divids = shift;
    for my $divid (@divids) {
        # if view exists in Hostinfo it will only resend its drawing
        $self->provision_view($divid);
    }
}

    
my $div_attr = { # these go somewhere magical and together, like always
    menu => "width:100%; background: #333; height: 90px;",
    hodu => "width:60%;  background: #352035; color: #afc; top: 50; height: 4000px",
    view => "width:40%; background: #c9f; height: 500px;",
    hodi => "width:40%; background: #09f; height: 5000px;",
};
# build its own div or something
sub provision_view {
    my $self = shift;
    my $divid = shift;

    my $styles = $div_attr->{$divid} || die "wtf";
    my $div = '<div id="'.$divid.'" class="view" style="'.$styles.'"></div>';
    $self->send("\$('body').append('$div');");

    unless ($self->get('screen/views/'.$divid)) {
        $self->set('screen/views/'.$divid, []);
    }
}

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
    say "Have $divid\n\n" if $views;
    unless ($views) {
        $views = $self->provision_view($divid);

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
# thanks to the high perfect babel of the #perl
# I think my drug is hash and perl and everything
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
    my $id = shift;

    my $things = $self->get('screen/things');
    return say "nothing...". $self->dump()  unless $things;

    my ($thing) = grep { $id eq $_->{id} } @$things;

    return $thing;
}


sub get {
    my ($self, $i) = @_;
    $data->{$i};
}
sub set {
    my ($self, $i, $d) = @_;
#    $self->app->log->info("Hosting info: $i -> ".($d||"~"));
    $data->{$i} = $d;
    return $d;
}
sub unset {
    my ($self, $i) = @_;
    $self->app->log->info("Deleting info: $i (".($data->{$i}||"~").")");
    delete $data->{$i};
}

sub error {
    my $self = shift;
    my $e = {@_};
    say "\nError: ".ddump($e);
    $self->updump($e);
}
sub updump {
    my $self = shift;
    my $thing = shift;
    my $dumpo = $self->get('Dumpo');
    unless ($dumpo) {
        say "---no Dumpo, doing it here"; # constipated leaders
        say ddump($thing);
    }
    $dumpo->updump($thing); # owner: $self
}
use YAML::Syck;
sub ddump {
    my $thing = shift;
    return join "\n",
        grep !/^     /,
        split "\n", Dump($thing);
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
