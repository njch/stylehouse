package G;
our $H;
use strict;
use warnings;
use utf8;
use lib 'lib';
use feature 'say';
# two annoying dependencies
use Redis;
use Mojo::Pg;
use Scriptalicious;

use File::Slurp;
use JSON::XS;
use YAML::Syck;
use Data::Dumper;
use Storable 'dclone';
use Carp;

use List::Util qw(first max maxstr min minstr reduce shuffle sum);
use List::MoreUtils qw(natatime uniq);
use POSIX qw'ceil floor';
use Math::Trig 'pi2';

use HTML::Entities;
use Unicode::UCD 'charinfo';
use Term::ANSIColor; 
use File::Find;
use feature 'switch';
our @F; # is Ring re subs from below 

our $MAX_FCURSION = 140;
our $HASHC = "#"."c";
our $RADIAN = 1.57079633;

# going...
our $db = 0;
our $gp_inarow = 0;
our $swdepth = 5;
our $G0;
our $Ly;
our $_ob = undef;


# ^ curves should optimise away, accord ion

# to dry up

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

sub new {
    my $G = shift;
    my (@ways) = @_;
    $G->{way} = join "+", @ways;
    $G->{name} = $G->{way};

    my $ui = $G->{A}->{u}->{i};
    wish(G => $ui) || $ui eq $H || die "not G above? $G->{name} ".$ui->pi;
    $G->{A}->umv('', 'G');
    my $h = $H->{G};
    $h ||= $G if $G->{name} eq 'H'; # TODO $G->{K}
    $h || die "nogh";
    $G->{A}->umk($h, 'Gs');


    $G->load_ways();

    $G
}

sub gp {
    my $u = shift;
    return $u->pi if ref $u && ref $u ne 'HASH' && ref $u ne 'CODE'
        && ref $u ne 'ARRAY' && $u->can('pi');
    gpty($u);
}

sub sw {
    return warn "BEFORE SWA" if !$H->{swa};
    return $H->{swa}->(@_);
}

