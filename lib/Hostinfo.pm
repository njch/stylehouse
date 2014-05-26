package Hostinfo;
use strict;
use warnings;
use Mojo::Base 'Mojolicious::Controller';
use Scriptalicious;
use Mojo::IOLoop;
use IO::Async::Loop::Mojo;
use IO::Async::Stream;
use UUID;
use Scalar::Util 'weaken';
use Time::HiRes 'gettimeofday', 'usleep';
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


    # here we want to graph things out real careful because it is how things get around
    # the one to the many
    # apps can be multicasting too
    # none of these workings should be trapped at this level
    # send it out there and get the hair on it
    if (!$self->who) {
        # got a push from stylhouse
        push @{ $self->for_all }, $message;
        $self->send_all(); # TRACTOR this with the view
        #say "Websocket Multi Loaded: $short";
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

    my $short = $message if length($message) < 200;
    $short ||= substr($message,0,23*5)." >SNIP<";
    
    say "send\t\t". $short unless $short =~ /#proc_list'\)\.(css|append)/;
    
    $god->{tx}->send({text => $message});
}

sub send_all {
    my $self = shift;
    my $messages = $self->for_all;
    #say "Sending ".(0+@$messages)." messages";
    for my $message (@$messages) {
        my $gods = $self->get('gods');
        for my $god (@$gods) {
            $self->god_send($message, $god);
        }
    }
    #say "Done.";
    $self->for_all([]);
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

# handy stuff shall call review() etc (if the browser can accept that "whatsthere" is "too hard")
}

sub god_enters {
    my $self = shift;
    my $mojo = shift;
    my $msg = shift;
    my $tx = $mojo->tx;
    # someone, anyone
    say "\n\n\n\n\nGod enters";
    say "";
    say "$msg";
    say "";
    my $exist = $self->find_god($tx);
    if ($exist) {
        say "$exist->{address} returns";
        $self->who($exist);
    }
    else {
        $self->new_god($tx);
    }
}

sub furnish_god {
    my $self = shift;

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

sub dkeys {
    return map { "$_ => ".(ref $data->{$_}) } keys %$data;
}

sub view_incharge {
    my $self = shift;
    my $view = shift;
    my $old = $self->get('tvs/'.$view->divid.'/top');
    $self->set('tvs/'.$view->divid.'/top', $view);
}

sub reload_views {
    my $self = shift;
    # state from client?

    my $tops = $self->grep('tvs/.+/top');
    my @tops = values %$tops;
    my @names = keys %$tops;
    return say " no existing views" unless @names;
    say " resurrecting views: ".ddump(\@names);

    my ($ploked, $floozal) = ([], []);
    for my $view (@tops) {
        push @{ $view->{floozal} ? $floozal : $ploked }, $view;
    }
    for my $view (@$ploked, @$floozal) { # is divid its after
        $view->takeover();
    }
}



sub app_menu_hooks {
    my $self = shift;
    return {
        tuxts_to_htmls => sub { # TODO leaks several \n to STDOUT somewhere... bisect this whole business some day
            my $self = shift;
            my $h = $self->{hooks};
            my $i = $h->{i} ||= 0;

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
                    my $menu = {%{ $object->menu() }};
                    delete $menu->{'.'};
                    $s->{value} = "$object";
                    $s->{value} =~ s/^(\w+).+$/$1/sgm;
                
                    # generate another Texty for menu items
                    # catch their <spans> and add to our value
                    my $inner = new Texty($self->hostinfo->intro, $self->view, [ sort keys %$menu ], {
                        tuxts_to_htmls => sub {
                            my $self = shift;
                            my $i = $h->{i} || 0;
                            for my $s (@{$self->tuxts}) {
                                $s->{style} .= random_colour_background();
                            }
                        },
                        class => "menu",
                        nospace => 1,
                        notakeover => 1,
                        event => sub {
                            my $self = shift;
                            my $event = shift;
                            my $id = $event->{id};
                            for my $s (@{ $self->{tuxts} }) {
                                if ($s->{id} eq $id) {
                                    return $self->{owner}->event($event, $object, $s->{value});
                                }
                            }
                            say ddump($self);
                            die "no such thjing (inside $object) $id";
                        },
                    });
                    $inner->{owner} = $self;
                    $s->{inner} = $inner;
                    $s->{value} .= join "", @{$inner->htmls || []};
                    $s->{html} = 1;
                    say ref $object." buttons: ".join ", ", @{ $inner->lines };
                }
                
                $s->{style} = random_colour_background()."border: 5px solid black;";
                $s->{class} =~ s/data/menu/g;
                $s->{origin} = $object;
            }
        },
        class => "menu",
        nospace => 1,
        event => sub {
            my $self = shift;
            my $event = shift;
            my $object = shift;
            my $submenu = shift;
            my $id = $event->{id};
            
            if (!$object) {
                for my $s (@{ $self->{tuxts} }) {
                    if ($s->{id} eq $id) {
                        $object = $s->{origin};
                        last;
                    }
                }
            }
            if (!$submenu) {
                $submenu = ".";
            }
            if ($object->can('menu') && $object->menu->{$submenu}) {
                say "Hostinfo appmenu passing event ($id) to $object->{id} ->menu->{'$submenu'}";
                $object->menu->{$submenu}->($event);
            }
            else {
                say ddump($self);
                die "$self->{id} $self->{view}->{divid} cannot route $id -> $object $submenu";
            }
        },
    };
}

