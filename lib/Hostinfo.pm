package Hostinfo;
use Mojo::Base 'Mojolicious::Controller';
use Scriptalicious;
use IO::Async::Loop::Mojo;
use IO::Async::Stream;
use UUID;
use Scalar::Util 'weaken';
use View;

my $data = {};

has 'ports';

has 'for_all';
has 'who'; # spawners of websocket activity


sub send {
    my $self = shift;
    my $message = shift;

    if (length($message) > ($self->{tx_max} || 300000)) {
        die "Message is bigger (".length($message).") than max websocket size=".$self->{ts_max}
        # TODO DOS fixed by visualising {ts} and their sizes
            ."\n\n".substr($message,0,180)."...";
    }

    $message =~ s/\n//g;

    if ($message =~ /\n/) {
        warn "Message contains \\n";
    }

    my $short = $message if length($message) < 200;
    $short ||= substr($message,0,23*3)." >SNIP<";
    
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

sub god_connects {
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

    my $new = {
        address => $tx->remote_address,
        max => $tx->max_websocket_size,
        tx => $tx,
    };


    say "$new->{address} appears";
    push @$gods, $new;
    $self->who($new);
    $self->review();
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

    my $gods = $self->get('gods');
    @$gods = grep { $_->{tx} ne $tx } @{$self->{tx}};
}

sub hostinfo { shift }

sub data { $data }


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
    babs => "width:60%; background: #09f; height: 2000px;",
    flood => "width:800px; height:8000px; border: 4px solid gray; position:absolute",
};
# build its own div or something
sub provision_view {
    my $self = shift;
    my $divid = shift;

    my $styles = $div_attr->{$divid} || die "wtf";
    my $div = '<div id="'.$divid.'" class="view" style="'.$styles.'"></div>';
    $div =~ s/class="view"/class="menu"/ if $divid eq "menu";
    $self->send("\$('body').append('$div');");

    unless ($self->get('screen/views/'.$divid)) {
        $self->set('screen/views/'.$divid, []);
    }
    $self->get('screen/views/'.$divid);
}

sub view_incharge {
    my $self = shift;
    my $view = shift;
    my $old = $self->get('screen/views/'.$view->divid.'/top');
    $old->unfocus() if $old;
    $self->set('screen/views/'.$view->divid.'/top', $view);
}

sub review {
    my $self = shift;

    my $tops = $self->grep('screen/views/.+/top');
    my @tops = values %$tops;
    return say "nothing to ->review" unless @tops;
    say "resurrecting: ".anydump([keys %$tops]);
    for my $div (qw{menu hodu view hodi}) {
        my ($view) = grep { $_->divid eq $div } @tops;
        next unless $view;
        $self->provision_view($view->divid);
        $view->review;
    }
}
 
sub event_id_thing_lookup {
    my $self = shift;
    my $id = shift;
    $id =~ s/^((\w+-)?\w+\-\w+).+$/$1/;

    my $things = $self->get('screen/things');
    return say "nothing..." unless $things;

    my ($thing) = grep { $id eq $_->{id} } @$things;

    return $thing;
}

sub screenthing {
    my $self = shift;
    my $thing = shift; # texty or view

    my $id = ref $thing;
    if ($thing->can('owner')) {
        my $owner = $thing->owner;
        die "wtf ".ddump($thing) unless $owner;
        if (ref $owner eq "View") {
            $owner = $owner->owner;
            die "wtf View owner ".ddump($thing->owner) unless $owner;
        }
        $id = ref($owner)."-$id";
    }

    $thing->id("$id-".$thing->{huid});

    if (!$self->get('screen/things')) {
        $self->set('screen/things', []);
    }
    my $things = $self->get('screen/things');
    
    push @$things, $thing;
}

