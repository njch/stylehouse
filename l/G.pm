package G;
our $H;
use strict;
use warnings;
use utf8;
use lib 'lib';
use feature 'say';
use base 'Ghost';
sub wdump { H::wdump(@_) };
sub gpty { Ghost::gpty(@_) };
sub pint { Ghost::pint(@_) };
use YAML::Syck;
our $swdepth = 5;
our $T; # allele tower... not like so, again R above
our @F; # is Ring re subs from below
our $G0;
# ^ curves should optimise away, accordion

sub new {
    my $G = shift;
    my (@ways) = @_;
    $G->{way} = join "+", @ways;
    $G->{name} = $G->{way};

    $G->{GGs} = [];
    my $ui = $G->{A}->{u}->{i};
    wish(G => $ui) || $ui eq $H || die "not G above? $G->{name} ".$ui->pi;
    $G->{O} = $ui;
    push @{$ui->{GGs}}, $G;
    push @{$H->{G}->{GGs}}, $G;


    #$G->timer(1, sub {sw($G->{A}->{u}->{u}->{i})}) if $G->{way} =~ /ux/;

    $G->{W} ||= $G->{A}->spawn('W');


    $G->load_ways(@ways);

    $G
}

sub sw {
    my $stuff = wdump($G::swdepth, @_>1?\@_:@_);
    $H->{r}->publish('sw', $stuff);
    say "published wdump to sw from   $G::swdepth x ".length($stuff);
}

sub pi {
    my $G = shift;
    "G ".$G->{name};
}

sub w {
    my $G = shift;
    my $point = shift;
    my $ar = shift;
    my $Sway = shift;
    my @ways;

    die "What do you MEAN $G->{name} $point $ar $Sway !?  ".wdump($ar) if defined $ar && ref $ar ne "HASH";
    my $talk = "w $point";
    my $watch;

    if ($Sway) {
        $talk .= " S";
        if (ref $Sway eq 'Ghost' || ref $Sway eq "G") {
            @ways = $Sway->ways;
            $talk .= " G";
        }
        elsif (ref $Sway eq 'Way' || ref $Sway eq "C") {
            if ($Sway->{ofways}) {
                @ways = @{$Sway->{ofways}};
            }
            elsif ($Sway->{Gw}) {
                my $SG = $Sway->{G} || die "no Sway G!?";
                my $CodeK = $Sway->{Gw};
                $CodeK = $Sway->{K} if $CodeK eq "1";
                $point = "$CodeK/$point" unless $point =~ /^$CodeK/;
                if ($G eq $SG) {
                    @ways = $G->ways; # ------------------
                }
                else {
                    return $SG->w($point, $ar, $Sway); # G pass
                }
            }
            else {
                @ways = $Sway; #---------------------
            }
        }
        elsif (ref $Sway eq 'ARRAY') {
            die "NO MORE ARRAY WAYS --- $point ".slim(100,80,ki($ar))."\n"."$Sway - ".ki($Sway);
        }
        my $b = {};
        %$b = (%{$Sway->{B}}, B => $Sway->{B}) if $Sway->{B};
        $ar = {%$ar, %$b, S => $Sway};
        $ar->{S} = $G->{S} if $G->{S};
    }
    else {
        @ways = $G->ways;
    }

    my @returns;
    for my $w (@ways) {
        my $h = $w->find($point);
            sw({h=>$h, point=>$point, w=>$w, Sway=>$Sway}) if $watch;
        next unless $h;
        my $u = $G->waystacken(Z => "$talk", $G, $w, $Sway, bless {h=>$h}, 'h');
        my ($Z) = @Ghost::F;
        my $r;

        eval { $r = [ $G->doo($h, $ar, $point, $Sway, $w, $Z) ] };

        push @returns, $r;
        my $ZZ = $u->();
        die "MISM" unless $Z eq $ZZ;
        $Z->{Returns} = $r;

        if ($@) {
            my $ne = "Z";
            $ne .= $Z->{inter} if $Z->{inter};
            $ne .= "\n";
            $ne .= "S: ".ki($Sway)."\n" if $Sway;
            $ne .= "$@";
            $@ = $ne;
            $G->Flab("Z Error $@");
            die $@;
        }
    }
    unless (@returns) {
        $G->Flab("way miss $talk", \@ways, $Sway) if $G->deeby > 3;
    }
    return warn "Multiple returns from ".($point||'some?where')
                            if @returns > 1;    
    return
                            if @returns < 1;
    my @return = @{$returns[0]};
    if (wantarray) {
        return @return
    }
    else {
        my $one = shift @return;
        return $one;
    }
}

