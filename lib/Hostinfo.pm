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
use YAML::Syck;
use JSON::XS;

our $data = {};
sub new {
    my $self = bless {}, shift;
    #$self->set('0', $self);
    $self->{for_all} = [];
    
    $Lyrico::H = $self;
    $Ghost::H = $self;
    $Travel::H = $self;
    $Wormhole::H = $self;
    $Codo::H = $self;
    $Codon::H = $self;
    $Git::H = $self;
    $Way::H = $self;

    $self->{GG} = $self->TT($self)->G;

    #jQuery.Color().hsla( array )
    return $self
}
sub TT {
    my $self = shift;
    my @from = @_;
    @from || die "WTF H::TT NO FROM";
    say "H Making Travel @from";
    return Travel->new($self->intro, @from);
}
sub Gf {
    my $self = shift;
    my $O = shift;
    my $way = shift;
    # TODO
    my @Gs = map { $_->{G} }
        grep { #$_->{O} eq $O TODO
        1 && $_->{G} && $_->{G}->{way} =~ /$way/ }
        @{$self->get('Travel')};
    if (@Gs > 1) {
        $self->error("H::Gf 1<".scalar(@Gs)."   $O->{name}     w $way", \@Gs, $self->get('Travel'));
    }
    $self->Say("\nH::Gf NOTHING nothing! $O->{name}     w $way") unless @Gs;
    shift @Gs;
}
sub init_flood {
    my $self = shift;

    $self->{horizon} = $data->{horizon};
    
    my $sky = new View($self->intro, $self, "sky",
        "height:$self->{horizon}; background: #00248F; width: 100%; overflow: scroll; position: absolute; top: 0px; left: 0px; z-index:3;"
    );
    my $Gsky = $self->TT($sky, $self)->G("Hostinfo/sky");
    $sky->{on_event} = sub {
        $Gsky->w("touch");
    };
    
    
    new View($self->intro, $self, "ground",
        "width: 100%; height: 100%; background: #A65300; overflow: none;position: absolute; top: $self->{horizon}; left: 0px; z-index:-1;"
    );
    my $f = $self->{ground}->spawn_floozy($self, "flood",
        "width: 42%; min-width:3em; background: #337921;"
        ." height: 100%; overflow: scroll;position: absolute; background-image: url(greencush.jpg); right:0px;z-index:-1;"
    );
    my $fm = $f->spawn_ceiling(
        "flood_ceiling",
        "width: 100%; margin:1em; height: 4.20em; background: #301a30; color: #afc; font-weight: bold;",
    );

    $self->{floodzy} = $f->spawn_floozy(
        floodzy => "width:100%;  background: #0000FF; color: black; height: 100px; font-weight: 7em;",
    );
    
    
    
    my $m = $sky->spawn_floozy(mess => "max-width:39%; right:0px; bottom:0px;"
        ."position:absolute; overflow: scroll; height:100%;"
        ."border: 2px solid white; z-index: 10; background: #B247F0; color: #030; font-weight: bold; ");
    $m->{on_event} = sub {
        $self->{GG}->doo("G mess Tw event(%\$ar)", {e=>\@_});
    };
    
    $m->spawn_floozy(
        Error => "width:100%; border: 2px solid white; background: #B24700; color: #030; font-weight: bold; overflow-x: scroll; white-space: pre; max-height: 100%;",
    );
    
    $m->spawn_floozy(
        Info => "width: 100%; overflow: scroll; border: 2px solid white; background: #99CCFF; color: #44ag39; font-weight: bold;  opacity: 0.7; z-index: 50; white-space: pre; max-height: 100%;",
    );
    
    $m->spawn_floozy(
        Say => "width: 100%; overflow: scroll; border: 2px solid white; background: #66FF66; color: #44ag39; font-weight: bold;  opacity: 0.7; z-index: 50; white-space: pre; max-height: 100%;",
    );
    
    $self->menu();
    $self->{floodmenu}->{Ш}->() if $data->{style} eq 'stylehouse';

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
    my $texty = $floozy->text;

    $thing = ddump($thing)
        unless ref \$thing eq "SCALAR";


    $texty->replace([$thing]);

    #$texty->{max_height} ||= 1000;
    $texty->fit_div;
    
    if ($floozy->{divid} ne "hi_error" && $self->{flood}->{latest} && $self->{flood}->{latest} ne $floozy) {
        $self->send("\$('#$self->{flood}->{ceiling}->{divid}').after(\$('#$floozy->{divid}'));");
    }
    $self->{flood}->{latest} = $floozy;
}
sub decode_message {
    my $self = shift;
    my $msg = shift;
    
    my $j;
    start_timer();
    
    `cat /dev/null > elvis_sez`;
    $self->spurt('elvis_sez', $msg);
    my $convert = q{perl -e 'use YAML::Syck; use JSON::XS; use File::Slurp;}
        .q{print " - reading json from elvis_sez";}
        .q{my $j = read_file("elvis_sez");}
        .q{print "! json already yaml !~?\n$j\n" if $j =~ /^---/s;}
        .q{print " - convert json -> yaml\n";}
        .q{my $d = decode_json($j);}
        .q{print " - write yaml to elvis_sez\n";}
        .q{DumpFile("elvis_sez", $d);}
        .q{print " - done\n";}
        .q{'};
    `$convert`;

    eval {
        $j = LoadFile('elvis_sez');

        while (my ($k, $v) = each %$j) {
            if (ref \$v eq "SCALAR") {
                $j->{$k} = decode_utf8($v);
            }
        }
    };
    say "Decode in ".show_delta();
    die "JSON DECODE FUCKUP: $@\n\nfor $msg\n\n\n\n"
        if $@;

    die "$msg\n\nJSON decoded to ~undef~" unless defined $j;
    return $j;
}
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
    if (ref $js) {
        use Carp;
        croak " \n\n\n\nTHIS:\n$js\nis not View" unless ref $js eq "View";
        my $jq = shift;
        $js = "\$('#$js->{divid}').$jq";
    }
    
    $js =~ s/\n/ /sg;
    $self->send($js);
}
sub elvis_send {
    my $self = shift;
    my $message = shift;
    my $elvis = shift;
    $elvis ||= $self->{who};
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
        ($elvis) = grep {$_->{tx}} values %{ $data->{elviss} };
        
        if ($elvis) {
            say "Found a way to $elvis->{address}";
        }
        else {
            say "No way to send to $elvis->{address} anymore!";
            return;
        }
    }
    $elvis->{tx}->send($message) if $elvis->{tx};
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

sub update_app_menu {
    my $self = shift;
    
    unless ($self->{appmenu}) {
        $self->{flood}->{ceiling}->spawn_floozy($self, "appmenu",
            "width:100%; background: #555; padding: 5px; color: #afc; font-family: serif; height: 4em;", undef, undef, 'menu'
        );
        $self->{appmenu}->text->add_hooks({
            class => 'menu',
            nospace => 1,
        });
    }
    
    my @fings = grep /^[A-Z]\w+$/ && !/View/ , keys %$data;
    my @items = $self;
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
    
    my @lines;
    for my $i (@items) {
        if ($i->can('menu')) {
            my $m = $i->menu();
            if (my $s = $m->{_spawn}) {
                $s->[1]->{class} ||= 'menu';
                $s->[1]->{nospace} ||= 1;
                push @lines, $m;
            }
            else {
                die "Oldskool menu: $i\n".ddump($m);
            }
        }
    }

    $self->{appmenu}->{extra_label} = "appmenu";
    $self->{appmenu}->text->replace([@lines]);
}
sub menu {
    my $self = shift;
    my $m = $self->{floodmenu} = {
        Ш => sub {
            $self->JS(
                "\$.scrollTo(\$('#ground').offset().top, 360);"
                ."\$('#ground').scrollTo(0, 360);"
            );
        },
    };

    return { _spawn => [
        [ sort keys %$m ], {
            event => {menu => $m},
            tuxtstyle => sub {
                my ($v, $s) = @_;
                $s->{style} .= "padding 5px; font-size: 35pt; "
                ."text-shadow: 2px 4px 5px #4C0000;"
            },
        }
    ] };
}
sub random_colour_background {
    my ($rgb) = join", ", map int rand 255, 1 .. 3;
    return "background: rgb($rgb);";
}
sub event {
    my $self = shift;
    my $ev = shift;
    $self->info("Hostinfo nothing todo with", $ev);
    #$self->info("hostinfo event, don't know what to do: $id", [$id, $id]);
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
        $self->{watching_files_aleady} = 1;
        $self->timer(0.5, sub {
            $self->watch_files("forever!");
        });
    }
    
    $self->watch_file_streams();
    $self->watch_git_diff();
}
sub watch_file_streams {
    my $self = shift;

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
sub watch_git_diff {
    my $self = shift;
    
    my @diff = `git diff`;
    my $d = {};
    my $f;
    for (@diff) {
        if (/^diff --git a\/(.+) b\/.+/) {
            $f = $1;
        }
        else {
            $d->{$f} .= $_
        }
    }
    while (my ($f, $D) = each %$d) {
        $d->{$f} = enhash($D);
    }
    my $od = $self->{last_git_diff};
    # ENGHOST
}
sub reload_ghosts {
    my $self = shift;
    my $gr = delete $self->{ghosts_to_reload};
    
    while (my ($gid, $gw) = each %$gr) {
        my ($ghost) = grep { $_->{id} eq $gid }
            @{$self->get("Ghost")};
        say "reload ghost: $ghost->{id}";
        die "NO Ghostys" unless $ghost;
        $ghost->load_ways(keys %$gw);
    }
}
sub watch_ghost_way {
    my $self = shift;
    my $ghost = shift;
    my $name = shift;
    my @files = -f "ghosts/$name" ? "ghosts/$name"
        : glob "ghosts/$name/*";
    my $f = { map { $_ => 1 } @files };
    
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
    
    if ($i =~ /^(\w+)-(........)$/) {
        return grep { $_->{huid} eq $2 } @{$self->get($1)};
    }
    
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
    push @{$self->gest($ere, [])}, $at;
}
sub deaccum {
    my $self = shift;
    my $ere = shift;
    my $at = shift;
    #$self->get($ere) || $self->set($ere, []);
    #push @{$self->get($ere)}, $at;
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
#    - Mojofbd0a371 Mojo::Server::SandBox::4826ff7dbcc5a7b1e294ecb4fbd0a371::dostuff 287

    my @from;
    my $b = 3;
    while (my $f = join " ", (caller($b))[0,3,2]) {
        last unless defined $f;
        my $surface = $f =~ s/(Mojo)::Server::(Sand)Box::\w{24}/$1$2/g
            || $f =~ m/^Mojo::IOLoop/;
        $f =~ s/(MojoSand\w+) (MojoSand\w+)::/$2::/;
        push @from, $f;
        last if $surface; 
        $b++;
    }

    return [ hitime(), \@from, $e ];
}
sub info {
    my $self = shift;
    $self->throwlog("Info", @_);
}
sub Info { shift->info(@_) }
sub error {
    my $self = shift;
    $self->throwlog("Error", @_);
}
sub Err { shift->error(@_) }
sub Say {
    my $self = shift;
    $self->throwlog("Say", @_);
}
    
sub throwlog {
    my $self = shift;
    my $what = shift;
    my $error = $self->enlogform(@_);

    $self->{saylimit} ||= 5;
    $self->{GG}->w("throwlog", {$what => $error})
        if $self->{GG} && $what eq "Say" && $self->{saylimit}-- > 0;

    my $string = join("\n", $error->[0],
        (map { "    - $_" } reverse @{$error->[1]}),
            join("\n\n", map { ref $_ ? wdump($_) : "$_" } @{$error->[2]}),
        );


    print colored(ind("$what  ", $string)."\n", $what eq "Error"?'red':'green');
    if ($string =~ /DOOF/) {
        $self->JS("\$('#mess').animate({'max-width': '80%'}, 500);");
    }
    $string = encode_entities($string);
    $string =~ s/'/\\'/g;
    $string =~ s/\n/\\n/g;
    $self->JS("\$('#mess').removeClass('widdle');");
    $self->JS("\$('#$what').removeClass('widdle').html('$string').scrollTo( '100%', 400);");
}
sub ind { "$_[0]".join "\n$_[0]", split "\n", $_[1] }
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
sub wdump {
    my $thing = shift;
    use Data::Dumper;
    $Data::Dumper::Maxdepth = 3;
    return join "\n", map { s/      /  /g; $_ } split /\n/, Dumper($thing);
}
sub intro {
    my $self = shift;
    return sub {
        my $other = shift;
        $self->duction($other);
    };
}

# as a chain, this is a new object coming into the web
# might want to spawn some intuition...
sub duction {
    my $self = shift;
    my $this = shift;
    
    $this->{hostinfo} = $self;

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
    
    $id =~ s/^(\w+-\w+).*$/$1/;
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
sub nah {
    my $self = shift;
    my $this = shift;
    say "DESTROYING EVERYTHING $this STOOD FOR";
    for my $OO (
        grep { $_->{O} ? $_->{O} eq $this
                    : $_->{owner} eq $this }
        map { @{$_} }
        map { $self->get($_) } "View", "Travel") {
        
        $OO->nah;
        $self->deaccum($this);
    }
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
    $file = decode_utf8($file);
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
    $file = encode_utf8($file);
      open my $f, '>', $file || die "O no $!";
    binmode $f, ':utf8';
    print $f $stuff."\n";
    close $f;
}


1;