sub get_view { # TODO create views and shit
    my $self = shift;
    my $this = shift;
    my $viewid = shift;
    my $alias = shift;
    ($alias, $viewid) = ($viewid, $alias) if $alias;

    my ($divid) = $viewid =~ /^(.+)_?/;

    my $views = $self->get('screen/views/'.$divid);
    unless ($views) {
        $views = $self->provision_view($divid);
    }

    my $view = new View($self->intro);

    $self->set("$view $this" => 1); # same as:
    $view->owner($this);

    $view->divid($divid);
    $self->screenthing($view);

    # add together
    push @$views, $view;
    if (@$views == 1) {
        $self->view_incharge($view);
    }

    # store it on the App
    my $oname = defined $this ? ref $this : "undef";
    if ($this->can("ports")) {
        unless ($this->ports) {
            $this->ports({});
        }
        $this->ports->{$viewid} = $view;
        $this->ports->{$alias} = $view if $alias;
    }

    return $view;
}

sub make_app_menu {
    my $self = shift;

    $self->get_view($self, "menu");

    $self->ports->{menu}->menu({
        tuxts_to_htmls => sub {
            my $self = shift;
            my $h = $self->hooks;
            my $i = $h->{i} ||= 0;
            say "Doing some $self, tuxts=".@{$self->tuxts};
            for my $s (@{$self->tuxts}) {
                my $object = $s->{value};
                $s->{value} = ref $object;
                unless (ref $object) {
                    say "Object unref: ".ddump($object);
                    use Carp;
                    confess ;
                }
                $s->{origin} = $object;

                if (ref $object && $object->can('menu')) {
                    my $menu = $object->menu(); # we don't clobber this hash?
                    delete $menu->{'.'};
                    $s->{value} = "$object";
                    $s->{value} =~ s/^(\w+).+$/$1/sgm;
                
                    # generate another Texty for menu items
                    # catch their <spans> and add to our value
                    my $inner = new Texty($self->hostinfo->intro, $self->view, [ keys %$menu ], {
                        tuxts_to_htmls => sub {
                            my $self = shift;
                            my $i = $h->{i} || 0;
                            for my $s (@{$self->tuxts}) {
                                delete $s->{top};
                                delete $s->{left};
                                $s->{class} = 'menu';
                                $s->{style} .= random_colour_background();
                            }
                        },
                        notakeover => 1,
                    });
                    $s->{inner} = $inner;
                    $s->{value} .= join "", @{$inner->htmls || []};
                    say ref $object." buttons: ".join ", ", @{ $inner->lines };
                }
                
                $s->{style} = random_colour_background();
                $s->{class} = 'menu';
                $s->{origin} = $object;
            }
        },
    });


    $self->update_app_menu();
}

sub random_colour_background {
    my ($rgb) = join", ", map int rand 255, 1 .. 3;
    return "background: rgb($rgb);";
}

sub update_app_menu {
    my $self = shift;
    my @fings = grep /^[A-Z]\w+$/ && !/View/, keys %$data;
    my @items;
    for my $f (@fings) {
        say "$f";
        my $a = $self->get($f);
        for my $app (@$a) {
            if ($app->can('menu')) {
                push @items, $app;
            }
        }
    }

    $self->ports->{menu}->menu->replace(\@items);
}

sub event {
    my $self = shift;
    my $menuv = $self->ports->{menu};
    $menuv->{menu}->event(@_);
}
    