sub update_app_menu {
    my $self = shift;

    unless ($self->{appmenu}) {
        $self->create_view($self, "appmenu",
            "width:98%; background: #333; color: #afc; font-family: serif; bottom:0px; z-index:5; position: fixed;",
            before => "#body :first",
            "menu",
        );
        $self->{appmenu}->text->add_hooks(
            $self->app_menu_hooks()
        );
    }
    
    my @fings = grep $_ eq "0" || /^[A-Z]\w+$/ && !/View/ , keys %$data;
    my @items;
    for my $f (@fings) {
        my $a = $self->get($f);
        $a = [$a] unless ref $a eq "ARRAY";
        for my $app (@$a) {
            next if $app->{avoid_app_menu};
            if ($app->can('menu')) {
                push @items, $app;
            }
        }
    }

    $self->{appmenu}->{extra_label} = "appmenu";
    $self->{appmenu}->text->replace([@items]);
}

sub random_colour_background {
    my ($rgb) = join", ", map int rand 255, 1 .. 3;
    return "background: rgb($rgb);";
}

sub event {
    my $self = shift;
    my $menuv = $self->{appmenu};
    say "Hostinfo passing probable menu action to $menuv->{id} $menuv->{menu}";
    $menuv->{text}->event(@_);
}
# this is where human attention is (before this text was in the wrong place)
# it's a place things flow into sporadically now
# but it's a beautiful picture of the plays of whatever
# thanks to the high perfect babel of the #perl
# I think my drug is hash and perl and everything
sub get_goya {
    my $self = shift;

    my $stuff = $self->grep('tvs');

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

# TODO bullshit! doesn't keep trying to read further appendages
#        close_on_read_eof => 0,

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


sub get_view { # TODO rip this out
    my $self = shift;
    my $this = shift;
    my $viewid = shift;
    my $alias = shift;
    ($alias, $viewid) = ($viewid, $alias) if $alias;

    my ($divid) = $viewid =~ /^(.+)_?/;

    my $view = $self->create_view($this, $divid, undef, "not-on-object");

    if ($this->can("ports")) {
        unless ($this->ports) {
            $this->ports({});
        }
        $this->ports->{$viewid} = $view;
        $this->ports->{$alias} = $view if $alias;
    }
}

sub accum {
    my $self = shift;
    my $ere = shift;
    my $at = shift;
    $self->get($ere) || $self->set($ere, []);
    push @{$self->get($ere)}, $at;
}

sub create_view {
    my $self = shift;
    new View(
        $self->intro, @_
    );
}

sub init_flood {
    my $self = shift;

    my $f = $self->{flood} = $self->create_view($self, "flood",
        "width:".420*1.14."px; background: #8af; border: 4px solid gray; height: ".420*2.34."px; overflow: scroll;"
    );
    my $fm = $f->spawn_ceiling(
        "flood_ceiling",
        "width: ".420*1.14."px; height: 60px;background: #301a30; color: #afc; font-weight: bold;",
        "fixed",
    );

    $fm->text([], {
        tuxts_to_htmls => sub {
            my $self = shift;
            for my $s (@{$self->tuxts}) {
                $s->{style} = random_colour_background();
                $s->{class} = 'menu';
            }
        },
        spatialise => sub {
            { top => 1, left => 1, horizontal => 40, wrap_at => 1200 }
        },
    });

    $fm->text->replace([("FLOOD")x7]);

    $self->{floodzy} = $f->spawn_floozy(
        floodzy => "width:420px;  background: #44ag30; color: black; height: 100px; font-weight: bold;",
    );
    $self->{hi_error} = $f->spawn_floozy(
        hi_error => "width:420px;  background: #ff9988; color: #030; height: 420px; font-weight: bold;",
    );
    $self->{hi_error} = $f->spawn_floozy(
        hi_info => "width:420px;  background: #afc; color: #44ag39; height: 420px; font-weight: bold;",
    );

    return $f
}

sub route_floozy {
    my $self = shift;
    return $self->{floodzy};
}

# grep '.-.travel' -R * # like an art student game
sub flood {
    my $self = shift;
    my $thing = shift;
    my $floozy = shift;

    $self->init_flood() unless $self->{flood};

    my $from = join ", ", (caller(1))[0,3,2];
    say "flood from: $from";

    $floozy ||= $self->route_floozy($from);
    say "floozy: $floozy->{divid}";

    $floozy->{extra_label} = $from;


    $thing = ddump($thing) unless ref \$thing eq "SCALAR";
    if (ref \$thing eq "SCALAR") {
        my $lines = [split "\n", $thing];
        my $texty = $floozy->text;

        $texty->replace($lines);

        #$texty->{max_height} ||= 1000;
        $texty->fit_div;
        
        if ($self->{flood}->{latest} && $self->{flood}->{latest} ne $floozy) {
            $self->send("\$('#$self->{flood}->{ceiling}->{divid}').after(\$('#$floozy->{divid}'));");
        }
        $self->{flood}->{latest} = $floozy;
    }
    elsif (0) {
        my $wormhole;
                                        eval { $wormhole = $floozy->travel($thing); };
        if ($@) {
            $self->error(
                "flood travel error" => $@,
                Thing => $thing,
                Travel => ddump($floozy->travel),
            );
        }
        else {
                                            eval { $wormhole->appear($floozy) };
            if ($@) {
                $self->error(
                    "flood wormhole appear error" => $@,
                    Thing => $thing,
                    Travel => ddump($floozy->travel),
                );
            }
        }
    }
}

sub snooze {
    my $self = shift;
    return Time::HiRes::usleep(shift || 5000);
}
sub hitime {
    my $self = shift;
    return join ".", time, (gettimeofday())[1];
}
sub timer {
    my $self = shift;
    my $time = shift || 0.2;
    Mojo::IOLoop->timer( $time, @_ );
}

sub enlogform {
    my $self = shift;

    my $e = [@_];

    my $from = [];
    my $back = 5;
    for my $b (1..$back) {
        $b += 1; # error + this sub
        push @$from, grep { (!/Mojo::Server::SandBox/)..0 } join " ", (caller($b))[0,3,2]; # package, subroutine, line
    }

    return [ hitime(), $from, $e ];
}

sub info {
    my $self = shift;
    
    my $error = $self->enlogform(@_);
    say "\n   infotangent! ".ind("    ", ddump($error->[1]->[0]));
    say "Error reads: ".ddump($error->[2]);
    $self->throwlog("errors", "hi_error", $error);
}
sub error {
    my $self = shift;
    
    my $error = $self->enlogform(@_);
    say "\n   infotangent! ".ind("    ", ddump($error->[1]));
    say "\nError from ".ddump($error->[1]);
    say "Error reads: ".ddump($error->[2]);
    $self->throwlog("errors", "hi_error", $error);
}

sub throwlog {
    my $self = shift;
    my $accuwhere = shift;
    my $tryappenddivid = shift;
    my $error = shift;

    $self->accum($accuwhere, $error);
    
    if (my $fl = $self->get("tvs/$tryappenddivid/top")) {
        $self->flood(ddump($error), $fl);
    }
}

sub ind { "$_[0]".join "$_[0]\n", split "\n", $_[1] }


use YAML::Syck;
sub ddump {
    my $thing = shift;
    my $ind;
    return
        join "\n",
        grep {
            !( do { /^(\s+)hostinfo:/ && do { $ind = $1; 1 } }
            ...
            do { /^$ind\S/ } )
        }
        "",
        grep !/^     /,
        split "\n", Dump($thing);
}

sub intro {
    my $self = shift;
    return sub {
        my $other = shift;
        $other->{hostinfo} = $self;
        $self->duction($other);
    };
}

# as a chain, this is a new object coming into the web
# might want to spawn some intuition...
sub duction {
    my $self = shift;
    my $this = shift;

    $this->{huid} = make_uuid();
    my $ref = ref $this;
    $self->accum($ref, $this);

    if (my $r = $self->tvs->{$ref}) {
        $self->accum('tvs', $this);
        $ref = $r;
    }

    if ($this->{owner}) {
        $ref = "$ref-".(ref $this->{owner});
    }

    $this->{id} = "$ref-$this->{huid}";

    return $self;
}

sub tvs {
    my $self = shift;
    $self->get("tvs/shortref") || do {
        $self->set("tvs/shortref", { Texty => "t", View => "v" });
    };
}

sub tv_by_id {
    my $self = shift;
    my $id = shift;
    $id =~ s/^(\w+-\w+).*$/$1/ ||
        say join "\n", qw{EVENT ID THING LOOKUP Got}, "a weird id: $id", "we shall try";

    for my $tv (@{$self->get('tvs')}) {
        if ($tv->{id} eq $id) {
            return $tv;
        }
    }
    return;
}

# make a number bigger than the universe...
sub make_uuid {
    my $stringuuid = secret();
    $stringuuid =~ s/^(\w+)-.+$/$1/s;
    return $stringuuid;
}

sub secret {
    UUID::generate(my $uuid);
    UUID::unparse($uuid, my $stringuuid);
    return $stringuuid;
}

sub claw {
    my $self = shift;
    my $event = shift;
    say "Claw!";
    return 0 unless exists $self->{claws}->{$event->{claw}};
    say "Claw exists";
    
    my $sub = delete $self->{claws}->{$event->{claw}};
    say "Doing Claw";
    $sub->($event);
    say "Claw Done!";
    return 1;
}
sub claw_add {
    my $self = shift;
    my $sub = shift;
    my $sec = secret();
    $self->{claws} ||= {};
    $self->{claws}->{$sec} = $sub;
    say "Claw added: $sec";
    return $sec;
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
    say "\n\nEvery $this: ".ddump($ah);
    my $i;
    for my $a (@$ah) {
        return $i if $a eq $this;
        $i++;
    }
    die "no findo ".ref($this)." i i i i i i $this";
    return undef;
}

1;