sub saycol {
    my $colour = shift;
    if ($colour eq "bright_yellow" && $db) {
        my $D = $F[0];
        my $ind = join"", ("  ")x@F;
        say "$ind $D->{G}->{name}:$D->{G}->{K} $D->{id}:$D->{K}   $D->{point}";
    }
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

sub pi {
    my $G = shift;
    join ' ', grep{defined} "G", $G->{K}, $G->{name}
}

sub pint {
    my $w = shift; 
    $w && ref $w eq "Way" ? $w->pint : "ww:".join"",map { s/\s//sg; $_ } wdump(2,$w)
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
        elsif (ref $t eq 'HASH') {
            push @s, '%{';
            if (3 == grep { $_ =~ /^(.+)\t(.+?)$/ } 
                (shuffle keys %$t)[0,1,2]) {
                push @s, "st%le";
            }
            if ($t->{name}) {
                push @s, "name=$t->{name}";
            }
            if ($t->{r}) {
                push @s, "r=$t->{r}";
            }
            if ($t->{bb}) {
                push @s, "* ".scalar(keys %$t);
            }
            push @s, '}%';
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
    my $Gs = [map{$_->{i}}@{$H->{G}->{A}->{n_Gs}}];

    my @GGs = grep { $_->{K} eq $way } @$Gs;
    if (!@GGs) {
        # never did much of this but from before was like
        @GGs = grep { $_->{way} =~ /$way/ } @$Gs;
          # which complicates as vague:
        #sort { length($a->{way}) <=> length($b->{way}) } # cerated
    }

    wantarray ? @GGs : shift @GGs;
}

sub HGf {
    $H->{G}->Gf(@_)
}

sub ki {
    my $ar = shift;
    if (!ref $ar || "$ar" !~ /HASH/) {
        confess "NOT HASH: $ar";
    }
    join ' ', map {
        my $v = $ar->{$_};
        $v = "~" unless defined $v;
        "$_=$v"
    } sort keys %$ar;
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

sub uiuS {
    my $G = shift;
    my ($u, $b) = @_;
    my $a = "S";
    my $ui = $u->{i} if $u->{i};

    for my $w ($ui, $u) {
        next if !$w;

        my $Gw = $w->{G}->findway($w->{K}) if $w->{Gw};

        for my $ww ($w, $Gw) {
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
    $G->w('chang', {humm=>$u});
}

sub load_ways {
    my $G = shift;
    my @ways = split /\+/, $G->{way};

    my $base = 'ghosts';
    $base = "$G->{stylebase}/$base" if $G->{stylebase};

    my @Aways = map{$_->{i}}@{$G->{A}->{n_way}};

    my $Awns = join '+', sort map{$_->{name}}@Aways;
    my $Gwns = join '+', sort map{$_->{name}}@{$G->{ways}};
    $Awns eq $Gwns || warn "funny looking A n_way <-> G ways:\n  A: $Awns\n  G: $Gwns";

    my $Aways = {map{$_->{name}=>$_}@Aways};

    $G->{ways} ||= [];
    $G->{wayfiles} ||= [];
    $G->{load_ways_count}++;
    my $ldw = [];
    for my $ghost (@ways) {
        my @files;

        my $where = "$base/$ghost";
        push @files, $where if -f $where;
        push @files, grep { /\/\d+$/ }
        # only glob numbery, so C/name will file further than C ways
            map { $H->fixutf8($_) }
            grep {-f $_}
            glob("$where/*") if -d $where;

        for my $file (@files) {
            my ($name) = $file =~ /ghosts\/(.+)$/;

            @{$G->{ways}} = grep { $_->{name} ne $name } @{$G->{ways}}; # TOGO
            if (my $old = $Aways->{$name}) {
                $G->deaccum($G->{A}, 'n_way', $old);
                # $G->w("del", {u=>$old}, $G->{R}) if $G->{R}; # held by pyramid...
            }

            $G->deaccum($G, wayfiles => $file);

            my ($w) = grep { $_->{_wayfile} eq $file } @{$G->{ways}};

            my $nw = $G->nw(name=>$name);
            $nw->{A}->umv('', 'way');
            $nw->load($file);

            push @$ldw, $nw;
            push @{$G->{wayfiles}}, $file;
            push @{$G->{ways}}, $nw;
        }

        die "no wayfiles from $ghost" unless @files;
    }

    say "G $G->{name} w+ ".join"  ", map{$_->{name}}@$ldw;

    return $G->w("load_ways_post") if !$G0;

    $G0 ->w("_load_ways_post", {S=>$G,w=>$G->{ways}});
}

sub Flab {
    my $G = shift;
    wish(G=>$G) || die "send G";

    # like sa*
    # throw $S up little con tent # F jointed sa*
    # also like di, has this db vector
    # for punching out with helpful quality

    say join("", "$G->{db} + $db", ("_") x scalar(@F))."$G->{name}  $_[0]"
        if $G->{db} + $db > 0
        && $_[0] !~ /^\w\ Error/;

    my $a;
    $a->{name} = "flab";
    $a->{stuff} = [@_];

    $G->pyramid($a);
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

sub di {
    # attaches meaning and dies

    # throwing back to D hopefully enriching

    # @_:
    #   bunch of vectors to topiarise the explotion
    #   bunch of data/messages

    my @vec;
    push @vec, shift while !ref $_[0] && $_[0] =~ /^[\.\d]+$/;

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
                $DOOF .= ind('ar.', join "\n",
                    map{
                     my $e = $ar->{$_};
                     my $s = "$e";
                     $s .= "(name=$e->{name})"
                         if ref $e && ref $e ne 'ARRAY'
                        && $e->{name};
                    "$_ = ". $s;
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
    # we can guess what to do and do it before the user
    #    has to squeeze right in there...
    # use Mojo::IOLoop::ForkCall;
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
        my ($wa) = $talk =~ /^w\ (\w+)/;

        warn $G->pi."    way miss $talk"
        if !($H->{misslesswa} ||= {map{$_=>1}
            qw'print humms_D flows_D fresh_init any_init recoded_init percolate_R percolate load_ways_post pv aj uxyou_D'}
          )->{$wa};
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
    $u->{order} = $H->{pyramiding}++;
    $u->{stack} = $H->stack(2,7);
    $u->{F} = [@F];
    $u->{depth} = 0+@F;
    $u->{Error} = $@ if $@; #?

    $G->{A}->An($u, 'pyramid');

    $u
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

sub pub {
    my $G = shift;
    my ($S, $m, $ig) = @_;
    G::sayyl "G pub $S < ".G::slim(50,50,$m) if !$ig;
    $H->{db}->notify($S,$m);
}

sub parse_babble {
    my $G = shift;
    my $eval = shift;

    my $AR = qr/(?:\[(.+?)\]|(?:\((.+?)\)))/;
    my $G_name = qr/[\/\w]+/;
    my $Gnv = qr/\$?$G_name/;
      my $NUM = qr/\d+(?:\.\d+)?/;
    my $mwall = qr/(?:= |^\s*)/m;



    # word or scalar
    my $point = qr/[\w\$\/\->\{\}\*]*[\w\$\/\->\.\}\*]+/;

    my $alive = qr/\$[\w]*[\w\->\{\}]+/;
    # a.b.c
    my $dotha = qr/[A-Za-z_]\w{0,3}(?:\.[\w-]*\w+)+/;

    my $poing = qr/$alive|G:$point|$dotha/;

    # [...]
    my $sqar = qr/\[.+?\]|\(.+?\)/; 



    # Sw

    $eval =~ s/(Sw|ws) (?=\w+)/w \$S /sg;

    # timer

    $eval =~ s/(timer|recur) ($NUM) \{/$1 \$G, $2, sub{/sg;

    $eval =~ s/aft \{/accum \$G, \$F[0] => _after_do => sub {/sg;

    # io
    $eval =~ s/${mwall}Sur (\S+) \{/su \$G, "$1", sub{my\$r=shift; /sg;
    $eval =~ s/${mwall}Pur (\S+) ([^;]+);$/\$H->pub("$1", $2);/sgm;

    #Sur Hostinfo {
    #Pur S/$hol "hostinfo/ack r.m", 'ig'

    # waylay

    #$eval =~ s/waylay (?:($NUM) )?(\w.+?);/\$G->timer("$1",sub { w $2; },"waylay $2");/sg;

    # wholeness Rwish #c

    my $sur = qr/ if| unless| for| when|,\s*$|;/;
    my $surn = qr/(?>! if)|(?>! unless)|(?>! for)/;
    my $suro = qr/(?:$sur|(?>!$sur))/;

    my $_m = qr/(?: (.+))?/;
    my $_u = qr/(?: ($poing))?/;
    my $ylay = qr/(yl(?: $NUM)?)?/;
    my $_g = qr/($poing )?/;

    while ($eval =~ /(?:^| )()(Rw$ylay() ((?:\*\/)?$point)$_m?)$sur?$/gsm) {
        my ($g, $old, $delay, $u, $p, $a, $un) = ($1, $2, $3, $4, $5, $6, $7);
        #say wdump[($1, $2, $3, $4, $5, $6, $7)];
        $g ||= $u.'->{G}' if $u;
        $g ||= '$G';
        $u ||= '$R';

        my $ne = ""; # hidden reverse
        $ne = $1 if $a =~ s/($sur)$//;

        my @n;
        my @m;
        my $wanr = $a =~ s/^\+ ?//;
        $wanr = 'stick' if $a =~ s/^- ?//;
        for (split /\,| |\, /, $a) {
            # sweet little pool... $J:geo etc
            if (/^\$((\w+:)?\S+)$/) {
                my ($na, $fa) = ($1, $2);
                if (!$fa) { # fake name, to ar
                    $fa = $na;
                }
                else {
                    $na =~ s/^\Q$fa\E//;
                    $fa =~ s/:$//;
                }
                $na = '$'.$na unless $na =~ /\S\.\S/;
                #saygr "from: $a          na: $na";
                push @n, "$fa => $na" ; # also avail a listy position
            }
            else {
                push @m, $_;
            }
        }
        push @n, '%$ar' if (!@n || $wanr) && $wanr ne "stick"; 

        # could use ^ here # edpeak?
        push @n, "m => [".join(',',map{'"'.$_.'"'}@m).']'
            if @m;

        my @e;
        push @e, '"'.$p.'"';
        push @e, "{".join(", ",@n)."}";
        push @e, $u if $u;
        my $en = join ", ", @e;

        my $wa = $g.'->w('.$en.')'.$ne;

        if ($delay) {
            $delay =~ /aylay ($NUM)/;
            $delay = $1 || "";
            $wa = '$G->timer("'.$delay.'",sub { '.$wa.' })';
        }

        #saygr " $old \t=>\t$wa \t\t\tg$g \tu$u \tp$p \ta$a \tun$un";

        $eval =~ s/\Q$old\E/$wa/          || die "Ca't replace $1\n\n in\n\n$eval";
    }

    #c way
    while ($eval =~ 
    /\${0}($poing )?((?<![\$\w])w(aylay(?: $NUM)?)?(?: ($poing))? ($point)( ?$sqar| ?$point|))($sur)?/sg) {
        my ($g, $old, $delay, $u, $p, $a, $un) = ($1, $2, $3, $4, $5, $6, $7);
        $g = $g ? "" : '$G'; # not in $old, over there already

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
        push @e, '"'.$p.'"';
        push @e, "{".join(", ",@n)."}";
        push @e, $u if $u;
        my $en = join ", ", @e;

        my $wa = $g."->w(".$en.")".$ne;

        if ($delay) {
            $delay =~ /aylay ($NUM)/;
            $delay = $1 || "";
            $wa = '$G->timer("'.$delay.'",sub { '.$wa.' })';
        }

        #saygr " $old \t=>\t$wa \t\t\tg$g \tu$u \tp$p \ta$a \tun$un";

        $eval =~ s/\Q$old\E/$wa/          || die "Ca't replace $1\n\n in\n\n$eval";
    } 

    # 8/9

    $eval =~ s/\${0}($poing)? K ($point)(?::($point))?(;| )/
    ($1 || '$G')
    .qq {->K("$2","$3")$4}/seg;

    $eval =~ s/(?<!G)0->(\w+)\(/\$G->$1(/sg; 

    $eval =~ s/(?:(?<=\W)|^)(?<!\\)([A-Za-z_]\w{0,3})((?:\.[\w-]*\w+)+)/"\$$1".join"",map {"->{$_}"} grep {length} split '\.', $2;/seg;


    $eval;
}

sub R {
    my $G = shift;
    $G->{A}->spawn(R => @_);
}

sub K {
    my $G = shift;
    my $n = shift;
    my $K = shift;
    if (!length $K) {
        $K = $n;
        $n = "R/non/C"; 
    }
    my $A = $G->{A};
    if ($n =~ /^(\w+)\/(\w+)\/(\w+)$/) {
        $n = $3;
        my $o = $G->K($1,$2);
        $o || die "not finding $o $1 $2\n".wdump(2,$o)
        ."only: ".join(" ",sort keys %{$G->{A}})."\n"
        .join"\n"," And: ",map{$_->pi} @{$G->{A}->{n_R}};
        $A = $o->{A};
    }

    my $lot = $A->{"n_$n"};
    warn "G::K() no A n_$n: ".$A->pi."  ".join("  ", sort keys %$A) if !$lot;
    $lot ||= [];

    $lot = [map{$_->{i}}@$lot];
    @$lot = grep { $_->{K} eq $K } @$lot if $K ne '*';


    wantarray ? @$lot : shift @$lot;
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
          my $i = 0.01;
          my @cs;
          my $up = sub {
              $bb->{"$D->{K}\t$i"} = join "\n", @cs if @cs;
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

sub chuntr {
    my $G = shift;
    split /(?=\{|\[|\^)/, shift;
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
    # sucks way matching $p # only supports matching$G->K("for","") now
    my ($p, $s, $P) = @_;
    my ($from) = $p->{from} || $G->CsK($p);

    $from || defined $P->{e} || return undef;

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

sub slim {
    my ($f,$t,$c) = @_;
    ($f,$t,$c) = (40,40,$f) if $f && !$t && !$c;
    ($f,$t,$c) = ($f,$f,$t) if $t && $f && !$c;
    $c = ($c=~/^(.{$t})/s)[0]."..." if length($c) > $f;
    $c
}

sub shtocss {
    my $s = shift;
    return join "", map { "$_:$s->{$_};" } sort keys %$s if ref $s eq "HASH";
    return join ";", @$s if ref $s eq "ARRAY";
    return $s
}

sub ind {
    "$_[0]".join "\n$_[0]", split "\n", $_[1]
}

9;

