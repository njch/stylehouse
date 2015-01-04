package G;
our $H;
use strict;
use warnings;
use utf8;
use lib 'lib';
use feature 'say';
use YAML::Syck;
use Mojo::Pg;
use List::MoreUtils 'natatime';
use File::Slurp;
use JSON::XS;
use YAML::Syck;
use Scriptalicious;
use HTML::Entities;
use List::Util qw(first max maxstr min minstr reduce shuffle sum);
use List::MoreUtils qw(natatime uniq);
use Unicode::UCD 'charinfo';
# use Mojo::IOLoop::ForkCall; # see para
our $swdepth = 5;
our $T; # allele tower... not like so, again R above
our @F; # is Ring re subs from below 
our $G0;
our $db = 0;
our $MAX_FCURSION = 140;
our $NUM = qr/(?:(\d+(?:\.\d+)?) )/;
our $HASHC = "#"."c";
our $gp_inarow = 0;
my %D_cache;

# ^ curves should optimise away, accordion

#c to dry up

  sub ddump { H::ddump(@_) }
  sub wdump { H::wdump(@_) }

  # to go
  sub findO { my ($k, $o) = @_; grep { $_->{O} eq $k } @$o }

  sub slim {
      my ($f,$t,$c) = @_;
      ($f,$t,$c) = (40,40,$f) if !$t && !$c;
      $c = ($c=~/^(.{$t})/s)[0]."..." if length($c) > $f;
      $c
  }
  sub shtocss { 
      my $s = shift;
      return join "", map { "$_:$s->{$_};" } sort keys %$s if ref $s eq "HASH";
      return join ";", @$s if ref $s eq "ARRAY";
      return $s
  }
  sub ind { "$_[0]".join "\n$_[0]", split "\n", $_[1] }
  use Carp 'confess';
  use Term::ANSIColor; 
  use File::Find;

  our $Ly;
  our $_ob = undef;

sub new {
    my $G = shift;
    my (@ways) = @_;
    $G->{way} = join "+", @ways;
    $G->{name} = $G->{way};

    $G->{GGs} = [];
    my $ui = $G->{A}->{u}->{i};
    wish(G => $ui) || $ui eq $H || die "not G above? $G->{name} ".$ui->pi;
    $G->{O} = $ui;
    $G->{A}->umv('', 'G');
    $G->{A}->umk($H->{G}, 'Gs') if $H->{G};
    push @{$ui->{GGs}}, $G; # OGG
    push @{$H->{G}->{GGs}}, $G unless $ui eq $H->{G}; # OGG


    $G->load_ways(@ways);

    $G
}

sub gp {
    my $u = shift;
    return $u->pi if ref $u && ref $u ne 'HASH' && ref $u ne 'CODE'
        && ref $u ne 'ARRAY' && $u->can('pi');
    gpty($u);
}

sub sw {
    my $stuff = wdump($G::swdepth, @_>1?\@_:@_);
    return say "too early rto publich" if ! $H->{r};
    $H->{r}->publish('sw', $stuff);
    say "published wdump to sw from   $G::swdepth x ".length($stuff);
}

sub pi {
    my $G = shift;
    "G ".$G->{name};
}

sub deeby {
    my $G = shift;
    $G->{db} + $db > 0
}

sub throwlog {
    my $G = shift;
    my $what = shift;
    $H->{G}->w(throwlog => {what => $what, thing => [@_]});
}

sub susgdb {
    my $G = shift;
    my $t = $db;
    push @{$F[0]->{_after_do}}, sub { $db = $t };
    $db = -2;
}