sub menu {
    my $self = shift;
    return {
        blah => sub {
            $self->send_all;
        },
    };
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

sub get_ghost { # ways & wormholes for an object (the google?)
    my $self = shift;
    my $this = shift; # Travel or something

    my $ghost = new Ghost($self->hostinfo->intro, $this);
    
    # Way also something big to join up to (!)
    # it looks like the fuzz of how you want to act while Travelling. yay.
    # which is just the place to join to liquified language
    # there may be more structure through/around a list of lingos we hard code for now
    # it's a tube with no phases yet, just "select ways" and misc chewing
    # just saw Enlightenment, which I absolutely must ignore for now.
    # it's instant babylon competing for all I know.
    # I write on facebook for now: Craig Steve

    # we eat all the ways and fire their hooks through our flow
    # so expression can be ordered more by theme, not scattered over variation
    # anyway this gets stored somehow and edited in codemirror, via Codo?

    my $name = ref $this;
    if (!$name) {
        die "load_ghost need to lookup ghosts for $this";
    }
    $this->{ways} = []; # should be hostinfoways replacement maneuvre
    push @{$this->{ways}}, map { new Way($this->hostinfo->intro, LoadFile($_)) } glob "ghosts/$name/*";

    for my $w (@{$this->{ways}}) {
        for my $c (@{$w->{chains}}) {
            $c->{way} ||= $w;
        }
    }

    # default tip of the ghost is this most definite 0
    $ghost->{wormhole} = new Wormhole($this->hostinfo->intro, LoadFile("wormholes/$name/0"));
    # and then they build 1s in easily controllable Ghost Pyramids
    # where layers can be injected in space anywhere without breaking the fabric of it
    # right now time is not something we can flop out anywhere, depending on what we're going for
    # take that morality
    
    return $ghost
}

sub get {
    my ($self, $i) = @_;
    $data->{$i};
}
sub getapp {
    my ($self, $i) = @_;
    $self->get($i)->[0];
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

sub arrive {
    my $self = shift;
}


sub error {
    my $self = shift;
    my $e = {@_};
    say "\nError: ".ddump($e);
    $self->flood($e);
}

sub make_floodzone {
    my $self = shift;

    $self->get_view($self, "flood");
    $self->flood($self->getapp("Lyrico"));
}

sub flood {
    my $self = shift;
    my $thing = shift;

    my $flood = $self->ports->{flood};
    my $done = 0;
    if ($flood) {
        say "Flood: ".ddump($thing);
            my $travel = $flood->{travel};
            my $wormhole;
            ($wormhole) = $travel->travel($thing); # grep '.-.travel' -R * # like an art student game
            $done++;
            say "WOM HOLEY".ddump($travel->{ghost}->{wormhole});
            $wormhole->appear($flood);
            $done++;
        if ($@) {
            say "!!!!!\nError ".($done == 1 ? "makin" : "rendering")." a wormhole! $@!!!!!\n";
        }
        $@ = "";
    }
    if ($done < 2) {
        say "--- Flood Travel fucked up, doing it here"; # leaders delivering reality turds
        say ddump($thing);
        return;
    }
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

sub loadghost {
    my $self = shift;
    my $ghost = shift;
    $ghost->{wormhole} = new Wormhole($self->hostinfo->intro);
}

# as a chain, this is a new object coming into the web
# might want to spawn some intuition...
sub duction {
    my $self = shift;
    my $new = shift;
    my ($name) = split '=', ref $new;

    my $thiss = $self->get($name) || $self->set($name, []);
    unshift @$thiss, $new;

    #my $uuids = $self->get("$name"."->uuid") || $self->set("$name"."->uuid", []);
    #unshift @$uuids, make_uuid();
    $new->{huid} = make_uuid();

    return $self;
}

# make a number bigger than the universe...
sub make_uuid {
    UUID::generate(my $uuid);
    UUID::unparse($uuid, my $stringuuid);
    $stringuuid =~ s/^(\w+)-.+$/$1/s;
    return $stringuuid;
}

sub grap { # joiney thing, the lie that won't die... maybe it checks data and this->{k} they seem parallel
    my $self = shift;
    my $left = shift;
    my $right = shift;
    if (ref $right) {
        ($left, $right) = ($right, $left);
    }
    my $name = ref $left;
    $name || die "non ref on join $left$right";

    my $i = $self->get_this_it($left);
    if (!defined($i)) {
        die "not findo $left".ddump({soome=>$data});
    }
    my $set = $self->get("$name$right");
    if (!$set) {
        die "not findo $name$right";
    }
    $set->[$i];
}

sub get_this_it { # find it amongst itselves
    my $self = shift;
    my $this = shift;
    my $ah = $self->get(ref $this);
    say "Every $this: ".ddump($ah);
    my $i;
    for my $a (@$ah) {
        return $i if $a eq $this;
        $i++;
    }
    die "no findo ".ref($this)." i i i i i i $this";
    return undef;
}

1;
