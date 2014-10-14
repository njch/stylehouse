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
use lib 'zrc/lib';
use Redis;

our $data = {};
${^WIDE_SYSTEM_CALLS} = 1;
sub new {
    my $H = bless {}, shift;
    #$self->set('0', $self);
    $H->{for_all} = [];
    $H->{name} = 'Њ';
    my $r = $H->{r} = Redis->new(
        server => 'localhost:8888',
        reconnect => 7,
        every => 1_000_000,
    );
    $H->{r}->{gest} = sub {
        my ($k, $make) = @_;
        my $c = $r->get($k);
        return ref \$c eq "SCALAR" ? fixutf8($c) : $c if $c;
        $c = $make->();
        $r->set($k => $c);
        return $c;
    };
    
    $Ghost::H =
    $Travel::H =
    $Wormhole::H =
    $Codo::H =
    $Codon::H =
    $Git::H =
    $Way::H = $H;



    $H->{G} = $H->TT($H)->G;
    $Ghost::G0 = $H->TT("Ghost")->G("G");
    $Ghost::G0->w('fresh_init');
    $Ghost::G0->w('any_init');
    
    
    $H->{underworld} = 1; # our fate's the most epic shift ever
    # SED name is styleblah, $style as far above is blah. layers peel everywhere.

    # get rid of this with Base.pm... or something
    # see what's there in all different ways
    # get the language
    # de-particulate
    # roller coaster

    # start git torrent
    # do it all

    # $0 has become a runtime


    # it's just about putting enough of it by itself so it makes sense
    # urgh so simple
    # when you stop trying the poetry builds itself into the language
    # almost
    # "I don't want to talk to you so you think"
    # it's not to produce thinking, it's a recognition
    # something more energetic

    # hold lots of websocket

    #jQuery.Color().hsla( array )
    
    push @{ $H->{file_streams} }, {
        filename => 'stylehouse.pl',
        touch_restart => 1,
    };
    return $H
}
sub TT {
    my $self = shift;
    my @from = @_;
    @from || die "WTF H::TT NO FROM";
    say "H Making Travel ". join ", ", map { Ghost::gpty($_) } @from;
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
sub send {
    my $self = shift;
    my $m = shift;
    if ($m =~ /\n/) {
        die "Message contains \\n:\n$m\n\n";
    }
    $self->{G}->w(send_Elvis => {m => $m});
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
sub enhash {
    return sha1_hex(shift)
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
        my $r = eval { $H->{G}->mess($what, [@_]) };
        if ($@) {
            eval { $H->{G}->timer(0.1, sub {
                $H->error("G mess error while throwing a $what: $@");
             }) };
            $@ = '';
        }
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
        join("\n",map { "    - $_" }
        grep { !/Ghost Ghost::__ANON__ | Ghost \(eval\)/ } @{$error->[1]}),
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
  return shift if @_ == 1;
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