sub gname {
    my $G = shift;
    my $g = shift;
    my $si = shift || 0;
    my $ush = "$g";
    my $may = $g->{name} || $g->{K} || $g->{id} if ref $g && $ush =~ /HASH/;
    $may ||= (0+keys %$g)."{" if ref $g eq "HASH";
    $may ||= "$g";
    $may =~ s/^(\w+)=HASH.*$/$1\{/;
    $may;
}

sub pint {
    my $w = shift; 
    $w && ref $w eq "Way" ? $w->pint : "ww:".join"",map { s/\s//sg; $_ } wdump(2,$w)
}

sub mess {
    my $G = shift;
    $H->{G}->w(mess => {what => shift, thing => shift}); # TODO say*
}

sub ghostlyprinty {
    $gp_inarow++;
    my $witcolour = sub { '<t style="color:#'.($_[1] || '8f9').';">'.shift.'</t>' };
    my $nohtml;
    if ($_[0] && $_[0] eq "NOHTML") {
        shift;
        $nohtml = 1;
        $witcolour = sub { shift };
    }

    my @t = @_;
    my @s;
    for my $t (@t) {
        if ($t && ref $t eq "ARRAY") {
            if ($gp_inarow > 5) {
                push @s, "ghostlyprinty recursion!";
                next;
            }
            push @s, map { "[".ghostlyprinty(($nohtml?("NOHTML", $_):($_))) } @$t;
        }
        elsif (ref $t) {
            push @s, $witcolour->(ref($t), "333;font-size:50%");
            my $name = gname($t);
            push @s, $witcolour->($name);
        }
        else {
            push @s, (defined $t ? $t : "~")
        }
    }
    $gp_inarow--;
    join "  ", @s
}

sub pty {
    my $t = shift;
    ref $t eq "Way" ? pint($t) : gpty($t)
}

sub gpty {
    ghostlyprinty('NOHTML',@_)
}

sub R {
    my $G = shift;
    $G->{A}->spawn(R => @_);
}

sub TRub {
    my $G = shift;
    my $a = {};
    my $R = $G->{R} ||= $G->{A}->spawn("R");
    # like du, vectors space out after $k
    #   for increment spacing over the braid

    # nah just chuck stuff in $a
    # everything should have more meaning than that
    my @a = @_;
    while (@a) {
        my ($k, $v) = (shift(@a), shift(@a));
        $R->loadup($a, $k, $v);
    }

    # 1

    # find u from K and B?
    my $u = $G->CsK({K=>$a->{i}->{K}});
    die "Not leading anywhere: ". wdump($a) unless $u;
    $u->from($a->{i});

    # etc
    $G->T({i => $u});
}

sub ob {
    my $G = shift;
    my $ob = $G->{_ob} || $_ob || return;

    my $s = $G->pyramid(@_);

    my $te = $@; $@ = "";
    my $to = $_ob; $_ob = undef;

    $ob->w(ob=>{s=>$s});

    $_ob = $to;
    $@ = $te;
}

sub Gf {
    my $G = shift;
    my $way = shift;
    # TODO $G or $S etc A 
    my @GGs =
      #sort { length($a->{way}) <=> length($b->{way}) } # cerated
      grep { $_->{way} =~ /$way/ } @{ $G->{GGs} };

    wantarray ? @GGs : shift @GGs;
}

sub HGf {
    $H->{G}->Gf(@_)
}

sub W {
    my $G = shift;
    $G->{W}
}

sub parse_babble {
    my $G = shift;

    my $eval = shift;

    my $AR = qr/(?:\[(.+?)\]|(?:\((.+?)\)))/;
    my $G_name = qr/[\/\w]+/;
    my $Gnv = qr/\$?$G_name/;

    # 5/9

    $eval =~ s/(Sw|ws) (?=\w+)/w \$S /sg;

    $eval =~ s/(Say|Info|Err) (([^;](?! if ))+)/\$H->$1($2)/sg;
    $eval =~ s/T (?=->)/->T() /sg;


    # 6/9 - motionless subway

    $eval =~ s/timer $NUM? \{(.+?)\}/\$G->timer($1, sub { $3 })/sg;
    $eval =~ s/waylay $NUM?(\w.+?);/\$G->timer("$1",sub { w $2; },"waylay $2");/sg;

    my $point = qr/[\w\$\/\->\{\}]*[\w\$\/\->\.\}]+/;

    my $alive = qr/\$[\w]*[\w\->\{\}]+/;

    my $dotha = qr/[A-Za-z_]\w{0,3}(?:\.[\w-]*\w+)+/;
    my $poing = qr/$alive|G:$point|$dotha/;

    my $sqar = qr/\[.+?\]|\(.+?\)/; 

    my $sur = qr/ if| unless| for/;
    my $surn = qr/(?>! if)|(?>! unless)|(?>! for)/;
    my $suro = qr/(?:$sur|(?>!$sur))/;

    while ($eval =~
    /\${0}($poing )?((?<![\$\w])w(?: ($poing))? ($point)( ?$sqar| ?$point|))($sur)?/sg) {
        my ($g, $old, $u, $p, $a, $un) = ($1, $2, $3, $4, $5, $6);

        if (!$g) {
            $g = '$G';
        }
        else {
            $g = ""
        }

        my @n;
        my $ne = ""; # hidden reverse
        ($ne, $a) = ($a, "") if $a =~ /^$sur$/;
        # ^ caught a bit of conditional syntax after w expr


        push @n, '%$ar' if $a =~ s/^[\(\[]\+ ?// || !$a;

        push @n, $a     if $a =~ s/^\(|\)$//sg;

        push @n, 
            map { my($l)=/\$(\w+)/;"$l => $_" } split /, */, $a

                        if $a =~ s/^\[|\]$//sg;


        my @e;
        push @e, qq["$p"];
        push @e, "{".join(", ",@n)."}";
        push @e, $u if $u;
        my $en = join ", ", @e;

        my $wa = $g."->w(".$en.")".$ne;


        #saygr " $old \t=>\t$wa \t\t\tg$g \tu$u \tp$p \ta$a \tun$un";

        $eval =~ s/\Q$old\E/$wa/          || die "Ca't replace $1\n\n in\n\n$eval";
    }

    # 8/9

    $eval =~ s/G!($Gnv)/G\.A->spawn(G => "$1")/sg;
    $eval =~ s/G-($Gnv)/\$G->Gf("$1")/sg;
    $eval =~ s/G:($Gnv)/HGf("$1")/sg;

    $eval =~ s/(?<!G)0->(\w+)\(/\$G->$1(/sg; 

    $eval =~ s/(?:(?<=\W)|^)([A-Za-z_]\w{0,3})((?:\.[\w-]*\w+)+)/"\$$1".join"",map {"->{$_}"} grep {length} split '\.', $2;/seg;


    $eval;
}

sub du {
    my $G = shift;
    my $a = shift;
    # how to get around the Objs' data
    my $s = $a->{s} ||= $G->dus();
    my $i = $a->{i};
    my $n = $a->{n};
    $a->{e} = 2 if !defined $a->{e};

    my $c = {};
    $a->{as} ||= [];
    die sw($a) if !defined $a->{i};
    push @{$a->{as}}, $a;
    $a->{ds} = [@{$a->{ds}||[]}, $a];

    return {} if @{$a->{ds}} > 12 || 2 < grep {ref $_->{i} && $_->{i} eq $i} @{$a->{as}};

    my $ref = ref $i;
    my $is = $s->{$ref} || $s->{default};
    $is ||= $s->{HASH} if "$i" =~ /^\w+=HASH\(/;
    $is ||= $s->{default} || return {};

    # $mustb
    # does HASH key importance if 0>e<1
    # travels every thing      if e>=1
    #                also      if 0.5<e<1
    # since it must want to know links by then
    # overthinking must be reached somehow
    # going over a line
    # at 5
    # how much is happened
    # sw is a channel
    # the way in the splat...

    # there's some more flipping around: TODO
    # an e mod possibly coming from mustb (missing part)
    # so some mustb key can e above 0.5 and see travel

    # could return somehow weighted graph, hmm
    # oldworld really doesn't like that idea
    # maybe if du was grabbed as more abstract chunks with A action
    # driving the new codons basically...

    # snapping branches off the concept of ^ for now

    # we sculpt data as fractions of energy that enlightens the 1-9 meanings
    # fuck binary

    # $an->{s}, etc can be modded as meaning builds down
    # but only for 
    # (separado until much future brings everything together)

    my $mustb = { map { $_ => 1 } split ',', $is->{mustb} } if $is->{mustb};

    for my $j ($is->{it}->($i)) {
        my $k = delete $j->{k};
        my $K = delete $j->{K};
        my $v = delete $j->{v};

        $j = {%$is, %$j};
        my $an = {%$a, i => $v};

        my $ohms = defined $j->{oh} ? $j->{oh} : 1;

        $an->{e} -= $ohms;

        my $rk = "$k $an->{e}";
        $c->{$rk} = $v;

        say join("", ("  ") x scalar(@{$a->{ds}}))
            ." $a->{e} - $ohms  $k\t $an->{e} \t\t ".gpty($v);

        if ($an->{e} >= 1 && ref $an->{i}) {
            my $cu = $G->du($an);
            while (my ($ku, $vu) = each %$cu) {
                my $nk = $k.$ku;
                next if grep { $_->($_, $an, $cu) } @{$s->{notZ}||[]};
                $c->{$nk} = $vu;
            }
        }
        elsif ($an->{e} > 0 && $an->{e} < 1 && $mustb && !$mustb->{$K}) {
            delete $c->{$rk};
        }
    }


    $c
}

sub dus {
    my $G = shift;
    my $h = {
      ARRAY => {
        it => sub {
          my $h = shift;
          my $i = 0;
          map { { k => "[".$i++, v => $_ } } @$h
        },
        oh => 0,
      },
      HASH => {
        it => sub {
          my $h = shift;
          map { { K=>$_, k=>"{".$_, v=>$h->{$_} } } sort keys %$h
        },
      },
    };
    my $an = sub {
        my $k = shift;
        my $i = $h->{$k} ||= {it => $h->{HASH}->{it}};
        %$i = (%$i, @_);
    };
    $an->(qw'A oh 0.2');
    $an->(qw'Ghost oh 0.8');
    $an->(qw'G oh 0.8');
    $an->(qw'W oh 0.8 mustb','id,hash,file,G');
    $h
}

sub F_delta {
    my $now = $H->hitime();
    my $then = $F[0]->{hitime};
    my $d = sprintf("%.3f",$now-$then);
    $d = $d<1 ? ($d*1000).'ms' : $d.'s';
}

sub inter {

    my $thing = shift;
    my $ki = ki($thing);
    $ki =~ s/^\s+//;
    $F[1]->{inter} ||= ".";
    $F[1]->{inter} .= "\n -{".$ki."}\n";
}

sub crankFun {
    my $G = shift;
    my $un = $G->crank(@_);
    # so a synapse would snake through something...
    # directly looking at a concept and exuding its energy pathway
    push @{ $F[0]->{_after_do} }, $un;
    return
}

sub crank {
    my $G = shift;
    my ($dial,$v) = @_;
    my $original = $G->{$dial};
    $G->{$dial} = $v;

    sub { $G->{$dial} = $original };
}

sub ki {
    my $ar = shift;
    my $s = "";
    if (!ref $ar || "$ar" !~ /HASH/) {
        confess "NOT HASH: $ar";
    }
    for my $k (sort keys %$ar) {
        my $v = $ar->{$k};
        $v = "~" unless defined $v;
        #$v = "( ".gname($v)." )" if ref $v;
        $s .= "   $k=$v";
    }
    $s
}

sub unico {
    my ($int, $wantinfo) = @_;
    my $h = sprintf("%x", $int);
    my @s = eval '"\\x{'.$h.'}"';
    push @s, charinfo($int) if $wantinfo;
    wantarray ? @s : shift @s
}

sub flatline {
    map { ref $_ eq "ARRAY" ? flatline(@$_) : $_ } @_
}

sub recur {
    my $G = shift;
    Mojo::IOLoop->recurring(@_);
}

sub wish {
    my $w = shift;
    my $i = shift;
    $w eq "W" ? ref $i eq "Wormhole" || ref $i eq "W" :
    $w eq "w" || $w eq "C" ? ref $i eq "Way" || ref $i eq "C" :
    $w eq "G" ? ref $i eq "Ghost" || ref $i eq "G" : die "wish $w $i";
}

sub saycol {
    my $colour = shift;
    print colored(join("\n", @_,""), $colour);
    wantarray ? @_ : shift @_
}

sub sayyl {
    saycol(bright_yellow => @_)
}

sub sayre {
    saycol(red => @_)
}

sub sayg {
    saycol(bright_green => @_)
}

sub saygr {
    saycol(green => @_)
}

sub saybl {
    saycol(bright_blue => @_) 
}

sub uiuS {
    my $G = shift;
    my ($u, $b) = @_;
    my $a = "S";
    my $ui = $u->{i} if $u->{i};

    for my $w ($ui, $u) {
        next if !$w;

        my $Gw = $w->{G}->findway($w->{K}) if $w->{Gw};

        for my $ww ($Gw, $w) {
            next if !$ww;
            next if !$ww->{$a};
            if ($ww->{$a}->{"${b}_D"}) {
                $G->Flab("got a $a $b _D  ", $u);
                my $some = $w->{G}->w("$a/${b}_D", {u=>$u}, $w);
                return $some if $some;
            }
            my $some = $ww->{$a}->{$b};
            return $some if $some;
        }
    }
}

sub GAK {
    my $G = shift;
    my ($K, $g) = @_;
    $g->{K} = $K;
    $G->{GG}->{$g->{K}} = $g;
}

sub sing {
    my $G = shift;
    my $p;
    $p->{name} = $G->{id}."/".shift;
    $p->{code} = shift;
    $p = {%$p, @_};
    my $name = $p->{name};
    my $code = $p->{code};

    my $si = $H->{G}->{singing} ||= {};
    return if $si->{$name} && $si->{$name}++;
    $si->{$name} = 1;

    my $after = $p->{block} || $p->{again} || 0.2;
    my $init = $p->{begin} || 0.001;

    $G->timer($init, sub {

        $G->timer($after, sub {
            my $splatter = delete $si->{$name};
            if ($splatter > 1 && $p->{again}) {
                $G->Flab("Sig reps $splatter... again!  $name");
                $G->sing($name, $code, %$p);
            }
        }, "sing-block        $name");

        $si->{$name} = 1;
        $code->();
    }, "pre-sing     $name");
}

sub ing {
    my $G = shift;
    my ($time, $ing, $w) = @_;
    $time && $ing || die " time&ing";

    my $name = $ing;
    $name .= $w->pint if $w;
    my $ingw = $G->nw(
        K=>"ing",
        name => $name,
        ing => $ing,
        time => $time,
    );
    say "create $ingw->{G}->{name} $ingw->{name} $time";
    $ingw->{w} = $w if $w;
    my $inga = $G->{ing}->{$name} ||= {};
    $_->{dead} = 1 for values %$inga;
    $inga->{$ingw->{id}} = $ingw;
    $G->ingo($ingw);
}

sub ingo {
    my $G = shift;
    my ($ingw) = @_;
    return say "ing $ingw->{name} $ingw->{id} deduped" if $ingw->{dead};
    return say "ing $ingw->{name} $ingw->{id} ui dead" if $ingw->{w} && $ingw->{w}->{dead};

    $G->w($ingw->{ing}, {}, $ingw->{w});

    my $time = $ingw->{w}->{e} if $ingw->{w} && $ingw->{w}->{e};
    $time ||= $ingw->{time};
    say "time $ingw->{G}->{name} $ingw->{name} $time";
    $G->timer($time, sub {
        $G->ingo($ingw);
    }, "ing $ingw->{name} $ingw->{id}");
}

sub ip {
    my $G = shift;
    my ($ip, $i) = @_;
    my $pass = 1;
    for my $I (keys %$ip) {
        $pass-- if $ip->{$I} ne $i->{$I};
    }
    $pass == 1
}

sub fs_glob {
    my $G = shift;
    my (@globs) = @_;
    my @list;
    for my $glob (@globs) {
        push @list, grep { defined }
            grep { $H->fixutf8($_) || 1 }
            grep { -f $_ } glob $glob;
    }
    return @list;
}

sub fs_find {
    my $G = shift;
    my (@dirs) = @_;
    my @list;
    File::Find::find(sub {
        my $na = $File::Find::name;
        $H->fixutf8($na);
        return unless -f $na;

        push @list, $na;
    }, @dirs);
    return @list;
}

sub jsq {
    my $G = shift;
    my @a = @_;
    for (@a) {
        s/\\/\\\\/g;
        s/'/\\'/g;
        s/\n/\\n/g;
    }
    wantarray ? @a : shift @a;
}

sub jssq {
    my $G = shift;
    my @a = @_;
    for (@a) {
        s/\\/\\\\/g;
        s/"/\\"/g;
        s/\\\\n/\\n/g;
        #s/\n/\\n/g;
    }
    wantarray ? @a : shift @a;
}

sub Stytog {
    my $G = shift;
    my ($u, $s) = @_;
    my @styles = split /\s+/, $u->{styles};
    if (grep { $_ eq $s } @styles) {
        @styles = grep { $_ ne $s } @styles
    }
    else {
        push @styles, $s;
    }
    $u->{styles} = join ' ', @styles;
    $G->w('v/ch', {u=>$u});
}

sub su {
    my $G = shift;
    my ($a) = @_;
    if (@_ > 1) {
        $a = {top => shift};
        $a->{cb} = pop;
        $a->{div} = shift || 7;
    }
    $a->{top} && $a->{cb} || die "wtf";
    my $D = $a->{cb};

    $H->{G}->w(subsc => $a); 
}

sub Flab {
    my $G = shift;
    wish(G=>$G) || die "send G";

    # like sa*
    # throw $S up little con tent # F jointed sa*
    # also like di, has this db vector
    # for punching out with helpful quality

    say join("", "$G->{db} + $db", ("_") x scalar(@F))."$G->{name}  $_[0]"
        if $G->deeby && $_[0] !~ /^\w\ Error/;

    my $a;
    $a->{name} = "f";
    $a->{stuff} = [@_];
    $a->{igGA} = 1;

    $G->pyramid($a);
}

sub fla {
    my $G = shift;
    $F[0]->{G}->Flab(@_);
}

sub ways {
    my $G = shift;
    grep { !$_->{_disabled} } @{$G->{ways}}
}

sub findway {
    my $G = shift;
    my $point = shift;
    my @w = grep { defined $_ } map { $_->find($point) } $G->ways;
    wantarray ? @w : shift @w;
}

sub anyway {
    my $G = shift;
    my $point = shift;
    my @a = grep { defined $_ } map { $_->find($point, 1) } $G->ways;
    wantarray ? @a : shift @a
}

sub load_ways {
    my $G = shift;
    my @ways = @_;
    $G->{ways} ||= [];
    $G->{wayfiles} ||= [];
    $G->{load_ways_count}++;

    my $ldw = [];
    while (defined( my $name = shift @ways )) {
        my @files;

        my $base = "ghosts/$name";
        push @files, $base if -f $base;
        push @files, grep { /\/\d+$/ }
            map { $H->fixutf8($_) } glob("$base/*");

        for my $file (@files) {
            # TODO pass an If object selector to 0->deaccum
            @{$G->{ways}} = grep { $_->{_wayfile} ne $file } @{$G->{ways}};
            $G->deaccum($G, wayfiles => $file);

            my ($w) = grep { $_->{_wayfile} eq $file } @{$G->{ways}};

            my ($wn) = $file =~ /ghosts\/(.+)$/;
            $wn ||= $file;
            my $nw = $G->nw(name=>$wn);
            $nw->{A}->umv('', 'way');
            $nw->load($file);

            say "G $G->{name} w+ $nw->{name}";
            push @{$G->{wayfiles}}, $file;
            push @{$G->{ways}}, $nw;
        }

        $G->{name} =~ s/\+$name// && warn "no wayfiles from $name" || die
        unless @files; # ^ dies if was first way name
    }

    return $G->w("load_ways_post") if !$G0;

    $G0 ->w("_load_ways_post", {S=>$G,w=>$G->{ways}});
}

sub di {
    # attaches meaning and dies

    # throwing back to D hopefully enriching

    # @_:
    #   bunch of vectors to topiarise the explotion
    #   bunch of data/messages

    my @vec;
    push @vec, shift while $_[0] =~ /^[\.\d]+$/;
    my $a = $F[0]->{di} = {};
    ($a->{mag}, $a->{dir}, $a->{etc}) = @vec;
    $a->{tip} = [@_];
    die @_;
}

sub Dm {
    my $G = shift;
    my $a = shift;

    if ($a->{D}) {
        die unless ref $a->{D} eq "CODE";
        return {evs=>"?????????????????", sub=>$a->{D}};
    }

    my $uuname = join " ",
        $G->{id},
        $H->dig($a->{bab}),
        $a->{point},
        " ar%".join(",",sort keys %{$a->{ar}}),
    ;        
    my $ha = $H->dig($uuname);
    die unless length($ha) == 40;

    my $Ds = $G0->{Dscache}->{$ha};
    return $Ds if $Ds;

    my $eval = $G->parse_babble($a->{bab}, $a->{point});

    my $ar = $a->{ar} || {};
    my $download = join("", map {
        'my$'.$_.'=$ar->{'.$_."}; "
        } keys %$ar)
        if %$ar;
    my $upload = join("", map {
        '$ar->{'.$_.'}=$'.$_."; "
        } keys %$ar)
        if %$ar;
      # there is
    my @warnings = ("no warnings 'experimental';");

    my $sub = "bollox";
    my $evs = 'sub { my $ar = shift; '.
    "@warnings $download\n".

    "my \@doo_return = (sub { \n\n$eval\n })->();\n"

    ."$upload"
    .'return @doo_return };';

    $sub = $G->Doe($evs, $ar);

    $@ = "nicht kompilieren!\n\n$@" if $@;

    $Ds = {evs=>$evs, sub=>$sub, ha=>$ha};

    if (!$@ && ref $sub eq "CODE") {
        $G0->{Dscache}->{$ha} = $Ds;
    }
    else {
        $a->{bungeval} = $evs;
    }
    $Ds
}

sub Doe {
    my $G = shift;
    my $D_eval_string = shift;
    my $ar = shift;
    return eval $D_eval_string;
}

sub D {
    my $G = shift;
    my $a;
    $a = shift;
    my $ar = $a->{ar} || {};

    die "RECURSION ".@F if @F > $MAX_FCURSION; 

    # also $a->{D} can be CODE, $Ds viv
    if (ref $a->{bab} eq "C") {
        my $b = $a->{bab};
        die unless $b->{K} eq "Disc";
        return $b->{G}->w('D', $a->{ar}, $b);
    }

    my $Ds = $G->Dm($a);
    $a->{Ds} = $Ds;
    my ($evs, $sub) = ($Ds->{evs}, $Ds->{sub});

    # TODO rewayen
    $a->{name} = "D";
    my $D = $G->Doming($a);

    $H->{sigstackend} ||= sub {
        local $@;
        eval { confess( '' ) };
        my @stack = split m/\n/, $@;
        shift @stack for 1..3; # hide above this sub, G eval & '  at G...';
        my @stackend;
        push @stackend, shift @stack until $stack[0] =~ /G::D/ || !@stack && die;
        s/\t//g for @stackend;

        # write on the train thats about to derail
        my $wall = $G::F[0]->{SigDieStack}||=[];

        push @$wall, \@stackend;
    };
    $H->{sigstackwa} ||= sub {
        return 1 if $_[0] =~ /^Use of uninitialized value/;
        my @loc = caller(1);
        sayre join "\n", "warn from ".$F[0]->{G}->{name}
            ."  way $F[0]->{point}"
            ."       at line $loc[2] in $loc[1]:", @_;
        return 1;
    };
    my @return;
    if (ref $sub eq "CODE" && !$@) {
        local $SIG{__DIE__} = $H->{sigstackend};
        local $SIG{__WARN__} = $H->{sigstackwa};
        eval { @return = $sub->($a->{ar}) }
    }

    $G->Done($D); # Ducks
    $D->{r} = [@return];


    return wantarray ? @return : shift @return
}

sub Doming {
    my $G = shift;
    my $a = shift;
    die if @_;

    my $s = $G->pyramid($a);

    unshift @F, $s;
    $s->{F} = [@F];

    return $s;
}

sub Done {
    my $G = shift;
    my $D = shift;
    sayre join"", ("BATS  ")x 23 if $F[0] ne $D;
    $D->{dolat} = $@ if $@;

    $_->() for @{$D->{_after_do}||[]};

    shift @F;

    $G->Duck($D) if $@;

    $_->() for @{$D->{_aft_etc_do}||[]};


    $D
}

sub Duck {
    my $G = shift;
    my $D = shift;
    my $evs = $D->{Ds}->{evs};
    my $ar = $D->{ar};


            my $DOOF; 
            my $first = 1 unless $@ =~ /DOOF/;

            $DOOF .= "DOOF $D->{K}".sprintf("%-24s",
                $G->{name}."  $D->{K}  ".($ar->{S} ? "S=".gpty($ar->{S}) :"")
            );
            $DOOF .= " w"." $D->{point}  ".join(", ", keys %$ar)."\n";

            $DOOF = "$D->{K}\n" if $D->{K} ne 'Dᣝ';


            if ($first) {
                my $x = $1 if $@ =~ /syntax error .+ line (\d+), near/
                    || $@ =~ /line (\d+)/;

                my $file = $1 if $@ =~ /at (\S+) line/;

                undef $file if $file && $file =~ /\(eval \d+\)/;
                undef $file if $file && !-f $file;

                my $code = $file ? $H->slurp($file) : $evs;

                my $eval = $G->Duckling($x, $code, $D);

                if (exists $D->{SigDieStack}) {
                    warn "MALTY SIGGI" if @{$D->{SigDieStack}} > 1;
                    $DOOF .= "\n";
                    my $i = "  ";
                    for my $s ( reverse flatline($D->{SigDieStack}) ) {
                        $DOOF .= "$i- $s\n";
                        $i .= "  ";
                    }
                }        
                $DOOF .= "\n$eval\n";
            }

            if ($first) {
                $DOOF .= ind("E    ", "\n$@\n\n")."\n\n";
            }

            if (!$first) {
                my $in = $D->{K} eq 'Dᣝ' ? "!   " : "";
                $DOOF .= ind($in, "$@")."\n";
            }
            if ($first) {
                $DOOF .= $H->ind('ar.', join "\n",
                    map{
                    "$_ = ".
                    #gp()
                    $ar->{$_}
                    }keys %$ar);
            }

            $D->{Error} = $DOOF;
            $@ = $DOOF;

            if (@F == 1) {
                sayyl "At top!";
                # send it away
                sayre $@;
                $@ = "";
                $_->() for @{$G0->{_aft_err_do}||[]};
            }
            else {
                die $@;
            }
}

sub Duckling {
    my $G = shift;
    my ($line, $code, $D) = @_;

    my $diag = "";
    my @code = split "\n", $code;
    my $whole = @code < 30;


    if ($code =~ /^sub \{ my \$ar = shift/
        && $code =~ /return \@doo_return \};/) {
        $line -= 2 if $line;
        shift @code for 1..2;
        pop @code for 1..2;
    }


    my $xx = 0;
    for (@code) {
        $xx++;
        if (!defined $line) {
            $diag .= ind("⊘  ", $_)."\n"
        }
        elsif ($xx == $line) {
            $diag .= ind("⊘  ", $_)."\n";

            my $bab = (split"\n",$D->{bab})[$line-2];
            if ($bab ne $_) {
                $diag .= ind("⊖r ", $bab)."\n";
            }
        }
        elsif (!$whole && $xx > $line-5 && $xx < $line+5) {
            $diag .= ind("|  ", $_)."\n"
        }
        elsif ($whole) {
            $diag .= ind("|  ", $_)."\n"
        }
    }

    $diag
}

sub timer {
    my $G = shift;
    my $time = shift || 0.001;
    my $D = shift;

    my $a;
    $a->{name} = "t";
    $a->{time} = $time;
    $a->{D} = $D; # maybe sub or Disc like thing
    $a->{stuff} = [@_];
    my $Dome = $G->Doming($a);

    Mojo::IOLoop->timer($time, sub {
        $G->comeback($Dome);
    });

    $G->Done($Dome);

    return $Dome;
}

sub para {
    my $G = shift;
    die "install it";
    # TODO get better paraphernalia
    # ram and cpus
    # new OS to get latest mojo things working in
    # such as this and Mojo::Redis2 for better eventing of sub
    my $fc = Mojo::IOLoop::ForkCall->new;
    $fc->run(
       sub {},
       ['arg', 'list'], 
       sub { my ($fc, $err, @return) = @_; ... }
    );
}

sub comeback {
    my $G = shift;
    my $Dome = shift;

    my $a;
    $a->{name} = 'r';
    $a->{from} = $Dome;
    my $Doing = $G->Doming($a);

    $G->D({D=>$Dome->{D}, toplevel=>1});

    $G->Done($Doing);

    sayre $@ if $@; # TODO toplevely
    $@ = "";
}

sub waystacken {
    my $G = shift;
    my $s = $G->pyramid(@_);
    push @{ $F[0]->{undies} ||= [] }, $s if @F;
    unshift @F, $s;
    $s->{F} = [@F],
    $G->ob("\\", $s);
    my $unway = sub {
        my @FF;
        if ($F[0] ne $s) {
            my $E = "BATS ";
            if (!grep {$_ eq $s} @F) {
                $E .= "self nowhere in \@F"
            }
            else {
                unshift @FF, shift @F until $FF[0] && $FF[0] eq $s || !@F;
                $E .= " - from $_->{name}\n" for shift @FF;
            }
            $H->error(BATS => $G->Flab($E, $s, [[@FF], [@F]]));
        }
        else {
            shift @F;
        }

        if ($@) {
            #$G->Flab("Stack Return Error", $s, $@);
            $s->{Error} = $@;
        }

        if ($s->{_after_do}) {
            $_->() for @{$s->{_after_do}};
        }

        my $te = $@; $@ = "";
        $G->ob("/", $s);
        $@ = $te;
        $s
    };
    wantarray ? ($unway, $s) : $unway;
}

sub nw {
    my $G = shift;
    my $C = $G->{A}->spawn('C');

    $C->from({@_}) if @_;
    # etc
    $C 
}

sub wayb {
    my $G = shift;
    my ($GG, $atu) = @_;

    $atu->{way} || die "needs a way".wdump($atu);

    my $suway = join "", map {"{$_"} split /\//, $atu->{way};

    $G->{R}->loadup($atu, "{hooks$suway", $atu);

    push @{$GG->{ways}}, $atu; # A etc
    # A drop old G+K+name
    # replay dep on perc state of origin $G
}

sub w {
    my $G = shift;
    my $point = shift; 
    my $ar = shift;
    my $S = shift; # some kinda C subject
    my $a = shift;
    my @ways;

    die wdump($ar) if $ar && ref $ar ne 'HASH';

    my $talk = "w\ $point";
    my $watch;

    if ($S) {
        $talk .= " S";
        if (ref $S eq "G") {
            $talk .= " G";
        }
        elsif (ref $S eq "C") {
            if (my $of = $S->{ofways}) { # TODO 
                @ways = @$of;
            }
            elsif ($S->{Gw}) {
                my $SG = $S->{G} || die "no way G!?";
                my $CodeK = $S->{Gw};
                $CodeK = $S->{K} if $CodeK eq "1";
                $point = "$CodeK/$point" unless $point =~ /^$CodeK/;
                if ($G eq $SG) {
                    @ways = $G->ways; # ------------------
                }
                else {
                    return $SG->w($point, $ar, $S); # G pass
                }
            }
            else {
                @ways = $S; #---------------------
            }
        }
        elsif (ref $S eq "R") {
            @ways = $S->{way};
            $G = $S->{G};
        }

        if (my $B = $S->{B}) {
            # we dont upload variables from B
            # change $B->{whatever} to set
            # good verboz code clarity for scheming
            %$ar = (%$ar, %$B, B => $B);
        }
        my $uu = ref $S eq 'R' ? 'R' : 'S';
        $ar->{$uu} = $S;
    }
    else {
        @ways = $G->ways;
    }

    my $l = [];
    for my $w (@ways) {

        my $h = $w->find($point) || next;

        my $a = {
          name => "Z",
          stuff => [$talk],
          bab => $h,
          ar => $ar,
          point => $point,
          way => $S,
        };
        $a->{w} = $w;

        my $Z = $G->Doming($a);

        $Z->{l} = $l;
        push @$l, $Z;

        my $r;

        eval { $r = [ $G->D($a) ] };

        $Z->{r} = $r;

        $G->Done($Z);

        if ($@) {
            my $ne = "Z";
            $ne .= $Z->{inter} if $Z->{inter};
            $ne .= "\n";
            $ne .= "S: ".ki($S)."\n" if $S;
            $ne .= "$@";
            $@ = $ne;
            $G->Flab("Z Error $@");
            die $@ unless $a->{nodie};
            $@ = "";
        }
    }

    if (!@$l) {
        $G->Flab("way miss $talk", \@ways, $S) if $G->deeby > 3;
        return;
    }

    if (@$l > 1) {
          warn "multiple returns from $point";
    }

    my ($z) = @$l;
    my @r = @{$z->{r}};
    return wantarray ? @r : shift @r;
}

sub pyramid {
    my $G = shift;
    my $a = shift;

    my ($last) = @F;
    # spawn the shadow $S of actions
    # could want more complexity per G
    # A hooks?
    my $u = $last->{A}->spawn('C') if $last;
    if (!$u) {
          $u = $G->{A}->spawn('C');
        $u->{A}->umv('','pyramid');
    }
    $u->{G} = $G if $G ne $u->{G};

    confess "Ba" if !ref $a;

    $u->from($a);
    $u->{K} = $u->{name} || die;
    $u->{K} .= 'ᣝ';
    $u->{hitime} = $H->hitime();
    $u->{stack} = $H->stack(2,7);
    $u->{F} = [@F];
    $u->{depth} = 0+@F;
    $u->{Error} = $@ if $@; #?

    $G->{A}->An($u, 'pyramid');

    $u
}

sub InjC {
    my $G = shift;
    my ($g, $In) = @_;
    while (my ($s, $etc) = each %$In) {
        while (my ($K, $win) = each %$etc) {
            my $C = $g->CsK({K=>$K, s=>$s});
            wish(C=>$C) || die "Wa".wdump[$K, $win, $C, $g];
            $C->from($win);
        }
    }
}

sub D_to_style {
    my $G = shift;
    my ($D, $bb) = @_;
          my $i = 0.001;
          my @cs;
          my $up = sub {
              $bb->{"$D->{K} $i"} = join "\n", @cs if @cs;
              @cs = ();
          };
          for my $l (split "\n", $D->{D}) {
              if ($l =~ /^\s*# (\d\S*)/) {
                  my $ni = $1;
                  $up->();
                  $i = $ni;
              }
              push @cs, $l;
          }
          $up->();
}

sub stylekeysort {
    my $G = shift;
    my $d = shift;
    my @r = sort keys %$d;

    if (grep { /^\[/ } @r) { 
        my $by = { map {
            my $p = $_;
            $p =~ s/^\[(\d+)/'['.sprintf('%08d', $1)/e;
            $p => $_
         } @r };
         @r = map { $by->{$_} } sort keys %$by;
    }
    @r
}

sub vimcolor {
    my $G = shift;
    my $string = shift;
    my $h = $H->dig($string);
    my $k = "vimcolor-$h";
    $H->{r}->{gest}->($k, sub {
        use Text::VimColor;
        my $syntax = Text::VimColor->new(
            string => $string,
            filetype => 'perl',
        );
        return $syntax->html;
    });
}

sub CsK {
    my $G = shift;
    my ($p, $GG) = @_;
    $GG ||= $G;
    $p->{s} ||= 'Cs C';
    my @topK = split ' ', delete $p->{s};
    my @Cs = map { flatline($_) } map { $GG->anyway($_) } @topK;
    @Cs = grep { $G->ip($p, $_) } @Cs if %$p;
    return wantarray ? @Cs : shift @Cs;
}

sub sway {
    my $G = shift;
    # sucks way matching $p # only supports matching K for now
    my ($p, $s, $P) = @_;
    my ($from) = $p->{from} || $G->CsK($p);

    $from || defined $P->{e} || die "no C: $p->{K} ($G->{name})".wdump([$p,$s]);

    my $w = $G->nw();
    $w->from($from) if $from;
    $w->from($p) unless $from;
    $w->from($s) if $s && %$s; # merges in B :D

    return $w
}

sub B_same {
    my $G = shift;
    my ($u, $i) = @_;

    return 1 if exists $u->{B}->{_} && exists $i->{B}->{_} && $u->{B}->{_} eq $i->{B}->{_};

    my @ks = keys %{$u->{B}||{}};
    for my $k (@ks) {
        $u->{B}->{$k} eq $i->{B}->{$k} || return 0;
    }
    return 1;
}

sub loquate {
    my $G = shift;
    my ($source, $path, $def) = @_;
    my @moves = split '/', $path;
    my $s = $source;
    until (@moves == 1) {
        my $m = shift @moves;
        $s = $s->{$m};
    }
    my $m = shift @moves;
    my $thing = $s->{$m} ||= $def;
    !ref $thing && die "Oh no! $path led to non-ref $thing from $source";
    return $thing;
}

sub accum {
    my $G = shift;
    # TODO path loquation doesn't stretch far re policy, no prob for now.
    my ($src, $ac, $t) = @_;

    if ($ac eq "Lo" || $ac eq "Li") {
        $src->{$ac} = $t;
        return;
    }

    my $a = $G->loquate($src, $ac, []);

    return if $ac eq 'o' && $src->{i} && $src->{i} eq $t;

    if (!grep { $_ eq $t } @$a) {
        push @$a, $t
    }
}

sub deaccum {
    my $G = shift;
    my ($source, $ac, $t) = @_; # takes ip ish $t maybe
    my $a = $source->{$ac} ||= [];
    my $i = 0;
    for (@$a) {
        return 1, splice(@$a, $i, 1) if $_ eq $t;
        $i++;
    }
    return 0;
}

9