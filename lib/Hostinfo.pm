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
use Digest::SHA;
use File::Slurp;
use utf8;
use Encode qw(encode_utf8 decode_utf8 is_utf8);
use Data::Dumper;
use YAML::Syck;
use JSON::XS;
sub sha1_hex { Digest::SHA::sha1_hex(encode_utf8(shift)) }
our $data = {};
${^WIDE_SYSTEM_CALLS} = 1;
sub new {
    my $self = bless {}, shift;
    #$self->set('0', $self);
    $self->{for_all} = [];
    $self->{name} = 'Њ';
    
    $Lyrico::H = $self;
    $Ghost::H = $self;
    $Travel::H = $self;
    $Wormhole::H = $self;
    $Codo::H = $self;
    $Codon::H = $self;
    $Git::H = $self;
    $Way::H = $self;



    $self->{G} = $self->TT($self)->G;
    $Ghost::G0 = $self->TT("Ghost")->G("G");
    $Ghost::G0->w('fresh_init');
    $Ghost::G0->w('any_init');
    
    push @{ $self->{file_streams} }, {
        filename => 'stylehouse.pl',
        touch_restart => 1,
    };

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
    my $way = shift;
    # TODO
    my @Gs =
        grep { $_->{way} eq "$way" }
        
        @{$self->get('Ghost')};
        
    die "H::Gf 1<".scalar(@Gs)."   w $way" if @Gs > 1;
    $self->Say("\nH::Gf NOTHING nothing!   w $way") unless @Gs;
    
    shift @Gs;
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
        say " restarting...";
        $self->{G}->w('re/exec');
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
    
    return 0 if $self->ignorable_mess($msg);
    
    if (-t STDOUT) {
        print colored("recv >\t\t", 'red');
        print colored($msg, 'bold red'), "\n";
    }
    else {
        say "recv >\t\t$msg";
        $self->Info("recv >", $msg);
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
    
    return 1;
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
        $self->{G}->_0(sing => {
            block_for => 0.1,
            name => "iggyprint",
            code => sub {
                print colored(" IGNORE MESS    ", 'red') for 1..5;
                say "";
            }
        });
        return 1;
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
        "ܤ" => sub {
            `touch /s/stylehouse.pl`;
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
        my ($ino, $ctime, $mtime, $size) =
        (stat $st->{filename})[1,10,9,7];

        my @diffs;
        if (!defined $st->{size}) {
            $st->{size} = $size;
            $st->{ctime} = $ctime;
            $st->{mtime} = $mtime;
            $st->{ino} = $ino;
        }
        else {
            push @diffs, "Size: $size < $st->{size}" if $size < $st->{size};
            push @diffs, "ctime: $ctime != $st->{ctime}" if $ctime != $st->{ctime};
            push @diffs, "modif time: $mtime != $st->{mtime}" if $mtime != $st->{mtime};
            push @diffs, "inode: $ino != $st->{ino}" if $ino != $st->{ino};
        }
        
        if (@diffs) {
            $self->Say("$st->{filename} CHANGED: ".join("   ", @diffs));
            say "$st->{filename} has been REPLACED or something:";
            say "    $_" for @diffs;
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
        elsif ($st->{touch_restart} && @diffs) {
            $self->{G}->w('re/exec');
        }
        elsif (@diffs) {
            die "something $st->{filename}\n".join("\n", @diffs)."\n\n";
        }
        
        
        $st->{size} = $size;
        $st->{ctime} = $ctime;
        $st->{mtime} = $mtime;
        $st->{ino} = $ino;
    }
}
sub watch_git_diff {
    my $self = shift;
    
    my @diff = `git diff`;
    my $d = {};
    my $f;
    for (@diff) {
        if (/^diff --git "?a\/(.+?)"? "?b\/.+"?/) {
            $f = $1;
        }
        else {
            $d->{$f} .= $_
        }
    }
    while (my ($f, $D) = each %$d) {
        $d->{$f} = enhash($D);
    }
    for my $f (keys %$d) {
        delete $d->{$f}
            if $f =~ /^ghosts/;
    }
    unless (exists $self->{last_git_diff}) {
        say "H watch_git_diff first time";
        $self->{last_git_diff} = $d;
        return;
    }
    
    my $od = $self->{last_git_diff} ||= {};
    $od = { %$od };
    while (my ($f, $n) = each %$d) {
        my $o = delete $od->{$f};
        if (!$o || $n ne $o) {
            say join("  <>  ", ($f)x38);
            $self->{G}->w('re/exec');
        }
    }
    for my $f (keys %$od) {
        say join("  <  >  ", ($_)x28) for $f;
        $self->{G}->w('re/exec');
    }
    $self->{last_git_diff} = $d;
    # ZIPPING!? accum?
}
sub reload_ghosts {
    my $self = shift;
    my $gr = delete $self->{ghosts_to_reload};
    
    while (my ($gid, $gw) = each %$gr) {
        my ($ghost) = grep { $_->{id} eq $gid }
            @{$self->get("Ghost")};
        say "reload ghost: $ghost->{name}";
        die "NO Ghostys" unless $ghost;
        $ghost->load_ways(keys %$gw);
    }
}
sub watch_ghost_way {
    my $self = shift;
    my $ghost = shift;
    my $name = shift;
    my $files = shift;
    my $f = { map { $_ => 1 } @$files };
    
    #say "Going to watch $name for $ghost->{id}";
    
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

sub accum {
    my $self = shift;
    my $ere = shift;
    my $at = shift;
    push @{$self->gest($ere, [])}, $at;
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

    return [ hitime(), $self->stack(3), [@_] ];
}
sub stack {
    my $self = shift;
    my $b = shift;
    $b = 1 unless defined $b;
    
    my @from;
    while (my $f = join " ", (caller($b))[0,3,2]) {
        last unless defined $f;
        my $surface = $f =~ s/(Mojo)::Server::(Sand)Box::\w{24}/$1$2/g
            || $f =~ m/^Mojo::IOLoop/
            || $f =~ m/^Mojolicious::Controller/;
        $f =~ s/(MojoSand\w+) (MojoSand\w+)::/$2::/;
        push @from, $f;
        last if $surface; 
        $b++;
    }
    return [@from];
}
sub info {
    my $self = shift;
    $self->throwlog("Info", @_);
}
sub Info { 
    my $self = shift;
    $self->throwlog("Info", @_);}
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
    my $H = shift;
    my $what = shift;
    
    if ($H->{_future}) {
        my $te = $@;
        $@ = "";
        my $r = $H->{G}->mess($what, [@_]);
        $@ = $te;
        if ($r && $r eq "yep") {
            return;
        }
    }
    
    my @E;
    for my $b (@_) {
        if (ref $b eq "Way") {
            push @E, "Way: $b->{name}";
            push @E, ( map { " ` ".Ghost::ghostlyprinty("NOHTML", $_) } @{$b->{thing}});
            push @E, $b->{Error} if $b->{Error};
        }
        else {
            push @E, Ghost::ghostlyprinty("NOHTML", $b)
        }
    }
    my $error =
        [ hitime(), $H->stack(2), [@E] ];
    
    $H->keep_throwing($what, $error);
}
sub keep_throwing {
    my $self = shift;
    my $what = shift;
    my $error = shift;
    
    my @context = (
        $error->[0],
        join("\n",map { "    - $_" } @{$error->[1]}),
    );
    @context = () if $what eq "Say" || $what eq "Info";
    
    my $string = join("\n\n",
        @context,
        @{$error->[2]},
    );
    $string = "\n$string\n";

    print colored(ind("$what  ", $string)."\n", $what eq "Error"?'red':'green');
    if ($string =~ /DOOF/) {
        $self->JS("\$('#mess').animate({'max-width': '51%'}, 1200);");
    }
    $string = encode_entities($string);
    $string =~ s/'/'/g;
    $string =~ s/\\/&bsol;/g;
    $string =~ s/\n/&NewLine;/g;
    return $self->error("Recusive error messaging, check console") && sleep 3
        if $string =~ /amp;amp;amp;/;
    $self->{throwings}->{$what} || $self->timer(0.1, sub { $self->throwlog_throw });
    $self->{throwings}->{$what} = $string;
}
sub throwlog_throw {
    my $self = shift;
    my $th = delete $self->{throwings};
    while (my ($what, $string) = each %$th) {
        $self->JS("\$('#mess').removeClass('widdle');"
        ."\$('#$what').removeClass('widdle').fadeOut(30).html('$string')"
        .".fadeIn(70).scrollTo({top:'100%',left:'0%'}, 30);");
    }
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
    my $maxdepth = 3;
    if (@_ && $thing =~ /^\d+$/) {
        $maxdepth = $thing;
        $thing = shift;
    }
    $Data::Dumper::Maxdepth = $maxdepth;
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

sub make_uuid {
    my $stringuuid = secret();
    $stringuuid =~ s/^(\w+)-.+$/$1/s;
    return $stringuuid;
}
sub secret { # make a number bigger than the universe
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

sub fixutf8 {
  for (@_) {
    if (!is_utf8($_)) {
      $_ = decode_utf8($_); 
    }
  }
}
sub slurp {
    my $self = shift;
    my $file = shift;
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

