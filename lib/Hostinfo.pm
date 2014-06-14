package Hostinfo;
use strict;
use warnings;
use Mojo::Base 'Mojolicious::Controller';
use Mojo::ByteStream 'b';
use Scriptalicious;
use Mojo::IOLoop;
use IO::Async::Loop::Mojo;
use IO::Async::FileStream;
use HTML::Entities;
use UUID;
use Scalar::Util 'weaken';
use Time::HiRes 'gettimeofday', 'usleep';
use View;
use Term::ANSIColor;
use Digest::SHA 'sha1_hex';
use File::Slurp;
use utf8;
use Encode qw(encode_utf8 decode_utf8);

our $data = {};

has 'ports';

has 'for_all';
has 'who'; # spawners of websocket activity
sub send {
    my $self = shift;
    my $message = shift;

    if (length($message) > ($self->{tx_max} || 300000)) {
        die "Message is bigger (".length($message).") than max websocket size=".$self->{ts_max}
        # TODO DOS fixed by visualising {ts} and their sizes
            ."\n\n".substr($message,0,300)."...";
    }

    if ($message =~ /\n/) {
        warn "Message contains \\n";
    }


    # here we want to graph things out real careful because it is how things get around
    # the one to the many
    # apps can be multicasting too
    # none of these workings should be trapped at this level
    # send it out there and get the hair on it
    $self->elvis_send($message);
}
sub JS {
    my $self = shift;
    my $js = shift;
    $js =~ s/\n/ /sg;
    $self->send($js);
}

sub elvis_send {
    my $self = shift;
    my $message = shift;
    my $elvis = shift;
    $elvis ||= $self->who;
    if (!$elvis) {
        say "NO INDIVIDUAL TO send $message";
    }

    my $short = length($message) < 200 ?
        $message
        :
        '('.substr(enhash($message),0,8).') '
        .substr($message,0,23*9)." >SNIP<";
    
    if (-t STDOUT) {
        print colored("< send\t\t", 'blue');
        print colored($short, 'bold blue'), "\n";
    }
    else {
        say "< send\t\t$short";
    }
    
    unless ($elvis->{tx}) {
        say "All Elvi:";
        $self->elvi();
        my ($nelvis) = grep {$_->{tx}} values %{ $data->{elviss} };
        if ($nelvis) {
            say "Found a way to $nelvis->{address}";
        }
        else {
            say "No way to send to $elvis->{address} anymore!";
        }
        $elvis = $nelvis;
    }
    $elvis->{tx}->send($message);
}
sub elvi {
    my $self = shift;
    map { say " -$_->{i} $_->{id}\t\t$_->{address}" } sort { $a->{i} <=> $b->{i} } values %{ $data->{elviss} };
}
sub elvis_connects {
    my $self = shift;
    my $mojo = shift;
    my $tx = $mojo->tx;
    
    my $max = $tx->max_websocket_size;
    $self->{tx_max} ||= $max;
    unless ($max >= $self->{tx_max}) {
        $self->{tx_max} = $max; # TODO potential DOS
    }

    my $elviss = $self->gest(elviss => {});

    my $new = {
        id => "Elvis-".make_uuid(),
        address => $tx->remote_address,
        max => $tx->max_websocket_size,
        tx => $tx,
        i => $self->{elvii}++,
    };

    say "A New Elvis from $new->{address} appears";
    $elviss->{$new->{id}} = $new;
    $self->{who} = $new;

    $mojo->stash(elvisid => $new->{id});

    if (scalar(keys %$elviss) > 1) {
        say " Elvis is taking over!";
        $_->{tx} && $_->{tx}->finish for values %$elviss;
        `touch $0`;
        sleep 3;
    }

    $self->{first_elvis} ||= $new;

    say "All Elvi:";
    $self->elvi();

    return $new
# handy stuff shall call review() etc (if the browser can accept that "whatsthere" is "too hard")
}
sub elvis_enters {
    my $self = shift;
    my $sug = shift;
    my $mojo = shift;
    my $msg = shift;
    my $tx = $mojo->tx;

    my $eid = $mojo->stash('elvisid'); 
    say "Elvis enters with stash: ".($eid||"undef");
 
    if (-t STDOUT) {
        print colored("recv >\t\t", 'red');
        print colored($msg, 'bold red'), "\n";
    }
    else {
        say "recv >\t\t$msg";
    }

    if (my $elvis = $self->get('elviss')->{$eid}) {
        if ($elvis ne $sug) {
            say "Elvis found by stash is not elvis passed: $sug->{address} to $elvis->{address}";
        }
        if ($elvis ne $self->{who}) {
            say "Elvission: $self->{who}->{address} to $elvis->{address}";
        }
        $self->{who} = $elvis;
    }
    else {
        die "Cannot find elvis: $eid";
    }
}
sub elvis_gone {
    my $self = shift;
    say "Elvis is Gone.";
    $self->elvis_leaves(@_);
}