sub nw {
    my $G = shift;
    my $C = $G->{A}->spawn('C');
    $C->from({@_}) if @_;
    $C
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
        push @files, map { Hostinfo::fixutf8($_) }
            grep { /\/\d+$/ } glob("$base/*");

        for my $file (@files) {
            # TODO pass an If object selector to 0->deaccum
            @{$G->{ways}} = grep { $_->{_wayfile} ne $file } @{$G->{ways}};
            @{$G->{wayfiles}} = grep { $_ ne $file } @{$G->{wayfiles}};

            my $nw = $G->nw(name=>$name);
            $nw->load($file);

            if (my $inc = $nw->{include}) {
                for my $name (split ' ', $inc) {
                    next if grep { $_->{name} eq $name } @{$G->{ways}};
                    push @ways, $name;
                }
            }

            say "G $G->{name} w+ $nw->{name}";
            push @{$G->{wayfiles}}, $file;
            push @{$G->{ways}}, $nw;
        }

        die "no wayfiles from $name" unless @files;
    }

    $G->_0('_load_ways_post', {w=>$G->{ways}});
}

sub babblethehut {
    my $G = shift;
    my $eval = shift;

    my $G_name = qr/[\/\w]+/;
    my $Gnv = qr/\$?$G_name/;

    $eval =~ s/G!($Gnv)/G\.A->spawn(G => "$1")/sg;
    $eval =~ s/G-($Gnv)/\$G->Gf("$1")/sg;
    $eval =~ s/G:($Gnv)/HGf("$1")/sg;

    $eval =~ s/(?<!G)(0->\w+)\(/\$G->_0("$1", /sg;
    $eval =~ s/(0S->\w+)\(/\$G->_0("$1", /sg;

    $eval =~ s/(?:(?<=\W)|^)([A-Za-z_]\w{0,3})((?:\.[\w-]*\w+)+)/"\$$1".join"",map {"->{$_}"} grep {length} split '\.', $2;/seg;

    $eval
}

sub _0 {
    my $G = shift;
    my ($point, @etc) = @_;
    if (!$G0 || !(ref $G0 eq "Ghost" || ref $G0 eq "G")) {
        if ($point eq "_load_ways_post") {
            return $G->w("load_ways_post");
        }
        die "CABNNOOT call G0, doesn't exist. "
            ." $point, @etc\n\n".wdump($G0);
    }
    if ($point =~ /^0S?->(.+)$/) {
        my $Usub = $1;
        $G->can($Usub) || die "no 0U $Usub\n".wdump(2,$G0);
        $G->$Usub(@etc);
    }
    else {
        my $ar = shift @etc;
        $ar->{S} = $G;
        $G0->w($point, $ar);
    }
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
            ." $a->{e} - $ohms  $k\t $an->{e} \t\t ".Ghost::gpty($v);

        if ($an->{e} >= 1 && ref $an->{i}) {
            my $cu = $G->du($an);
            while (my ($ku, $vu) = each %$cu) {
                $c->{$k.$ku} = $vu;
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

sub ki {
    Ghost::ki(@_)
}

sub flatline {
    Ghost::flatline(@_)
}

sub wish {
    Ghost::wish(@_);
}

sub sayyl {
    print colored(join("\n", @_,""), 'bright_yellow');
}

sub sayre {
    print colored(join("\n", @_,""), 'red');
}

sub sayg {
    print colored(join("\n", @_,""), 'bright_green');
}

sub saygr {
    print colored(join("\n", @_,""), 'green');
}

sub saybl {
    print colored(join("\n", @_,""), 'bright_blue');
}

sub uiuS {
    my $G = shift;
    my ($u, $b) = @_;
    my $a = "S";
    my $ui = $u->{B}->{Lu}->{i} if $u->{B}->{Lu}; # even if below thingy?

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

sub InjC {
    my $G = shift;
    my ($g, $In) = @_;
    while (my ($s, $etc) = each %$In) {
        while (my ($K, $win) = each %$etc) {
            my $C = $g->CsK({K=>$K, s=>$s});
            $C->from($win);
        }
    }
}

sub GAK {
    my $G = shift;
    my ($K, $g) = @_;
    $g->{K} = $K;
    $G->{GG}->{$g->{K}} = $g;
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
    $G->_0("0S->ingo", $ingw);
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
        $G->_0("0S->ingo", $ingw);
    }, "ing $ingw->{name} $ingw->{id}");
}

sub scGre {
    my $G = shift;
    my ($ip) = @_;
    # or something was somehow, tractioning v
    my @a = grep { $G->_0("0->ip", $ip, $_->{i}) } @{ $G->{W}->{script} };
    @a
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

sub rei {
    my $G = shift;
    my ($ip) = @_;
    map {$_->{i}} $G->_0("0S->scGre", $ip);
}

sub ei {
    my $G = shift;
    my $ip = {};
    $ip->{K} = shift; # lookup BcS for more, we could want to create
    map {$_->{i}} $G->_0("0S->scGre", $ip);
}

sub reeni {
    my $G = shift;
    my ($ip, @is) = @_;
    my @sel;
    my @new = grep {defined} map {
        if ($G->_0("0S->ip", $ip, $_->{i})) {;
            push @sel, $_;
            undef;
        }
        else {         $_           }
    } @{$G->{W}->{script}};
    # etc
}

sub sing {
    my $G = shift;
    my $p;
    $p->{name} = shift;
    $p->{code} = shift;
    $p = {%$p, @_};
    $p->{again} = 0.5 if !defined $p->{again};
    $p->{begin} = 0.2 if !defined $p->{begin};
    $H->{G}->w(sing => $p);
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

    my $a = $G->_0("0S->loquate", $src, $ac, []);

    return if $ac eq 'o' && $src->{i} && $src->{i} eq $t;

    if (!grep { $_ eq $t } @$a) {
        push @$a, $t
    }
}

sub deaccum {
    my $G = shift;
    my ($source, $ac, $t) = @_;
    my $a = $source->{$ac} ||= [];
    my $i = 0;
    for (@$a) {
        return splice(@$a, $i, 1) if $_ eq $t;
        $i++;
    }
}

sub wdif {
    my $G = shift;
    my ($h, $w) = @_;
    if ($w->{$h}) {
        $G->w($h, {}, $w);
        delete $w->{$h};
    }
}

sub u {
    my $G = shift;
    my ($K, $s) = @_;
    $G->_0("0S->sway", {K=>$K}, $s);
}

sub sway {
    my $G = shift;
    # sucks way matching $p # only supports matching K for now
    my ($p, $s, $P) = @_;
    $p->{s} ||= 'chains C';
    my ($from) = $p->{from} || $G->_0("0S->CsK", $p);

    $from || defined $P->{e} || die "no findo way called $p->{K} ($G->{name})".wdump([$p,$s]);

    my $w = $G->nw();
    $w->from($from) if $from;
    $w->from($p) unless $from;
    $w->from($s) if $s && %$s; # merges in B :D

    return $w
}

sub Bu {
    my $G = shift;
    my($K,$B)=@_;
    my $u = $G->_0("0S->sway", {K=>$K},{B=>$B});
    my $a = {};
    $G ->w("Bu_D", {a => $a}, $u) if $u->{Gw} || $u->{Bu_D};#opopopopop
    $u;
}

sub CsK {
    my $G = shift;
    my ($p, $GG) = @_;
    $GG ||= $G;
    $p->{s} ||= 'C';
    # $p->{CsK} locates the Cs, is a qw of paths for anyway
    my @Cs = map { flatline($_) } map { $GG->anyway($_) }  split ' ', delete $p->{s};
    # another ghost lurks
    if ($p->{K}) {
        @Cs = grep { $_->{K} eq $p->{K} } @Cs;
    }
    return wantarray ? @Cs : shift @Cs;
}

sub Tind {
    my $G = shift;
    my ($space) = @_;
    $space = "    " if !defined $space;
    my $mes = $T->{r}->{is} if $T->{r};
    $mes ||= [];
    my $ind = "";
    $ind .= "    " for 0..@$mes; # +1
    return $ind;
}

sub Egypto {
    my $G = shift;
    my ($Egyptian_Fraction) = @_;
    my $val = 0;
    for (split / ?\+ ?/, $Egyptian_Fraction) {
        /^(\d+)\/(\d+)$/ || die "Egypmal";
        $val += $1 / $2;
    }
    $val;
}

sub EgyB {
    my $G = shift;
    my ($B) = @_;
    return { map { $G->_0("0->Egypto", $_) => $_ } keys %$B };
}

sub TafuBl {
    my $G = shift;
    #STICKSSTICKSSTICKSSTICKSSTICKSSTICKSSTICKSSTICKSSTICKSSTICKS
    $G->_0("0S->l",  $G->_0("0S->TafuB", @_) );
}

sub TafuB {
    my $G = shift;
    my($K,$B)=@_;
    my $ca = $G->W->{ca}->{K}->{$K}->{B_ki}->{ki($B)};
    if ($ca && !$ca->{dead}) {
        return $ca;
    }
    $G->_0("0S->Tafu", $G->_0("0S->Bu", $K, $B))
}

sub TB {
    my $G = shift;
    my ($K, $B) = @_;
    my $u = $G->_0("0S->Bu", $K, $B);
    $G->_0("0S->T", {i=>$u});
}

sub Tafu {
    my $G = shift;
    my($uu)=@_;
    $G->_0("0S->fu", $uu) || $G->_0("0S->T", {i => $uu});
}

sub Taful {
    my $G = shift;
    my($uu)=@_;
    $G->_0("0S->l",  $G->_0("0S->Tafu", $uu) );
}

sub visTp_TafuBlA {
    my $G = shift;
    my ($Tp, $Bup, $A) = @_;
    my $old = $G->_0("0S->visTp", $Tp); # could be Fun, wire into end
    my $uu = $G->_0("0S->Bu", @$Bup); 
    my $u = $G->_0("0S->fu", $uu);

    $A->{old} ||= [] if $A;
    $A->{new} ||= [] if $A;
    if ($u) {
        push @{$A->{old}}, $u if $A;
    }
    else {
        push @{$A->{new}}, $u if $A;
        $u = $G->_0("0S->T", {i => $uu});
    }

    $G->_0("0->l", $u);
    $T= $old;
    $u;
}

sub visTp_l_u {
    my $G = shift;
    my ($Tp, $u) = @_; # get in to a T place and make links
    my $old = $G->_0("0S->visTp", $Tp);
    $G->_0("0->l", $u);
    $T= $old;
    $u;
}

sub l {
    my $G = shift;
    my ($u) = @_;
    $u->{A}->An($u);
    $u->{A}->Au($T->{i});
    $G->_0("0->accum", $u, 'Lo', $T->{L});
    $G->_0("0->accum", $T, 'o', $u);
    $u;
}

sub visTp_TafuBl {
    my $G = shift;
    my ($Tp, $Bp) = @_;
    my $old = $G->_0("0S->visTp", $Tp);
    my $u = $G->_0("0S->TafuBl", @$Bp);
    $T= $old;
    $u;
}

sub T {
    my $G = shift;
    my ($p) = @_;

    # 1/9

    my $giu = $T->{i};
    my $old = $G->_0("0S->visTp", $p); # 1
    die "no old!".wdump($T) if !$old;
    $T->{i} || die " no way in! ".wdump($p);

    $G->_0("0S->fu_cache", $T->{i});

    # set up this dimension - allele tower
    # maths stapler - clown shoes - RNA

    my $beg = $T->{i};
    my $sge = sub {
        die "Lost i somewhere before ".shift."... "
        .wdump(2, [$beg, $T->{i}]) unless $T->{i} eq $beg;
    };

    # 2/9

    say "HAUNT HAUNT HAUNT ".$T->{i}->pi if $G->deeby;
    #$G0->{travels_of}->{$G->{name}} ++;
    $G->ob("haunt");
    # so crawl is like an expanding awareness thing
    # see the whole structure

    # 3/9
     $G->w("T/flows");
       $G->w('flows_D', {}, $T->{i});
    #$G->Flab("flows ", $T);
      $sge->("flows");

    # 4/9
    $T->{L} = $G->W->continues($G); # %
      $sge->("humms W being"); # eg travelling sw eval
     $G->w("T/humms");
       $G->w('humms_D', {}, $T->{i});
    #$G->Flab("humms", $T);
      $sge->("humms");

    # 5/9
    $T->{L}->{i} eq $T->{i} || die "5 eye swamp gone wrong".sw($T);
    $G->_0("0S->accum", $T->{L}->{i}, 'Li', $T->{L}); # just right

     $G->w("T/links", {u=>$T->{i}});
       $G->w('links_D', {}, $T->{i});
    #$G->Flab("links", $T);
      $sge->("links");
    # rounds_D? replayable when recoded?
    # assume 6/7 will continue the process...
    # 6/9
     $G->w("T/travels");
       $G->w('travels_D', {}, $T->{i});
    #$G->Flab("travels", $T);
      $sge->("travels");
    die "Lost i somewhere before 7... "
    .wdump(2, [$beg, $T->{i}])unless $T->{i} eq $beg;

    # 7/9

    $G->w("T/traction", {u=>$T->{i}});
    $G->w('traction_D', {}, $T->{i});
    #$G->Flab("travels", $T);
      $sge->("travels");

    # 8/9

    #$H->Info("HAUNTED ".sw($T)) if $G->{name} =~ /braid|ux|odon/;

    # 9/9

    die "Lost i somewhere before 9... "
    .wdump(2, [$beg, $T->{i}])unless $T->{i} eq $beg;

    my $L = $T->{L};
    $T = $old;
    die "dumb".wdump([$T, $old, $giu]) unless $T->{i} eq $giu;
    return $L->{i};
}

sub visTp {
    my $G = shift;
    my ($p, $fun) = @_;

    # are in Ghost right now?
    my $tish = $T && (ref $T eq 'Way' || ref $T eq 'C');
    my $old = $T;
    if (!$tish) {
        $T = $G->nw();
    }
    elsif ($T->{G} ne $G) {
        # loses hair? we never care?
        $T = $G->nw();
    }
    else {
        $T = $T->spawn;
    }
    $Ghost::T = $T;

    $p = {i=>$p} if ref $p =~ /^(Way|C)$/;
    my $moved = $p->{i} || $p->{L};
    if ($moved) {
        delete $T->{$_} for qw'i L t o';
    }

    $T->from($p);

    $T->{i} ||= $T->{L}->{i};
    $T->{L} ||= $T->{i}->{Li};
    $T->{t} ||= $T->{L}->{t};
    $T->{o} ||= $T->{L}->{o};
    $T->{o} ||= [];

    if ($old) {
        $T->{_T} = $old;
        #push @{$old->{T_}||=[]}, $T;
    }
    if (my $r = $T->{r}) {
        if ($moved && $r->{ih}->{$T->{i}->{id}} && $r->{noo}) {
            # recursion q factor # can rebraid things to go on forever etc.
            die "not allowed circular travel, "
                .sw({here_before => $T});
        }
        $r = $T->{r} = {%$r};
        $r->{ih} = {%{$r->{ih}||{}}};
        $r->{is} = [@{$r->{is}||[]}, $T->{i}];
        $r->{ih}->{$T->{i}->{id}} = $T;
    }

    if (ref $fun eq "CODE") {
        return $fun->();
        $T = $old;
        $Ghost::T = $T;
    }
    elsif ($fun eq "Fun") {
        push @{ $F[0]->{_after_do} }, sub {
            $T = $old;
            $Ghost::T = $T;
        }
    }
    return $old;
}

sub fu {
    my $G = shift;
    my $u = shift;

    my $fo = $G->W->{ca}->{K}->{$u->{K}}->{B_ki}->{ki($u->{B})};
    if ($fo && $fo->{dead}) {
        say "$u->{K} found but dead";
        $fo = undef;
    }
    return $fo if $fo;

    for my $LL (@{$G->W->{script}}) {
        my $i = $LL->{i};
        my $yup = $i eq $u
            || (!exists $u->{K} || $i->{K} eq $u->{K})
            && $G->_0("0S->B_same", $u => $i);
        if ($yup) {
           say "found $i->{K} in script";
            return $i;
        }
    }
    return undef;
}

sub fu_cache {
    my $G = shift;
    my $u = shift;
    $u->{B} ||= {};
    $G->W->{ca}->{K}->{$u->{K}}->{B_ki}->{ki($u->{B})} = $u;
}

sub fs_glob {
    my $G = shift;
    my (@globs) = @_;
    my @list;
    for my $glob (@globs) {
        push @list, grep { defined }
            grep { Hostinfo::fixutf8($_) || 1 }
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
        Hostinfo::fixutf8($na);
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

sub B_same {
    my $G = shift;
    my ($u, $i) = @_;

    return 1 if exists $u->{B}->{_} && exists $i->{B}->{_} && $u->{B}->{_} eq $i->{B}->{_};

    my @ks = keys %{$u->{B}};
    for my $k (@ks) {
        $u->{B}->{$k} eq $i->{B}->{$k} || return 0;
        next if $k eq "Codon";
    }
    unless (keys %{$u->{B}}) {
        $H->Say(" u has no B, mind  you...".ki($u));
    }
    return 1;
}

sub Ato {
    my $G = shift;
    my ($w, $to) = @_;
    grep { $_->{K} =~ /^$to$/ } @{$w->{Li}->{o}}
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

sub wayray {
    my $G = shift;
    my ($SS, $GG) = @_;
    $GG ||= $G;
    die sw(\@_) if ref ${GG} !~ /^G/;
    my $i = 0;
    for my $wS (@$SS) {
        $SS->[$i] = $GG->nw(%$wS) unless ref $wS =~ /^(Way|C)$/;
        $i++;
    }
}

sub RW {
    my $G = shift;
    my ($GG) = @_;
    say "RW RW RW RW RW $GG->{name}\t\t $GG->{K}";
    $_->{dead} = $F[0] for $G->_0("0->rei", $GG, {});
    my $W = $GG->{W};
    delete $GG->{Vu}; # vortex will start over
    my $deadscript = $W->{script};
    $W->{script} = [];
    $W->{n} = 0;
    delete $W->{ca};
    $deadscript;
}

sub delfrom {
    my $G = shift;
    my ($u) = @_;
    for my $uu ($G->_0("0S->Io", $u)) {
        $G->_0("0S->del", $uu);
    }
}

sub del {
    my $G = shift;
    my ($u) = @_;
    my $L = $u->{Li} || die "wasnt";
    #say "deleting ".$u->pint;
    $G->w('v/ch'=>{u=>$u});

    $G->_0("0S->deaccum", $u->{Lo}, 'o', $u);
    $G->_0("0S->deaccum", $u->{Li}->{W}, 'script', $L);
    $u->{dead} = 1;

    $G->_0("0S->del", $_) for @{$u->{Li}->{o}};
}

sub Io {
    my $G = shift;
    my ($u) = @_;
    grep { $_->{G} eq $G } @{$u->{Li}->{o}};
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
    $a->{cb} = sub {
        my $d = {};
        ($d->{m}, $d->{top}, $d->{sutop}) = @_;
        $G->timer(0.1, sub {
            say "a su $d->{top} from $d->{sutop}";
            $D->($d);
        });
    };

    $H->{G}->w(suRedis => $a);
}

'stylehouse'