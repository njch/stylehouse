package Hostinfo;
use strict;
use warnings;
use Mojo::ByteStream 'b';
use Scriptalicious;
use Mojo::IOLoop;
use IO::Async::Loop::Mojo;
use IO::Async::FileStream;
use HTML::Entities;
use UUID;
use Scalar::Util 'weaken';
use Time::HiRes 'gettimeofday', 'usleep';
use Term::ANSIColor;
use Digest::SHA;
use File::Slurp;
use utf8;
use Encode qw(encode_utf8 decode_utf8 is_utf8);
use Data::Dumper;
use YAML::Syck;
use JSON::XS;
sub sha1_hex { Digest::SHA::sha1_hex(encode_utf8(shift)) }
sub enhash { sha1_hex(shift) }
sub dig { enhash(shift) }
use lib 'zrc/lib';
use Redis;

our $data = {};
${^WIDE_SYSTEM_CALLS} = 1;
sub new {
    my $pa = shift;
    my $p = shift;
    my $H = bless {%$p}, $pa;
    #$self->set('0', $self);
    $H->{for_all} = [];
    $H->{name} = 'Њ';
    
    lib_perc_H($H);
    
     #ouble
    $H->set('style', $H->{name}); # eventually to pick up a wormhole and etc.
    $H->set('sstyle', $H->{style}); # eventually to pick up a wormhole and etc
    
    $H->{G} = $H->TT($H)->G;
    
    $Ghost::G0 = $H->TT("Ghost")->G("G");
    $Ghost::G0->w('fresh_init');
    $Ghost::G0->w('any_init');
    
    $H->{G}->w('fresh_init');
    $H->{G}->w('any_init');
    
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
    return $H
}
sub lib_perc_H {
    my $h = shift;
    $Ghost::H =
    $Travel::H =
    $Wormhole::H =
    $Codo::H =
    $Codon::H =
    $Git::H =
    $Way::H = $h;
}

sub la { (`uptime` =~ /load average: (\S+),/)[0] }
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
    my $cb = shift;
    $self->{G}->w(send_Elvis => {m => " $m", cb => $cb});
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
sub random_colour_background {
    my ($rgb) = join", ", map int rand 255, 1 .. 3;
    return "background: rgb($rgb);";
}
sub event { die "Hostinfo sub event!"; }
sub grep {
    my $self = shift;
    my $regex = shift;
    return {
        map { $_ => $data->{$_} }
        grep /$regex/,
        keys %$data
    };
}

sub clean_text {
    my $self = shift;
    my $l = shift;
    return b($l)->encode("UTF-8");
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
sub get {
    my ($self, $i) = @_;
    
    if ($i =~ /^(\w+)-(........)$/) {
        return grep { $_->{uuid} eq $2 } @{$self->get($1)};
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
                say "G mess error while throwing a $what: $@";
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
    
    my @context = (
        grep { !/Ghost Ghost::__ANON__ |Ghost \(eval\)/ } @{$error->[1]},
    );
    @context = () if $what eq "Say" || $what eq "Info";
    my @f = @Ghost::F;
    for my $c (@context) {
        my $f = shift @f;
        say "$c ======== ". Ghost::gpty($f->{thing});
    }
    
    my $string = join("\n",
        @context,
        @{$error->[2]},
    );
    $string = "\n$string\n";
    print colored(ind("$what  ", $string)."\n", $what eq "Error"?'red':'green');
}
sub ind {
    "$_[0]".join "\n$_[0]", split "\n", $_[1]
}
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

    $this->{uuid} = make_uuid();
    my $ref = ref $this;
    $self->accum($ref, $this);

    if (my $r = $self->tvs->{$ref}) {
        $self->accum('tvs', $this);
        $ref = $r;
    }

    if ($this->{owner} && 0) {
        $ref = "$ref-".(ref $this->{owner});
    }

    $this->{id} = "$ref-$this->{uuid}";

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