sub elvis_leaves {
    my $self = shift;
    my $mojo = shift;
    my $code = shift;
    my $reason = shift;

    my $eid = $mojo->stash('elvisid'); 
    say "Elvis had stash: ".($eid||"undef");
    if (my $elvis = $self->get('elviss')->{$eid}) {
        say "Goes $elvis->{address}";
        delete $elvis->{tx};
    }
    else {
        die "Cannot find elvis: $eid\n"."Remote address: ".$mojo->tx->remote_address;
    }
    if ($code || $reason) {
        say "  reason: ".($code||'?').": ".($reason||'?');
    }
    $self->{who} = $self->{first_elvis};
# could unset $who, demand views specify how to multicast
# leave it open
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
sub ignorable_mess {
    my $self = shift;
    my $mess = shift;
    my $dig = enhash($mess);
    my $iggy = $self->gest('ignorable_messs', {});

    if ($iggy->{$dig}) {
        say "Something to ignore: $dig";
        return;
    }

    $iggy->{$dig} = 1;
    $self->timer(0.2, sub { delete $iggy->{$dig} });

    return 0;
}
sub enhash {
    return sha1_hex(encode_utf8(shift))
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
            if ($object && $object->can('menu') && $object->menu->{$submenu}) {
                say "Hostinfo appmenu passing event ($id) to $object->{id} ->menu->{'$submenu'}";
                $object->menu->{$submenu}->($event);
            }
            else {
                say ddump($self);
                say "$self->{id} $self->{view}->{divid} cannot route $id ->";
                say "Object: $object" if $object;
                say "submenu: $submenu" if $submenu;
            }
        },
    };
}
sub update_app_menu {
    my $self = shift;

    unless ($self->{appmenu}) {
        $self->flood->spawn_floozy($self, "appmenu",
            "width:98%; background: #333; color: #afc; font-family: serif; height: 4em;", undef, undef, 'menu'
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
    say "Hostinfo event, probably appmenu}";
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

sub tail_file { shift->stream_file(@_, "just_tail") }
sub stream_file {
    my $self = shift;

    my $st = {
        filename => shift,
        linehook => shift,
        lines => [],
    };
    my $tail = shift;
    $st->{tail} = $tail if defined $tail;
    $st->{hook_diffs} = sub {
        my ($diffs, $st) = @_;
        my ($ino, $ctime, $size) =
            (stat $st->{filename})[1,10,7];
        
        my $fh = $st->{handle}; # try finish off the old one
        while (<$fh>) {
            my $l = clean_text($_);
            push @{$st->{lines}}, $l;
            $st->{linehook}->($l);
        }
        close $fh;
        my $samei = 0;
        if ($size > $st->{size}) {
            my @whole = `cat $st->{filename}`;
            my $whole = join "", @whole;
            my $new = join("", @{$st->{lines}});
            if ($whole ne $new) {
                $samei = scalar @whole;
            }
        }

        open(my $anfh, '<', $st->{filename})
            or die "cannot open $st->{filename}: $!";

        my $i = 0;
        while (<$anfh>) {
            if ($samei == 0) {
                my $mark = "==== ~!";
                $st->{linehook}->($mark);
            }
            unless ($samei-- > 0) {
                my $l = clean_text($_);
                push @{$st->{lines}}, $l;
                $st->{linehook}->($l);
            }
        }

        $st->{handle} = $anfh;
        ($st->{ino}, $st->{ctime}, $st->{size}) = 
            (stat $st->{filename})[1,10,7];
    };
    push @{$self->{file_streams} ||= []}, $st;

    $self->watch_files();
    
    return $st;
}
sub clean_text {
    my $self = shift;
    my $l = shift;
    return b($l)->encode("UTF-8");
}
sub watch_files {
    my $self = shift;
    my $forever = shift;

    if ($forever || !$self->{watching_files_aleady}) {
        $self->timer(0.5, sub {
            $self->{watching_files} = time;
            $self->{watching_files_aleady} = 0;
            $self->watch_files("forever!");
        });
    }
    $self->{watching_files_aleady} = 1;

    for my $st (@{ $self->{file_streams} }) {
        my ($ino, $ctime, $size) =
        (stat $st->{filename})[1,10,7];

        my @diffs;
        if (!defined $st->{size}) {
            $st->{size} = $size;
            $st->{ctime} = $ctime;
            $st->{ino} = $ino;
        }
        else {
            push @diffs, "Size: $size < SHRUNKEN  $st->{size}" if $size < $st->{size};
            push @diffs, "ctime: $ctime != $st->{ctime}" if $ctime != $st->{ctime};
            push @diffs, "inode: $ino != $st->{ino}" if $ino != $st->{ino};
        }
        
        if (@diffs) {
            say "$st->{filename} has been REPLACED or something:";
            say "    ".join("    ", @diffs)
        }
        
        if ($st->{lines}) {
            
            unless ($st->{handle}) {
                open(my $fh, '<', $st->{filename})
                    or die "cannot open $st->{filename}: $!";
                # TODO tail number of lines $st->{tail}
                while (<$fh>) {
                    unless (defined $st->{tail}) {
                        my $l = clean_text($_);
                        push @{$st->{lines}}, $l;
                        $st->{linehook}->($l);
                    }
                }
                $st->{handle} = $fh;
            }
            
            if (@diffs) {
                $st->{hook_diffs}->(\@diffs, $st);
            }
            
            if ($size > $st->{size}) {
                say "$st->{filename} has GROWTH";
                my $fh = $st->{handle};
                while (<$fh>) {
                    my $l = clean_text($_);
                    push @{$st->{lines}}, $l;
                    $st->{linehook}->($l);
                }
                $st->{size} = (stat $st->{filename})[7];
            }
            elsif ($size == $st->{size}) {
            }
            else {# size < $st->size means file was re-read for @diffs
            }
            
        }

        push @diffs, "Size: $size > > >  $st->{size}" if $size > $st->{size};
        
        if (@diffs) {
            say "$st->{filename} has change:";
            say "    ".join("    ", @diffs)
        }
        
        if (my $gs = $st->{ghosts}) {
            if (@diffs) {
                my $gr = $self->{ghosts_to_reload} ||= do {
                    $self->timer(0.3, sub { $self->reload_ghosts });
                    {};
                };
                while (my ($gid, $gw) = each %$gs) {
                    for my $wn (keys %$gw) {
                        $gr->{$gid}->{$wn} = 1;
                    }
                }
            }
        }
        else { die "something$size > $st->{size})  else?" }
        
        ($st->{ino}, $st->{ctime}, $st->{size}) = 
            (stat $st->{filename})[1,10,7];
    }
}
sub reload_ghosts {
    my $self = shift;
    my $gr = delete $self->{ghosts_to_reload};
    
    while (my ($gid, $gw) = each %$gr) {
        my $ghost = $self->get($gid);
        say "reload ghost: $ghost->{id}";
        die "NO Ghostys" unless $ghost;
        $ghost->load_ways(keys %$gw);
    }
}
sub watch_ghost_way {
    my $self = shift;
    my $ghost = shift;
    my $name = shift;
    my $f = { map { $_ => 1 } glob "ghosts/$name/*" };
    
    say "Going to watch $name for $ghost->{id}";
    
    for my $est (@{$self->{file_streams}}) {
        if (delete $f->{$est->{filename}}) {
            my $ghosts = $est->{ghosts};
            my $gw = $ghosts->{$ghost->{id}} ||= {};
            $gw->{$name} = 1;
        }
    }
    for my $file (keys %$f) {
        my $st = {
            filename => $file,
            ghosts => { $ghost->{id} => { $name => 1 } },
        };
        push @{$self->{file_streams}}, $st;
    }
    
    $self->watch_files();
}
sub get {
    my ($self, $i) = @_;
    $data->{$i};
}
sub gest {
    my $self = shift;
    my ($k, $v) = @_;
    $data->{$k} ||= $v;
}
sub getapp {
    my ($self, $i) = @_;
    my $as = $self->get($i);
    warn "no such app: $i" if !$as;
    $as->[0] if $as;
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
    
    return $self->{ground}->spawn_floozy(@_);
}
sub screen_height {
    my $self = shift;
    my $sc = shift;
    $self->set("screen/width" => $sc->{x});
    $self->set("screen/height" => $sc->{y});
}

sub init_flood {
    my $self = shift;

    $self->{horizon} = $data->{horizon};
    new View($self->intro, $self, "sky",
        "height:$self->{horizon}; background: #CCFFFF; width: 100%; overflow: scroll; position: absolute; top: 0px; left: 0px; z-index:3;"
    );
    new View($self->intro, $self, "ground",
        "width: 100%; height: 100%; background: #A65300; overflow: scroll;position: absolute; top: $self->{horizon}; left: 0px; z-index:-1;"
    );
    my $f = $self->create_view($self, "flood",
        "width: 42%; min-width:509.188px; background: #8af; height: 666%; overflow: scroll;position: absolute; left: 0px; z-index:-1;"
    );
    my $fm = $f->spawn_ceiling(
        "flood_ceiling",
        "width: ".420*1.14."px; height: 12px; background: #301a30; color: #afc; font-weight: bold;",
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

    $fm->text->replace([("FLOOD")x1]);

    $self->{floodzy} = $f->spawn_floozy(
        floodzy => "width:420px;  background: #44ag30; color: black; height: 100px; font-weight: bold;",
    );
    $self->{hi_error} = $f->spawn_floozy(
        hi_error => "width:100%; border: 2px solid white; background: #B24700; color: #030; height: 1em; font-weight: bold; overflow-x: scroll;",
    );
    $self->{hi_info} = $f->spawn_floozy(
        hi_info => "width: 50%; border: 2px solid white; background: #99CCFF; color: #44ag39; height: 1em; font-weight: bold; position: fixed; bottom: 0px; right: 0px; opacity: 0.7;",
    );

    return $f
}

# grep '.-.travel' -R * # like an art student game
sub flood {
    my $self = shift;
    my $thing = shift;
    my $floozy = shift;

    $self->init_flood() unless $self->{flood};

    if (!defined $thing && !defined $floozy) {
        return $self->{flood}
    }

    my $from = join ", ", (caller(1))[0,3,2];

    $floozy ||= $self->{floodzy};
    say "floozy: $floozy->{divid}    from $from";

    $floozy->{extra_label} = $from;


    $thing = encode_entities(ddump($thing)) unless ref \$thing eq "SCALAR";

    my $lines = [split "\n", $thing];
    my $texty = $floozy->text;

    $texty->replace($lines);

    #$texty->{max_height} ||= 1000;
    $texty->fit_div;
    
    if ($floozy->{divid} ne "hi_error" && $self->{flood}->{latest} && $self->{flood}->{latest} ne $floozy) {
        $self->send("\$('#$self->{flood}->{ceiling}->{divid}').after(\$('#$floozy->{divid}'));");
    }
    $self->{flood}->{latest} = $floozy;
}

sub ravel {
    my $self = shift;
    my $travel = shift;
    my $thing = shift;
    my $floozy = shift;

    my $wormhole;
    start_timer();
                                    eval { $wormhole = $travel->travel($thing) };

    my $travel_exec = "->travel in ".show_delta();
    $self->info("$travel_exec");

    return $self->error(
        "flood travel error" => $@,
        Travel => ddump($travel),
    ) if $@;



    return $self->error(
        "no wormhole!?",
        Travel => ddump($travel),
    ) if !$wormhole;



                                        $wormhole->appear($floozy) ;

    my $womholy_exec = "wormhole->appear in ".show_delta();
    $self->info("$womholy_exec");
    
        if ($@) {
            $self->error(
                "flood wormhole appear error" => $@,
                Wormhole => 1,#ddump($wormhole),
            );
        }
}

sub travel {
    my $self = shift;
    my $thing = shift;
    my $floozy = shift;

    $self->init_flood() unless $self->{flood};

    my $from = join ", ", (caller(1))[0,3,2];
    say "Hostinfo->travel from: $from";

    $floozy ||= $self->{ra};
    say "floozy: $floozy->{divid}";

    $floozy->{extra_label} = $from;

    my $travel = $floozy->travel();

    $self->ravel($travel, $thing, $floozy);

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

    my @from;
    my $b = 1; # past last couple
    while (1) {
        my $from = join " ", (caller($b))[0,3,2];# package, subroutine, line
        push @from, $from;
        last if $from =~ /^Mojo/; 
        $b++;
    }

    return [ hitime(), \@from, $e ];
}
sub info {
    my $self = shift;
    
    my $info = $self->enlogform(@_);
    $self->throwlog("Info", "infos", "hi_info", $info);
}

sub error {
    my $self = shift;
    
    my $error = $self->enlogform(@_);
    $self->throwlog("Error", "errors", "hi_error", $error);
}
sub throwlog {
    my $self = shift;
    my $what = shift;
    my $accuwhere = shift;
    my $divid = shift;
    my $error = shift;

    $self->accum($accuwhere, $error);

    my $string = 
        join("\n",
            $error->[0],
            
                (map { "    - $_" } reverse @{$error->[1]}),
            join("\n\n\n", map { ref $_ ? ddump($_) : "$_" } @{$error->[2]}),
        );

    say "$what =>\n$string";
    if (my $fl = $self->get("tvs/$divid/top")) {
        $self->flood($string, $fl);
    }
    $self->send("\$('#$divid').removeClass('widdle');");
}

use YAML::Syck;
sub ddump {
    my $thing = shift;
    my $ind;
    return
        join "\n",
        grep {
            1 || !( do { /^(\s*)hostinfo:/ && do { $ind = $1; 1 } }
            ...
            do { /^$ind\S/ } )
        }
        "",
        grep !/^       /,
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

    if ($this->{owner} && 0) {
        $ref = "$ref-".(ref $this->{owner});
    }

    $this->{id} = "$ref-$this->{huid}";
    $self->set($this->{id}, $this);

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
        $id =~ s/^(\w+-\w+).*$/$1/ || do {
            $self->error("EVENT ID THING LOOKUP Got a weird id", $id);
        };
    say "ID : $id";

    for my $tv (@{$self->get('tvs')}) {
        if ($tv->{id} eq $id) {
            return $tv;
        }
    }
    if (my $tv = $self->get('tvs/'.$id.'/top')) {
        return $tv;
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
sub slurp {
    my $self = shift;
    my $file = shift;
    say "Hostinfo: slurping $file";
    
      open my $f, $file || die "O no $!";
    binmode $f, ':utf8';
    my $m = join "", <$f>;
    close $f;
    $m;
}
sub spurt {
    my $self = shift;
    my $file = shift;
    my $stuff = shift;
    say "Hostinfo: spurting $file (".length($stuff).")";
      open my $f, '>', $file || die "O no $!";
    binmode $f, ':utf8';
    print $f $stuff;
    close $f;
    system("grep ' sub' $file")    ;
}


1;
