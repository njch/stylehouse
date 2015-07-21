package G;
our $H;
use strict;
use warnings;
use utf8;
use lib 'lib';
use feature 'say';
# two annoying dependencies 
use Mojo::IOLoop::Stream;
use Mojo::IOLoop;
use File::Path qw(make_path remove_tree);
use Scriptalicious;  
use File::Slurp;
use JSON::XS;
our $JSON = JSON::XS->new->allow_nonref;
use YAML::Syck;
use Data::Dumper; 
use Storable 'dclone';
use Carp;
use UUID;

use Time::HiRes 'gettimeofday', 'usleep';
use List::Util qw(first max maxstr min minstr reduce shuffle sum);
use List::MoreUtils qw(natatime uniq);
use POSIX qw'ceil floor';
use Math::Trig 'pi2';

use HTML::Entities;
use Unicode::UCD 'charinfo';
use Encode qw(encode_utf8 decode_utf8 is_utf8);
use Term::ANSIColor; 
use File::Find;
use feature 'switch';
our @F; # is Ring re subs from below 

our $MAX_FCURSION = 240;
our $RADIAN = 1.57079633;
our $NUM = qr/-?\d+(?:\.\d+)?/;

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
    my $s = join "\n", map { s/      /  /g; $_ } split /\n/, Dumper($thing);
    $s =~ s/^\$VAR1 = //;
    $s =~ s/^    //gm;
    $s;
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
            if (@s == 1) {
                push @s, slim(200, ki($t));
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

sub cgp {
    my $G = shift;
    my $u = shift;
      my $c = {};
      if (!defined $u){
          $c->{undef} = 1;
      } else {
          if (my $ref = ref $u) {
              $c->{ARRAY} = 1 if $ref eq "ARRAY";
              $c->{HASH} = 1 if $ref eq "HASH";
              $c->{CODE} = 1 if $ref eq "CODE";
              $c->{canpi} = 1 if !%$c && $u->can('pi');
              for (qw'A C G T     R   J') {
                    $c->{$_} = 1 if $ref eq $_;
              }
              $c->{ref} = $ref;
          }
          else {
              if (ref \$u eq 'SCALAR') {
                  $c->{text} = 1;
                  $c->{len} = length($u);
                  $c->{lin} = scalar split /\n/, $u;
                  $c->{b} = scalar split /\n\n/, $u;
                  $c->{number} = $u =~ /^(?:\d+\.)?\d+$/;
                  $c->{wordy} = $u =~ /\w+/;
              }
              else { die "wtf is $u" };
          }
      }
      $c
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
    my $re = $ar if $ar =~ /^\d+$/;
    $ar = shift if defined $re;
    my $d = 1 + shift;
    if (!ref $ar || "$ar" !~ /HASH/) {
        return "!%:$ar";
    }
    my $lim = 150 - (150 * ($d / 3));
    join ' ', map {
        my $v = $ar->{$_};
        $v = "~" unless defined $v;
        ref $v eq 'HASH'
            ? "$_=".($re ?  "{ ".slim($lim,ki($re-1, $v,$d))." }" : gp($v))
            : "$_=".slim(150,"$v")
    } sort keys %$ar;
}

sub k2 {
    ki 1, shift;
}

sub unico {
    my ($int, $wantinfo) = @_;
    my $h = sprintf("%x", $int);
    my @s = eval '"\\x{'.$h.'}"';
    push @s, charinfo($int) if $wantinfo;
    wantarray ? @s : shift @s
}

sub hexend {
    $_[0] =~ /([0-f])?([0-f])?([0-f])?$/;
    map { hex($_) } $1, $2, $3;
}

sub hexbe {
    my@h = map { sprintf('%x', int($_)) } @_;
    wantarray ? @h : join'',@h;
}

sub hitime {
    return join ".", gettimeofday();
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
                sayre "Gsing $splatter again! $name";
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
        !ref $ip->{$I} && $ip->{$I} ne $i->{$I} && $pass--;
        ref $ip->{$I} eq 'HASH' && do {
            if (my $not = $ip->{$I}->{not}) {
                $not eq 'def' && do {
                    defined $i->{$I} && $pass--;
                } 
                || $not eq $i->{$I} && $pass--;
            }
            else {
                $ip->{$I}->{$i->{$I}} eq '1' || $pass--;
            }
        };

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

sub mkuid {
    (mkuuid() =~ /^(\w+)-.+$/)[0]
    .$H->{sdghih}++
}

sub mkuuid {
    UUID::generate(my $i);
    UUID::unparse($i, my $s);
    $s
}

sub load_ways {
    my $G = shift;
    my @ways = split /\+/, $G->{way};

    my $base = 'ghosts';
    $base = "$G->{stylebase}/$base" if $G->{stylebase};

    my @Aways = map{$_->{i}}@{$G->{A}->{n_way}};

    my $Awns = join '+', sort map{$_->{name}}@Aways;
    my $Gwns = join '+', sort map{$_->{name}}@{$G->{ways}};
    $Awns eq $Gwns || sayre "tons of A way building up for G way....?";

    my $Aways = {map{$_->{name}=>$_}@Aways};

    $G->{ways} ||= [];
    $G->{wayfiles} ||= [];
    $H->{load_ways_count}->{$G->{id}}++;
    my $ldw = [];
    for my $ghost (@ways) {
        my @files;

        my $where = "$base/$ghost";
        push @files, $where if -f $where;
        push @files, grep { /\/\d+$/ }
        # only glob numbery, so C/name will file further than C ways
            map { fixutf8($_) }
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

sub Dm {
    my $G = shift;
    my $a = shift;

    if ($a->{D}) {
        die unless ref $a->{D} eq "CODE";
        return {evs=>"?????????????????", sub=>$a->{D}};
    }

    my $uuname = join " ",
        $G->{id},
        dig($a->{bab}),
        $a->{point},
        " ar%".join(",",sort keys %{$a->{ar}}),
    ;        
    my $ha = dig($uuname);
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
    my @warnings;

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

    $G->{sigstackend} ||= sub {
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
    $G->{sigstackwa} ||= sub {
        return 1 if $_[0] =~ /^Use of uninitialized value/;
        my @loc = caller(1);
        sayre join "\n", "warn from ".$F[0]->{G}->{name}
            ."  way $F[0]->{point}"
            ."       at line $loc[2] in $loc[1]:", @_;
        return 1;
    };
    my @return;
    if (ref $sub eq "CODE" && !$@) {
        local $SIG{__DIE__} = $G->{sigstackend};
        local $SIG{__WARN__} = $G->{sigstackwa};


        eval { @return = $sub->($a->{ar}) }
    }

    $G->Done($D); # Ducks
    $D->{r} = [@return];


    return wantarray ? @return : shift @return
}

sub Doming {
    my $G = shift;
    my $D = shift;
    die if @_;

    $D = $G->pyramid($D);

    unshift @F, $D;
    $D->{F} = [@F];

    return $D;
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
            $DOOF .= " ". $D;
            $DOOF .= "DOOF $D->{K}".sprintf("%-24s",
                $G->{name}."  $D->{K}  ".($ar->{S} ? "S=".gpty($ar->{S}) :"")
            );
            $DOOF .= " w"." $D->{point}  ".join(", ", keys %$ar)."\n";

            if ($D->{K} ne 'Dᣝ') {
                $DOOF =  "$D->{K}"; 
                $DOOF .= "  $D->{inter}" if $D->{inter};
                $DOOF .= "\n";
            }  



            if ($first) {
                my $x = $1 if $@ =~ /syntax error .+ line (\d+), near/
                    || $@ =~ /line (\d+)/;

                my $file = $1 if $@ =~ /at (\S+) line/;

                undef $file if $file && $file =~ /\(eval \d+\)/;
                undef $file if $file && !-f $file;

                my $code = $file ? read_file($file) : $evs;

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
                my $in = ($D->{K} ? $D->{K} eq 'Dᣝ' : $D->{sign} eq 'D') ? "! " : "";
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
                # send it away
                sayre $@;
                $G->{dooftip} && $G->{dooftip}->($@);
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
    my $whole = @code < 18;


    if ($code =~ /^sub \{ my \$ar = shift/
        && $code =~ /return \@doo_return \};/) {
        $line -= 2 if $line;
        shift @code for 1..2;
        pop @code for 1..2;
    }


    my $xx = 0;
    my $lci;
    for my $c (@code) {
        $xx++;
        $lci = $1 if $xx < $line && $c =~ /^\s*(#\s*\d.*)$/;
        if (!defined $line) {
            $diag .= ind("⊘  ", $c)."\n"
        }
        elsif ($xx == $line) {
            $diag .= ind("⊘  ", $c)."\n";

            my $bab = (split"\n",$D->{bab})[$line-2];
            if ($bab ne $c) {
                $diag .= ind("⊖r ", $bab)."\n";
            }
        }
        elsif (!$whole && $xx > $line-5 && $xx < $line+5) {
            $diag .= ind("|  ", $c)."\n"
        }
        elsif ($whole) {
            $diag .= ind("|  ", $c)."\n"
        }
    }

    $diag = "$diag\n#~~~$lci" if $lci && $lci !~ /^# 0.01/;
    $diag
}

sub stack {
    my $b = shift;
    my $for = shift || 1024;
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
        last if !--$for;
        $b++;
    }
    return [@from];
}

sub timer {
    my $G = shift;
    my $time = shift || 0.001;
    my $D = shift;

    my $B; 
    $B->{name} = "t";
    $B->{talk} = "Ze timer from ".$F[0]->{talk};
    $B->{time} = $time;
    $B->{D} = $D; # maybe sub or Disc like thing
    $B->{stuff} = [@_];
    my $Dome = $G->Doming($B);

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

    $G->D({D=>$Dome->{D}, toplevel=>1, talk=>"351 dollars",name=>"comeback"});

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
            warn "BATS: $E     s.point";
        }
        else {
            shift @F;
        }

        if ($@) {
            $s->{Error} = $@;
        }

        if ($s->{_after_do}) {
            $_->() for @{$s->{_after_do}};
        }

        my $te = $@; $@ = "";
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
    $ar->{R} = undef if !defined $ar->{R};

    my $talk = "w\ $point";
    my $watch;

    if ($S) {
        my $y = 'S';
        $talk .= " $y";
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
            $y = 'R';
        }

        if (my $B = $S->{B}) {
            # we dont upload variables from B
            # change $B->{whatever} to set
            # good verboz code clarity for scheming
            %$ar = (%$ar, %$B, B => $B);
        }
        $ar->{$y} = $S;
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

        $Z->{r} = $r; # TODO many awkward

        $G->Done($Z);

        if ($@) {
            my $ne = "Z";
            $ne .= $Z->{inter} if $Z->{inter};
            $ne .= "\n";
            $ne .= "S: ".ki($S)."\n" if $S;
            $ne .= "$@";
            $@ = $ne;
            die $@ unless $a->{nodie};
            $@ = "";
        }
    }

    if (!@$l) {
        my ($wa) = $talk =~ /^w\ (\w+)/;

        warn $G->pi."    way miss $talk"
        if !($G->{misslesswa} ||= {map{$_=>1}
            qw'print humms_D flows_D fresh_init any_init recoded_init percolate_R percolate load_ways_post pv aj uxyou_D event life_D'}
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
    my $u = $last->{A}->spawn('C') if $last && do{
        $last->{A} ||  do {
            sayre  "finish!";
            exec "nice perl $0 @ARGV";
        };
        $last->{A};
    };
    if (!$u) {
          $u = $G->{A}->spawn('C');
        $u->{A}->umv('','pyramid');
    }
    $u->{G} = $G if $G ne $u->{G};

    confess "Ba" if !ref $a;

    $u->from($a);
    $u->{K} = $u->{name} || die;
    $u->{K} .= 'ᣝ';
    $u->{hitime} = hitime();
    $u->{order} = $H->{pyramiding}++;
    $u->{stack} = $H->stack(2,7);
    $u->{F} = [@F];
    $u->{depth} = 0+@F;
    $u->{Error} = $@ if $@; #?

    $G->{A}->An($u, 'pyramid');

    $u
}

sub F_delta {
    my $now = hitime();
    my $then = $F[0]->{hitime};
    my $d = sprintf("%.3f",$now-$then);
    $d = $d<1 ? ($d*1000).'ms' : $d.'s';
}

sub inter {
    my $thing = shift;
    my $ki = ki($thing);
    $ki =~ s/^\s+//;
    $F[1]->{inter} .= " -{".$ki."}\n";
}

sub intr {
    my ($k, $v) = @_;
    $F[0]->{intr}->{$k} = $v;
}

sub loadup {
    my $G = shift;
    my ($i, $k, $v) = @_;
    my $s = $G->snapple($k); # chunks {G{GG{etc 3
    $s->{e} = $v;
    $G->suets($i, $s);
}

sub suets {
    my $G = shift;
    my ($i, $s) = @_;
    $s = {s=>[$G->chuntr($s)]} if !ref $s;
    my @s = @{$s->{s}};
    my $end = pop @s if exists $s->{e};
    my $last;
    while (1) {
        my $ac = shift @s || do {exists $s->{e} || last; $last=1; $end};

        $ac =~ /^(\W)(.*)$/ || die "$ac !".G::wdump($s);

        if ($last) { # TODO know about insto hash or array...
            if (exists $s->{e}) {
                $i->{$2} = $s->{e} if $1 eq "{";
                $i->[$2] = $s->{e} if $1 eq "[";
            }
            last;
        }
        elsif ($1 eq '{') {
             $i = $i->{$2} ||=
                  $s->{noset} ? return undef : {};
        }
        elsif ($1 eq '[') {
             $i = $i->[$2] ||=
                  $s->{noset} ? return undef : {};
        }
        else {
             die "je seuits $1?";
        }
    }
    $i
}

sub suet {
    my $G = shift;
    my ($i,$s) = @_;
    $s = {s=>[map{"{$_"}split'/',$s]};
    $G->suets($i,$s);
}

sub gip {
    my $G = shift;
    my ($i,$s) = @_;
    $s = {s=>[map{"{$_"}split'/',$s]};
    $s->{noset} = 1;
    $G->suets($i,$s);
}

sub snapple {
    my $G = shift;
    my $k = shift;
    ($k, my $v) = $k =~ /^(\S+)(?: (.+))?$/;
    my $a = {k => $k, v => $v};
    my @s;
    while ($k =~ m/(\W\w+)/sg) {
          push @s, $1;
    }
    $a->{s} = \@s;
    $a
}

sub catchings {
    my $G = shift;
    $SIG{__WARN__} = sub {
       my $ing = shift;
       warn$ing unless $ing =~ /^Use of uninitialized/;
    };
}

sub Loadc {
    my $yaml = shift;
    $@="";

    $SIG{__DIE__} = undef;
    $SIG{__WARN__} = undef;
    my $w = eval {
    YAML::Syck::Load($yaml)
    } ;
    sayyl ki 1, {yml=>$yaml,w=>$w};

           if ($@ || !$w || $@) {
               say $@;
               my ($x, $y) = $@ =~
                     /parser \(line (\d+), column -?(\d+)\)/;

               my @file = split "\n",  $yaml;
               my $xx = 1;
               my $vision = 'SYCK SYCJK'; 
               for (@file) {
                 if ($x - 8 < $xx && $xx < $x + 5) {
                   if ($xx == $x) {
                     $vision .= "HERE > $_\n";
                     $vision .= "HERE > ".join("", (" ")x$y)."^\n";
                   }
                   else {
                     $vision .= "       $_\n";
                   }
                 }
                 $xx++;
               }
               sayre "! YAML load failed: "
               .($@ ? $@ : "got: ".($w || "~"))
               ."\n\n".$vision;
               $@ = "";
           }
     $w
}

sub fspu {
    my $file = shift;
    my $m = encode_utf8 shift;
    write_cone($file, $m);
}

sub fscc {
    my $file = shift;
    my $m = encode_utf8 shift;
    write_cone($file, {append=>1}, $m);
}

sub tai {
    my $G = shift;
    my ($f,$n) = $G->taR(@_);
    fspu($f, "$n\n");
    #saybl '  tai fspu '.$f.'    '.slim(30, $n);
}

sub tac {
    my $G = shift;
    my ($f,$n) = $G->taR(@_);
    fscc($f, "$n\n");
    #saybl '  tac fscc '.$f.'    '.slim(30, $n);
}

sub tas {
    my $G = shift;
    my ($fs,$n,$x) = $G->taR(@_);
    my $f = $G->msc($x);
    fscc($f, "$n\n");
    #saybl '  tas fscc '.$f.'    '.slim(30, $n);
}

sub tri {
    my $G = shift;
    my ($f) = $G->taR(@_);
    return if !-f $f;  
    read_file($f);
}

sub taR {
    my $G = shift;
    # MZ $f,$n
    my ($f, $n) = @_;
    my $x = $G->spc($f);
    $n = zjson($n) if ref $n;
    ($x->{fi}, $n, $x)
}

sub zjson {
    my $n = shift;
    if ($n->{J}) {
        $n = {%$n};
        delete $n->{J};
    }
    sjson($n)
}

sub ztm {
    my $aj = shift;
    return {map{$_=>$aj->{$_}}'y','id'};
}

sub ily {
    my $G = shift;
    say "Jep: ".join '  ', @_;
    my $l = pop;
    my $x = $G->spc(@_);
    $x->{l} = $l;

    saybl "        ily: $x->{fi}"; 

    for (@{$x->{lots}}) {
        my $file = $x->{fi}.'.'.$_;

        $G->tailf($x, $file);
    }

    $G->wtfy($x);
    $x
}

sub su {
    my $G = shift;
    $G->ily(@_);
}

sub pub {
    my $G = shift;
    my ($S, $m, $ig) = @_;
    sayyl "H pub $S < ".G::slim(50,50,$m) if !$ig;
    $G->tas($S, $m);
}

sub spc {
    my $G = shift;
    my $f = pop;
    if ($f =~ /\x{0}/) {
        run(-in => sub{ print $f."\n"; },
            -out => '/tmp/fuuf',
            'xxd');
        sayre "NON ! ".`cat /tmp/fuuf`; 
    }
    my $o = pop || $G->{lifespot} || 'life';
    my $fi = "$o/$f";
    my $x = $G->{taily}->{f}->{$fi} ||= {};
      if (!$x->{fi}) {
          $x->{fi} = $fi;
          $x->{f} = $f;
          $x->{o} = $o;
          $fi =~ /^(.+)\/(.+?)$/;
          $x->{t} = $2;
          $x->{d} = $1;
          $x->{lots} = ['sc','sc2'];
      }
      for (grep {$x->{$_} =~ /\x{0}/} keys %$x) {
          say "nully $_ => $x->{$_}";
          run(-in => sub{ print $x->{$_}."\n"; },
            -out => '/tmp/fuuf',
            'xxd');
          #say "MSC ZOOP:", ''.`cat /tmp/fuuf`;
      }
      if (0){
        }
    $x
}

sub msc {
    my $G = shift;
    my $x = ref $_[0] ? $_[0] : $G->spc(@_);
    my $link = $x->{fi}.'.s';

    return $link if -l $link;

      my $s = `readlink $link` || do {
          $link =~ s/[^\w\/\-\.]//g; # TODO nully
          `readlink $link` || do {
              say "try again: $link";
              my $jsu = `ls -l $link`;
              sayre ' lsd: '.$jsu;
              saybl "JSU ". `pwd`;
              $jsu =~ /-> (.+)$/sgm;
              sayre " re - $1";
              $1;
          };
      };
      chomp $s;
      sayre "msc $link -> '$s'" unless $s =~ /^(J|Hostinfo|doc)\./;
      if (!$s) {
          say "auto sc (said $s) $x->{fi}    from $link";
          $G->wtfy($x); # makes a .s -> .sc
          snooze(2500);
          $G->{mscily}++;
          die "TOO MUCH TRIP looking for $link" if $G->{mscily} > 5;
          my $f = $G->msc($x);
          $G->{mscily}--;
          return $f;
      }
      # so appends can sense together before even .cing
      $x->{d}.'/'.$s
}

sub wtfy {
    my $G = shift;
    my $x = shift;
    my $link = $x->{fi}.'.s';

    my $s = readlink $link if -e $link;
    my $ex = $1 if $s && $s =~ /\.(.+?)$/;
    my ($next) = reverse reverse(@{$x->{lots}}), reverse grep { !$ex || $_ eq $ex && do {$ex=0} } @{$x->{lots}};
    # forth and around
    my $wt = $x->{t}.'.'.$next;

    sayyl "ln -fs $wt $link";

    my $fis = "$x->{d}/$wt";
    if (!-e $fis) {
        fscc($fis, '');
    }

    symlink $wt, $link;
    #`ln -fs $wt $link`;

    if ($s) {
        my $sif = $x->{d}.'/'.$s;
        # TODO acquire lock (first hol line in lock file wins, wait 0.1)
        $G->sing("cleam$sif", sub {
            my $siz = -s $sif;
            $G->timer(2.3, sub {
                $G->squash($x, $sif, $siz);
            });
        }, begin => 0.4);
    }
}

sub squash {
    my $G = shift;
    my $x = shift;
    my $sif = shift;
    my $siz = shift;
    my $siz2 = -s $sif;
    if ($siz != $siz2) {
        #warn "$sif got written to sinze changing link!?";
    }

    fspu($sif, '');

    sayre "Cleaned $sif";
}

sub tailf {
    my $G = shift;
    my $x = shift;
    my $file = shift;
    sayyl "Tailing $file";

    fscc($file, '');
    die "go figgy $file" unless -f $file;

    my $al = $x->{s}->{$file} ||= {}; 
    open my $ha, '-|','tail', '-q',
        '-s','0.1','-F','-n0',
        $file
        or die $!;
    $al->{s} && $al->{s}->close;
    my $s = $al->{s} = Mojo::IOLoop::Stream->new($ha);
    $al->{h} = $ha;
    $al->{x} = $x;
    $al->{file} = $file;

    $s->on(read => sub {
        my ($s,$b) = @_;
        fixutf8($b);
        $G->l_lines($al->{x}, $b, $al->{file});
    });
    $s->on(close => sub {
        my $s = shift;
        die "$al->{file} closed!?";
    });
    $s->on(error => sub {
        my ($s, $err) = @_;
        die "$al->{file} err: $err";
    });
    $s->timeout(0);
    $s->start;
    #$s->reactor->start unless $s->reactor->is_running;
}

sub burp {
    my $G = shift;
    my $x = shift;
    my $file = shift;
    my $time = hitime;
    $x->{hitime} ||= $time;
    if ($time - $x->{hitime} > 42 && -s $file > 8000) {
        $G->wtfy($x);
    }
}

sub l_lines {
    my $G = shift;
    my $x = shift;
    my $b = shift;
    my $file = shift;

    $G->burp($x, $file);

    if($b =~ /\x{0}/) {
        say "nully $b =>";
        run(-in => sub{ print "$b\n"; },
          -out => '/tmp/fuuf',
          'xxd');
        say "MSC ZOOP:", ''.slim(100,`cat /tmp/fuuf`);
    }
    for my $m (split "\n", $b) {
        next unless $m;

        $x->{l}->($m);
    }
}

sub write_cone {
    my $arm = [@_];

    # so stupidly retarded
    # use quantum fector to drop things down
    # exhaustingly haphazard machinery crammed into the rounding error factory
    # make rounding error factory factory
    eval { write_file(@$arm) };
    if ($@) {
        my ($file) = @$arm;
        if ($@ =~ /sysopen: No such file or directory/) {
        }
        elsif ($@ =~ /sysopen: Is a directory/) {
            my $wtah = "-f $file == ".-f $file;
            warn "thinks it's a directory: $wtah";
        }
        else {
            die "UNKNOWN WRITE CONE E\n\n$@"
        }
        sayre "Recovering from write error::: $@";
        my $fore = $file;
        $file =~ s/[^\w\/\-\.]//g; # TODO nulls
        if ($fore ne $file) {
                warn "NONNAMES OR SO, HEXDUMP IT $fore -> $file";
        }

        my @chun = split '/', $file;
        my $fn = pop @chun;
        say "    file: $file";
        my @try = shift @chun;
        push @try, join '/', $try[-1], $_ for @chun;
        my @nodir;
        for my $d (reverse @try) {
            if (-d $d) {
                sayyl "$d DIR EXISTS!";
                last;
            }
            push @nodir, $d;
        }
        say "Not existing dirs: ".wdump[@nodir];
        sayre "Weeor was $!";
        undef $!;
        say "==========";
        my $broke;
        for my $d (reverse @nodir) {
            saybl "try to make_path $d";
            mkdir $d;
            if ($!) {
                sayre "mkdir $d: $!";
                $broke = 1;
            }
            if (!-d $d) {
                sayre "not exist after";
                $broke = 1;
            }
        }

        sayyl "Doing again---";
         eval {
           write_file(@$arm)
         };
         if ($@) {
           say "Fucked up again: $@";
         }


        if ($broke) {
            warn "cionedddd.....\n\nWrite $file fuckup: $@";
        }
        $@ = "";
    }
}

sub djson {
    my $m = shift;
    my $j;

    eval { $j = $JSON->decode(encode_utf8($m)) };
    die "JSON DECODE FUCKUP: $@\n\nfor $m\n\n\n\n" if $@;
    die "$m\n\nJSON decoded to ~undef~" unless defined $j;
    $j
}

sub ejson {
    my $m = shift;
    $JSON->encode($m);
}

sub sjson {
    my $m = shift;
    $H->{canon}||= do {
       my $j = new JSON::XS;
       $j->canonical(1);
       $j
    };
    $H->{canon}->encode($m);
}

sub jsq {
    my ($s,@e) = @_;
    sprintf $s, map { ejson($_) } @e
}

sub fixutf8 {
    for (@_) {
      if (!is_utf8($_)) {
        $_ = decode_utf8($_); 
      }
    }
    return shift if @_ == 1
}

sub E {
    $H->send(@_);
}

sub parse_babble {
    my $G = shift;
    my $eval = shift;

    my $AR = qr/(?:\[(.+?)\]|(?:\((.+?)\)))/;
    my $G_name = qr/[\/\w]+/;
    my $Gnv = qr/\$?$G_name/;
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


    my $Jsrc = qr/(J\d*(?:\.\w+)?) (\w+)/;
    # thingy, cv => thing
    my $Jlump = qr/(\S+) (\S+)\s+(\S.+)/;
    $eval =~ s/$mwall$Jsrc $Jlump$/$1.$2->("$3\\t$4" => $5);/smg;

    $eval =~ s/($mwall)(\w?J)n\(/$1$2\.no->(\$$2, /smg;
    $eval =~ s/($mwall)(\w?M)n\(/${1}J\.no->(\$$2, /smg;


    #$eval =~ s/waylay (?:($NUM) )?(\w.+?);/\$G->timer("$1",sub { w $2; },"waylay $2");/sg;

    # wholeness Rwish #

    my $sur = qr/ if| unless| for| when|,\s*$|;\s*/;
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
            if (/^\$((\w+(:|=))?\S+)$/) {
                my ($na, $fa, $wa) = ($1, $2, $3);
                if (!$fa) { # fake name, to ar
                    $fa = $na;
                }
                else {
                    $na =~ s/^\Q$fa\E//;
                    $fa =~ s/(:|=)$//;
                    if ($wa eq '=') {
                        $na = '"'.$na.'"';
                    }
                }
                $na = '$'.$na unless
                    $wa eq '=' || $na =~ /^\S+\.\S/;
                #saygr "from: $a          na: $na";
                push @n, "$fa => $na" ; # also avail a listy position
            }
            else {
                push @m, $_;
            }
        }
        unshift @n, '%$ar' if (!@n || $wanr) && $wanr ne "stick"; 

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
            $delay =~ /yl ($NUM)/;
            $delay = $1 || "";
            $wa = '$G->timer("'.$delay.'",sub { '.$wa.' })';
        }

        #saygr " $old \t=>\t$wa \t\t\tg$g \tu$u \tp$p \ta$a \tun$un";

        $eval =~ s/\Q$old\E/$wa/          || die "Ca't replace $1\n\n in\n\n$eval";
    }

    # way
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
    #warn "G::K() no A n_$n: ".$A->pi."  ".join("  ", sort keys %$A) if !$lot;
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

sub CsK {
    my $G = shift;
    my ($p, $GG) = @_;
    $GG ||= $G;
    $p->{s} ||= 'C';
    my @topK = delete $p->{s};
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
    $c = ($c=~/^(.{$t})/s)[0]."..".(length($c) - $f) if length($c) > $f;
    $c
}

sub slm {
    my $s = slim(@_);
    $s =~ s/\.\.(\.|\d+)$//;
    $s
}

sub acum {
    my ($n, $y, $c) = @_;
    push @{$n->{$y}||=[]}, $c;
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

sub dig {
    Digest::SHA::sha1_hex(encode_utf8(shift))
}

sub snooze {
    return Time::HiRes::usleep((shift || 500) * 10);
}

sub wag {
    $H ||= {up=>hitime()};
    my $G = bless {}, 'G';
    $G->{id} = mkuid();
    $G->{name} = "theG";
    $G->catchings;
    $G->wayup("wormhole/yb\.yml");
    $G->w('expro');
    Mojo::IOLoop->start unless Mojo::IOLoop->is_running;
}

sub wayup {
    my $G = shift;
    my $way = read_file(shift);
    $G->{way} = Load($way); 
}

sub g_parse_babble {
    my $G = shift;
    my $eval = shift;

    my $AR = qr/(?:\[(.+?)\]|(?:\((.+?)\)))/;
    my $G_name = qr/[\/\w]+/;
    my $Gnv = qr/\$?$G_name/;
    my $mwall = qr/(?:= |if |^\s*)/m;




    # word or scalar
    my $point = qr/[\w\$\/\->\{\}\*]*[\w\$\/\->\.\}\*]+/;

    my $alive = qr/\$[\w]*[\w\->\{\}]+/;
    # a.b.c
    my $dotha = qr/[A-Za-z_]\w{0,3}(?:\.[\w-]*\w+)+/;

    my $poing = qr/$alive|$dotha|[-\w]{8,}/;

    # [...]
    my $sqar = qr/\[.+?\]|\(.+?\)/; 

    # timer

    $eval =~ s/(timer|recur) ($NUM|$alive) \{/$1 \$G, $2, sub{/sg;

    $eval =~ s/aft \{/accum \$G, \$F[0] => _after_do => sub {/sg;


    my $Jsrc = qr/(J\d*(?:\.\w+)?) (\w+)/;
    # thingy, cv => thing
    my $Jlump = qr/(\S+) (\S+)\s+(\S.+)/;
    $eval =~ s/$mwall$Jsrc $Jlump$/$1.$2->("$3\\t$4" => $5);/smg;

    # oJn -> oJ.n->( ish
    $eval =~ s/($mwall)(\w*A)(\w+)\(/$1$2\.$3->(\$J, /smg;
    # or w
    $eval =~ s/($mwall)(\w*G)(\w+)\(/${1}g\.$3->(\$A,\$C,\$g,\$T, /smg;
    $eval =~ s/($mwall)(\w*J)(\w+)\(/$1$2\.$3->(\$$2, /smg;
    $eval =~ s/($mwall)(\w*M)(\w+)\(/${1}J\.$3->(\$$2, /smg;

    # lma quack $not->('tag');
    $eval =~ s/($poing|\w+)\&($point)(,[^\s;]+)?(;)?/
    my $s = "$1->(\"$2\"$3)$4";
    $s = '$'.$s if $1 !~ m{\.};
    $s
    /smge;


    # $sc>$k -> $sc->{$k}
    $eval =~ s/($poing)((?:\.>$poing)+)/
    join '->', $1, map {'{"'.$_.'"}'} grep {$_} split m{\.>}, $2;
    /smge;


    #$eval =~ s/waylay (?:($NUM) )?(\w.+?);/\$G->timer("$1",sub { w $2; },"waylay $2");/sg;

    # wholeness Rwish #

    my $sur = qr/ if| unless| for| when|,\s*$|;\s*/;
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
            if (/^\$((\w+(:|=))?\S+)$/) {
                my ($na, $fa, $wa) = ($1, $2, $3);
                if (!$fa) { # fake name, to ar
                    $fa = $na;
                }
                else {
                    $na =~ s/^\Q$fa\E//;
                    $fa =~ s/(:|=)$//;
                    if ($wa eq '=') {
                        $na = '"'.$na.'"';
                    }
                }
                $na = '$'.$na unless
                    $wa eq '=' || $na =~ /^\S+\.\S/;
                #saygr "from: $a          na: $na";
                push @n, "$fa => $na" ; # also avail a listy position
            }
            else {
                push @m, $_;
            }
        }
        unshift @n, '%$ar' if (!@n || $wanr) && $wanr ne "stick"; 

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
            $delay =~ /yl ($NUM)/;
            $delay = $1 || "";
            $wa = '$G->timer("'.$delay.'",sub { '.$wa.' })';
        }

        #saygr " $old \t=>\t$wa \t\t\tg$g \tu$u \tp$p \ta$a \tun$un";

        $eval =~ s/\Q$old\E/$wa/          || die "Ca't replace $1\n\n in\n\n$eval";
    }

    # way
    while ($eval =~ 
    /\${0}($poing )?((?<![\$\w])w(aylay(?: $NUM)?)?(?: ($poing))? ($point)( ?$sqar| ?$point|))($sur)?/sg) {
        my ($g, $old, $delay, $u, $p, $a, $un) = ($1, $2, $3, $4, $5, $6, $7);
        die wdump[$old,$eval];
    } 

    # 8/9

    $eval =~ s/\${0}($poing)? K ($point)(?::($point))?(;| )/
    ($1 || '$G')
    .qq {->K("$2","$3")$4}/seg;

    $eval =~ s/(?<!G)0->(\w+)\(/\$G->$1(/sg; 

    $eval =~ s/(?:(?<=\W)|^)(?<!\\)([A-Za-z_]\w{0,3})((?:\.[\w-]*\w+)+)/"\$$1".join"",map {"->{$_}"} grep {length} split '\.', $2;/seg;


    $eval;
}

sub fwind {
    my $way = shift;
          my $point = shift;
          my @path = split /\/|\./, $point;
          my $h = $way;
          for my $p (@path) {
              $h = $h->{$p};
              unless ($h) {
                  undef $h;
                  last;
              }
          }
          return $h if defined $h;

          return undef unless $point =~ /\*/;
          die "sat rs findy $point";
}

sub g_w {
    my $G = shift;
    my $am;
    #die wdump [@_] if @_ > 1;
    $am->{point} = shift;
    $am->{ar} = shift;

    $am->{name} = join ' ', $am->{point}, sort keys %{$am->{ar}};
    $am->{sign} = "Z";
    $am->{talk} = "$am->{sign} $am->{name}";

    $am->{bab} = fwind($G->{way}, $am->{point});

    if (!defined $am->{bab}) {
        warn $G->pi."    way miss $am->{talk}"
            if !($G->{misslesswa} ||= {map{$_=>1} qw'
                fresh_init any_init recoded_init
                percolate_R percolate load_ways_post aj event
            '})->{$am->{point}};
        return;
    }

    my $Z = $G->Doming($am);
    $G->{randomtask}->() if $G->{randomtask};
    my $r;
    eval { $r = [ $G->D($am) ] };
    $G->Done($Z);

    if ($@) {
        my $ne = "Z";
        $ne .= $Z->{inter} if $Z->{inter};
        $ne .= "\n";
        $ne .= "$@";
        $@ = $ne;
        die $@ unless $am->{nodie};
        $@ = "";
    }
    return wantarray ? @$r : $r->[0];
}

sub g_pyramid {
    my $G = shift;
    my $am = shift;
    confess "Ba" if ref $am ne 'HASH';

    my ($last) = @F;
    my $u = {%$am};
    if ($last) {
        push @{$last->{Lo}||=[]}, $u;
        $u->{Li} = $last;
    }
    else {
        push @{$G->{East}||=[]}, $u;
    }

    $u->{G} = $G;
    $u->{K} = $u->{name} || die;
    $u->{hitime} = hitime;
    $u->{order} = $H->{pyramiding}++;
    $u->{stack} = stack(2,7);
    $u->{F} = [@F];
    $u->{depth} = 0+@F;
    $u->{Error} = $@ if $@; #?

    $u
}

sub g_Dm {
    my $G = shift;
    my $am = shift;

    $am->{talk} || confess wdump 2, $am;
    my $Ds = $G->{drop}->{Dscache}->{$am->{talk}};
    return $Ds if $Ds;

    die "SOMEONENONE".wdump 1, $am if ref $am->{bab};

    my $eval = $G->parse_babble($am->{bab}, $am->{point});

    my $ar = $am->{ar} || {};
    $ar->{R} = $G;
    my $download = join("", map {
        'my$'.$_.'=$ar->{'.$_."}; "
        } keys %$ar)
        if %$ar;
    my $upload = join("", map {
        '$ar->{'.$_.'}=$'.$_."; "
        } keys %$ar)
        if %$ar;

    my @warnings;
    my $sub = "bollox";
    my $evs = 'sub { my $ar = shift; '.
    "@warnings $download\n".

    "my \@doo_return = (sub { \n\n$eval\n })->();\n"

    ."$upload"
    .'return @doo_return };';


    $sub = $G->Doe($evs, $ar);

    $@ = "nicht kompilieren!\n\n$@" if $@;

    $Ds = {evs=>$evs, sub=>$sub, talk=>$am->{talk}};

    if (!$@ && ref $sub eq "CODE") {
        $G->{drop}->{Dscache}->{$am->{talk}} = $Ds;
    }
    else {
        $am->{bungeval} = $evs;
    }
    $Ds
}

sub g_D {
    my $G = shift;
    my $D = shift;
          my $ar = $D->{ar} || {};

          die "RECURSION ".@F if @F > $MAX_FCURSION;
          my $sub = $D->{D} || do {
               $D->{Ds} = $G->Dm($D);
               $D->{Ds}->{sub};
          };
          #ref $sub eq 'CODE' || die wdump [ $@, $D ];

          # TODO getonwithitnciousness
          $D->{sign} = 'D';
          $D->{talk} = "$D->{sign} $D->{name}";
          $D = $G->Doming($D);

          $G->{sigstackend} ||= sub {
              local $@;
              eval { confess( '' ) };
              my @stack = split m/\n/, $@;
              shift @stack for 1..3; # hide above this sub, G eval & '  at G...';
              my @stackend;
              push @stackend, shift @stack until $stack[0] =~ /g::ggggggg/ || !@stack && die;
              s/\t//g for @stackend;

              # write on the train thats about to derail
              my $wall = $G::F[0]->{SigDieStack}||=[];

              push @$wall, \@stackend;
          };
          $G->{sigstackwa} ||= sub {
              return 1 if $_[0] =~ /^Use of uninitialized value/;
              if ($_[0] =~ /Deep recursion on/) {
                 sayre "snoozing $F[0]->{talk}";
                 snooze();
                 return;
              }
              my @loc = caller(1);
              $@ = join "\n", @_;
              my $DOOF = $G->Duck($F[0],1);
              $@ = "";
              sayre $DOOF;
              return 1;
          };

          my @return;
          if (ref $sub eq "CODE" && !$@) {
              local $SIG{__DIE__} = $G->{sigstackend};
              local $SIG{__WARN__} = $G->{sigstackwa};

              #sub ggggggg {eval{shift->(@_)}}
              wantarray ? 
              do { @return = ggggggg($sub, $D->{ar}) }
              : do { $return[0] = ggggggg($sub, $D->{ar}) };
              #eval {  = $sub->($a->{ar}) }
          }

          $G->Done($D); # Ducks
          $D->{r} = [@return];


          return wantarray ? @return : shift @return
}

sub g_Duck {
    my $G = shift;
    my $D = shift;
    my $nodie = shift;
    my $evs = $D->{Ds}->{evs};
    my $ar = $D->{ar};

    my $DOOF; 
    my $first = 1 unless $@ =~ /DOOF/;

               $DOOF .= "DOOF $D->{talk}\n" if $D->{sign} eq 'D';
               $DOOF .= "  $D->{inter}" if $D->{inter};

               if ($first) {
                   my $x = $1 if $@ =~ /syntax error .+ line (\d+), near/
                       || $@ =~ /line (\d+)/;

                   my $file = $1 if $@ =~ /at (\S+) line/;

                   undef $file if $file && $file =~ /\(eval \d+\)/;
                   undef $file if $file && !-f $file;

                   my $code = $file ? 
                   read_file($file)
                   : $evs;

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
                   my $in = $D->{sign} eq 'D' ? "! " : "";
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

               return $DOOF if $nodie;

               $D->{Error} = $DOOF;
               $@ = $DOOF;

               if (@F == 1) {
                   # send it away
                   $DOOF = join"\n",map{s/^(\! )+//smg if !/DOOF/; $_}split"\n",$DOOF;
                   sayre $DOOF;
                   $G->{dooftip} && $G->{dooftip}->($@);
                   $@ = "";
                   $_->() for @{$G->{_aft_err_do}||[]};
               }
               else {
                   die $@;
               }
}

my $g = 9;

