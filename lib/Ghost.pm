package Ghost;
use strict;
use Scriptalicious;
use File::Slurp;
use JSON::XS;
use YAML::Syck;
use HTML::Entities;
use Way;
use List::Util qw(first max maxstr min minstr reduce shuffle sum);
sub ddump { Hostinfo::ddump(@_) }
sub wdump { Hostinfo::wdump(@_) }
sub htmlesc { encode_entities(shift) }
sub flatline { map { ref $_ eq "ARRAY" ? flatline(@$_) : $_ } @_ }
sub findO { my ($k, $o) = @_; grep { $_->{O} eq $k } @$o }
use Carp 'confess';
use Term::ANSIColor;
use File::Find;
our $H;
our @F;
our @Flab;
our $G0;
our $Ly;
our $db = 0;
our $_ob = undef;
our $MAX_FCURSION = 140;
our $U;
our $T;
sub new {
    my $self = bless {}, shift;
    shift->($self);
    delete $self->{hostinfo}; # TODO put this back once travelling feels right

    $self->{T} = shift;
    
    my $name = $self->{T}->{name};
    
    $self->{O} = $self->{T}->{O};
    $self->{GG} = [];
    
    my @ways = @_;
    say "way spec @_";
    unless (@ways) {
        my $s = { map { $_ => (/^(\w)/)[0] }
            qw{Ghost Hostinfo Lyrico Travel Wormhole} };
        
        my $guess = ref $self->{T}->{O};
        $guess = $s->{$guess} if $s->{$guess};
        say " . . guess way is $guess";
        @ways = $guess;
    };
    my $way = join", ",@ways;
    $name = "$name`($way)";
    $self->{name} = $name;
    $self->{way} = $way;
    say "Ghost named $name";
    $self->load_ways(@ways);

    if ($self->tractors) {
        $H->TT($self)->G("W/tractor");
    }
    
    if (ref $self->{T}->{O} eq "Ghost") {
        push @{$self->{T}->{O}->{GG}}, $self;
    }
    

    return $self;
}
sub gname {
    my $g = shift;
    my $si = shift || 0;
    my $ish = ref $g;
    my $ush = "$g";
    my $may = $g->{name} || $g->{id} if $ish && $ush =~ /HASH/;
    $may ||= (0+keys %$g)."{" if $ish eq "HASH";
    $may ||= "$g";
    $may =~ s/^(\w+)=HASH.*$/$1\{/;
    $may;
}
sub hitime { Hostinfo::hitime() }
sub pint {
    my $w = shift;
    $w && ref $w eq "Way" ? $w->pint : "ww:".join"",map { s/\s//sg; $_ } wdump(2,$w)
}
sub U {
    my ($G, $Usub, @etc) = @_;
    $G->{U}->{$Usub} || confess "no U $Usub";
    $G->{U}->{$Usub}->(@etc);
}
sub mess {
    my $G = shift;
    $H->{G}->w(mess => {what => shift, thing => shift});
}
our $gp_inarow = 0;
sub ghostlyprinty {
    $gp_inarow++;
    my $witcolour = sub { '<t style="color:#'.($_[1] || '8f9').';">'.shift.'</t>' };
    if ($_[0] && $_[0] eq "NOHTML") {
        shift;
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
            push @s, map { "[".ghostlyprinty($_) } @$t;
        }
        elsif (ref $t) {
            push @s, $witcolour->(ref($t), "333;font-size-adjust:0.5");
            push @s, $witcolour->(gname($t));
        }
        else {
            push @s, (defined $t ? $t : "~")
        }
    }
    $gp_inarow--;
    join "  ", @s
}
sub pty { my $t = shift; ref $t eq "Way" ? pint($t) : gpty($t) }
sub gpty { ghostlyprinty('NOHTML',@_) };
sub Flab {
    my $G = shift;
    ref $G eq "Ghost" || die "send Ghost";
    say join("",(".") x scalar(@F))."$G->{name}  $_[0]"
        if (($G->{db}||0) + ($db||0)) > 0
            && $_[0] !~ /^\w Error/;
    $G->ob(@_);
    my $s = $G->stackway(@_);
    unshift @Flab, $s;
    $s->{Flab} = [@Flab];
    $s;
}
sub waystacken {
    my $G = shift;
    my $s = $G->stackway(@_);
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
                $E .= "from $_->{name}" for shift @FF;
            }
            $G->mess(BATS => $G->Flab($E, $s, [@FF], [@F]));
        }
        else {
            shift @F;
        }
        
        if ($@) {
            #$G->Flab("Stack Return Error", $s, $@);
            $s->{Error} = $@;
        }
        $s->{Flab} = [@Flab];
        
        if ($s->{_after_do}) {
            $_->() for @{$s->{_after_do}};
        }
        
        my $te = $@; $@ = "";
        $G->ob("/", $s);
        $@ = $te;
        @Flab = ();
        $s
    };
    wantarray ? ($unway, $s) : $unway;
}
sub timur {
    if ($G0) {
        $G0->timer(@_);
    }
    else {
        $H->timer(@_);
    }
}
sub timer {
    my $G = shift;
    my $time = shift || 0.001;
    my $doing = shift;
    my $st = " ".$_[0] if $_[0] && !ref $_[0];
    $st ||= "";
    my $last = $G->Flab("G Timer$st", @_);
    
    my $doings;
    $doings = sub { $G->comeback($last, $doings, $doing, @_); };
    Mojo::IOLoop->timer( $time, $doings );
    return $last
}
sub comeback {
    my $G = shift;
    my $last = shift;
    my $doings = shift;
    my $doing = shift;
    my @saying = @{ $last->{thing} };
    $saying[0] =~ s/G Timer/G remiT/ || unshift @saying, "G remiT";
    my ($u, $s) = $G->waystacken(@saying, @_);
    $s->{doings} = $doings;
    $s->{timer_from} = $last;
    $last->{timer_back} = $s;
    eval { $doing->(); };
    $u->();
    if ($@) {
        $H->error($s) if $@;
    }
}
sub printF {
    my $G= shift;
    my $F = [@F];
    $G->_0(printF => {FFF=>$F});
}
sub stackway {
    my $G = shift;
    my $thing = [@_];
    my $w = $G->nw;
    my $stack = $H->stack(1);
    my $from;
    # FUZZ!
    if ($stack->[0] =~ /Ghost::timer/) {
        $from = "time"
    }
    elsif ($stack->[1] =~ /Ghost.+eval.+/
        && $stack->[2] =~ /Ghost::doo/) {
        $from = "some doing..."
    }
    else {
        ($from) = $stack->[1] =~ / (\S+::\S+) /;
        $from =~ s/.*Ghost::(Fl|wa).*/$1/;
        $from =~ s/^Fl$/ᣜ/;
        $from =~ s/^wa$/ᣝ/;
        $from =~ s/Ghost::/G:/;
    }
    $from ||= "stackw $stack->[0]";
    shift @$stack;
    
    $w->from({
        K => "$from",
        G => $G,
        hitime => $H->hitime(),
        stack => $stack,
        Flab => [@Flab],
        F => [@F],
        depth => 0+@F,
        thing => $thing,
        print => 'join " ", grep {defined $_} $S->{G}->{way}, $S->{K}, ghostlyprinty(@{$S->{thing}})',
    });
    $w->from({Error=>$@}) if $@;
    $w->{name} = join " ", grep {defined $_} $w->{G}->{way}, $w->{K}, ghostlyprinty(@{$w->{thing}});
    $w;
}
sub F_delta {
    my $G = shift;
    my $now = $H->hitime();
    my $then = $F[0]->{hitime};
    $H->error("F_delta shows $now < $then;", $F[0]) if $now < $then;
    my $d = sprintf("%.3f",$now-$then);
    $d = $d<1 ? ($d*1000).'ms' : $d.'s';
}
sub ob {
    my $G = shift;
    my $ob = $G->{_ob}||$_ob;
    return unless $ob;
    my $s = $G->stackway(@_);
    my $te = $@; $@ = "";
     my $to = $_ob; $_ob = undef;
      
      $ob->T($s);
      
     $_ob = $to;
    $@ = $te;
}
sub ki {
    my $ar = shift;
    my $s = "";
    for my $k (sort keys %$ar) {
        my $v = $ar->{$k};
        $v = "~" unless defined $v;
        #$v = "( ".gname($v)." )" if ref $v;
        $s .= "   $k=$v";
    }
    return $s;
}
sub idname {
    my $self = shift;
    $self->{id}."-".$self->{name}
}
sub T { # TODO funny
    my $self = shift;
    $self->T->T(@_) if @_;
    $self->{T};
}
sub Tw {
    my $G = shift;    
    my ($GG, $wp, $war, $thing) = @_;
    $GG || die "NO Tw GG! $G->{name}        w $wp  ".ki($war);
    
    my $w = $G->nw();
    $w->{arr_hook} = $wp if $wp;
    $w->{arr_ar} = $war if $war;
    $w->{thing} = $thing if $thing;
    $w->{print} = "'$G->{way} ⰱ $wp'";
    # travel to a wp in another ghost
    # we see this somewhere
    # so we can interfere case left
    
    # here (but not constructed here) is where ways may pool
    #   for more thinking before travelling
    #   parallel, streaming...
    my $u = $G->waystacken("Tw $wp", $GG, $w);
    $w->{waystack} = $F[0];
    my @r = $GG->T->T($thing, undef, $w);
    my $Tw = $u->();
    $Tw->{Returns} = [@r];
    
    return wantarray ? @r : $r[0];
}
sub Gf {
    my $self = shift;    
    my $way = shift;

    # TODO self or $S etc
    my @Gs =
        grep { $_->{way} =~ /$way/ } @{ $self->{GG} };
    
    #die "Gf = ".scalar(@Gs)." $self->{name}   $way " if @Gs != 1;
    
    shift @Gs;
}
sub Gc { # TODO merge into ^ 
    my $self = shift;
    $H->TT($self)->G(@_);
}
sub W {
    my $self = shift;
    return $self->{W} if $self->{W};
    $self->{T}->{W} ||= Wormhole->new($H->intro, $self, "wormholes/$self->{name}/0");
}
sub RW {
    my $self = shift;
    my $OW = $self->W->{script};
    $self->W->{script} = [];
    $self->W->{n} = 0;
    $OW;
}
sub load_ways {
    my $self = shift;
    my @ways = @_;
    my $p = shift @ways if ref $ways[0] eq "HASH";
    $p ||= {};
    my $ws = $self->{ways} ||= [];
    my $wfs = $self->{wayfiles} ||= [];
    $self->{load_ways_count}++;
    
    my $ldw = [];
    for my $name (@ways) {
        my @files;
        
        my $base = "ghosts/$name";
        if (-f $base) {
            push @files, $base;
        }
        else {
            push @files, grep { /\/\d+$/ } glob "$base/*";
        }
        
        for my $file (@files) {
            my ($ow) = grep { $_->{_wayfile} eq $file } @$ws;
            
            if ($ow) {
                $ow->load(); # and the top level hashkeys will not go away without restart
                push @$ldw, $ow;
                say "$self->{id} +$self->{load_ways_count}+ ".
                ($ow->{K}||$ow->{name}||$ow->{id}||"?").": $file";
                
            }
            else {
                my $nw = $self->nw;
                push @$ldw, $nw;
                $nw->name($name);
                $nw->load($file);
                say "G + ".($nw->{K}||$nw->{name}||$nw->{id}||"?").": $file";
                push @$ws, $nw;
                push @$wfs, $file;
            }
        }
        
        if (@files) {
            $H->watch_ghost_way($self, $name, \@files);
        }
        else {
            $H->error("No way! $name");
        }
    }
    
    $self->_0('_load_ways_post', {w=>$ldw, %$p});
}
our$doneprotolwptimes=[];
sub _0 {
    my $G = shift;
    my ($point, @etc) = @_;
    return $G->w("load_ways_post")
        if !$G0 && $point eq "_load_ways_post";
    if ($point =~ /^0->(.+)$/) {
        my $Usub = $1;
        $G0->{U}->{$Usub} || confess "no 0U $Usub\n".wdump(2,$G0);
        $G0->{U}->{$Usub}->($G, @etc);
    }
    else {
        my $ar = shift @etc;
        $ar->{S} = $G;
        $G0->w($point, $ar);
    }
}
sub nw {
    my $self = shift;
    my $w = new Way($H->intro, $self);
    $w->from({@_}) if @_;
    $w
}
sub crank {
    my $self = shift;
    my $dial = shift;
    #die "no $dial on $self->{name}" unless exists $self->{$dial};
    my $original = $self->{$dial};
    my $uncrank = sub { $self->{$dial} = $original };
    $self->{$dial} = shift;
    return $uncrank;
}
sub way_was {
    my $G = shift;
    my $what = shift;
    my $lt = $F[0]->{thing};
    $lt->[0] eq "D" && $lt->[1] eq $what
}
sub haunt { # arrives through here
    my $G = shift;
    return $G->_0("0->haunt", @_);
}
sub chains {
    my $G = shift;
    return @{$G->{chains}} if $G->{chains};
    grep { !$_->{_disabled} }
    map { @{$_->{chains}||[]} } $G->ways
}
sub allchains {
    my $self = shift;
    map { @{$_->{chains}||[]} } $self->ways
}
sub unrush {
    my $self = shift;
    my $point = shift;
    unless ($self->{_unrush}->{$point}) {
        $self->timer(0.2, sub {
            $self->{_unrush}->{$point} = 2;
            $self->w($point);
        }, "unrush $point");
        $self->{_unrush}->{$point} = 1
    }
    $self->{_unrush}->{$point} == 2
    
    && delete $self->{_unrush}->{$point}
}
sub tractors {
    my $self = shift;
    grep { !$_->{_disabled} }
    map { @{$_->{tractors}||[]} } $self->ways
}
sub A {
    my $G = shift;
    my @AA = $G->tractors;
    for my $K (@_) {
        @AA = grep { $_->{K} eq $K }  @AA
    }
    wantarray ? @AA : shift @AA;
}
sub ways {
    my $self = shift;
    
    grep { !$_->{_disabled} } @{$self->{ways}}
}
sub styles {
    my ($G, $styles) = @_;
    
    my @styles;
    for my $style (split ' ', $styles) {
        push @styles,
            join "", map { /;$/ ? $_ : "$_;" } $G->w("styles/$style");
    }
    join ' ', @styles;
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
    map { $_->find($point, 1) } $G->ways
}
sub throwlog {
    my $what = shift;
    $H->{G}->w(throwlog => {what => $what, thing => [@_]});
}
sub susgdb {
    my $G = shift;
    my $t = $Ghost::db;
    push @{$F[0]->{_after_do}}, sub { $Ghost::db = $t };
    $Ghost::db = -2;
}
sub w {
    my $G = shift;
    my $point = shift;
    my $ar = shift;
    my $Sway = shift;
    my @ways;
    
    my $talk = "w $point";
    
    if ($Sway) {
        $talk .= " S";
        if (ref $Sway eq 'Ghost') {
            @ways = $Sway->ways;
            $talk .= " G";
        }
        elsif (ref $Sway eq 'Way') {
            @ways = $Sway->{ofways} ? @{$Sway->{ofways}} : $Sway; #---------------------
        }
        elsif (ref $Sway eq 'ARRAY') {
            die "NO MORE ARRAY WAYS --- $point ".ki($ar)."\n"."$Sway - ".ki($Sway);
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
        next unless $h;
        my $u = $G->waystacken(Z => "$talk", $G, $w, $Sway, bless {h=>$h}, 'h'); 
        my ($Z) = @F;
        my $r;
        
        eval { $r = [ $G->doo($h, $ar, $point, $Sway, $w, $Z) ] };
        
        push @returns, $r;
        my $ZZ = $u->();
        die "MISM" unless $Z eq $ZZ;
        $Z->{Returns} = $r;
           
        if ($@) {
            my $ne = "Z\n";
            $ne .= "S: ".ki($Sway)."\n" if $Sway;
            $ne .= "$@";
            $@ = $ne;
            $G->Flab("Z Error $@");
            die $@;
        }
    }
    unless (@returns) {
        $G->Flab("way miss $talk", \@ways, $Sway);
    }
    return say "Multiple returns from ".($point||'some?where')
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
our %D_cache;
sub doo {
    my $G = shift;
    my $babble = shift;
    my $ar = shift || {};
    my $point = shift;
    my $Sway = shift;
    my $w = shift;
    my $Z = shift;
    die "RECURSION ".@F if @F > $MAX_FCURSION;
    
    my $ksmush = join",",sort keys %$ar;
    my $uuname = "$G->{id} ".Hostinfo::sha1_hex($babble)
        ." ".($point||"")." arar=".$ksmush;
        
    my $ha = Hostinfo::sha1_hex($uuname);
    die unless length($ha) == 40;
    
    $G->Flab(join("   ", '☺', ($point ? "w $point" : "⊖ $babble"), "$ksmush"));
    
    my $Ds = $D_cache{$ha};
    unless ($Ds) {
        my $eval = $G->parse_babble($babble, $point);
        my $download = $ar?join("", map { 'my$'.$_.'=$ar->{'.$_."}; " } keys %$ar):"";
        $download .= 'my $thing = $G->{t}; ' unless $ar->{thing};
        $download .= 'my $O = $G->T->{O}; ' unless $ar->{O};
        my $upload = $ar?join("", map { '$ar->{'.$_.'}=$'.$_."; "    } keys %$ar):"";
        
        my @warnings = ("no warnings 'experimental';");
    
        my $sub = "bollox";
        
        my $evs = '$sub = sub { my $ar = shift; '.
                                "@warnings $download\n".
                                
            "my \@doo_return = (sub { \n\n$eval\n })->();\n"
            
                                ."$upload"
        .'return @doo_return };';
        
        eval $evs;
        
        $Ds = [ $evs, $sub ];
        if (!$@ && ref $sub eq "CODE") {
            $D_cache{$ha} = $Ds;
        }
    };
    my ($evs, $sub) = @$Ds;
        
    my $back = $G->waystacken(D => $point, $G, $ar, $Sway, $w);
    
    my $komptalk = $@ ? "nicht kompilieren! nicht kompilieren!\n" : "";
    
    my $sigstacken = sub {
        local $@;
        eval { confess( '' ) };
        my @stack = split m/\n/, $@;
        shift @stack for 1..6; # Cover our tracks.
        my @stackend;
        push @stackend, shift @stack until $stack[0] =~ /Ghost::doo/ || !@stack && die;
        s/\t//g for @stackend;
        push @{$F[0]->{SigDieStack}||=[]}, \@stackend;
    };
    
    my @return;
    if (ref $sub eq "CODE" && !$@) {
        local $SIG{__DIE__} = $sigstacken;
        eval { @return = $sub->($ar) }
    }
    
    my $D = $back->();
    $D->{Returns} = [@return];
    
    if ($@) { #c     DOO DOO
        my ($x) = $@ =~ /line (\d+)/;
        $x = $1 if $@ =~ /syntax error .+ line (\d+), near/;
        my $file = $1 if $@ =~ /at (\S+) line/;
        undef $file if $file && $file =~ /\(eval \d+\)/;
        undef $file if $file && !-f $file;
        my $perl = $H->slurp($file) if $file;
        $perl ||= $evs;
        
        my $eval = "";
        $eval .= "$file\n" if $file;
        my @eval = split "\n", $perl;
        my $xx = 0;
        $x -= 3 if $x;
        shift @eval for 1..3;
        pop @eval for 1..3;
        my $whole = @eval < 20;
        for (@eval) {
            $xx++;
            
                if (!defined $x) {
                    $eval .= ind("⊘  ", $_)."\n"
                }
                elsif ($xx == $x) {
                    $eval .= ind("⊘  ", $_)."\n";
                    my $bab = (split"\n",$babble)[$x -1];
                    if (!$file && $bab ne $_) {
                        $eval .= ind("⊖r ", $bab)."\n";
                    }
                }
                elsif (!$whole && $xx > $x-5 && $xx < $x+5) {
                    $eval .= ind("|  ", $_)."\n"
                }
                elsif ($whole) {
                    $eval .= ind("|  ", $_)."\n"
                }
        }
        my $DOOF; 
        my $first = 1 unless $@ =~ /DOOF/;
        
        $DOOF .= "DOOF  $G->{name}   ".($ar->{S} ? "S=".gpty($ar->{S}) :"");
        $DOOF .= " \t w $point  ".join(", ", keys %$ar)."\n";;
        if ($first) {
            if (exists $D->{SigDieStack}) {
                die if @{$D->{SigDieStack}} > 1;
                $DOOF .= "\n";
                my $i = "  ";
                for my $s ( reverse flatline($D->{SigDieStack}) ) {
                    $DOOF .= "$i↘ $s\n";
                    $i .= "  ";
                }
            }        
            $DOOF .= "\n$eval\n";
        }
        $DOOF .= ind("E    ", "\n$komptalk$@\n\n")."\n\n"     if $first;
        $DOOF .= ind("E   ", "$@")."\n"             if !$first;
        $DOOF .= ind("ar  ",wdump(1,$ar))             if $first;
        $DOOF .= dooftip()                         if $first;
        
        my $OOF = $G->Flab("D Error $@", $DOOF, $D);
        if ($first) {
            #$H->error($OOF);
        }
        $D->{Error} = $DOOF;
        $@ = $DOOF;
        die "$@";
    }
    
    return wantarray ? @return : shift @return;
}
sub enc { encode_entities(shift) }
sub ind { "$_[0]".join "\n$_[0]", split "\n", $_[1] }
sub dooftip {<<"";
     .-'''-.     
   '   _    \   
 /   /` '.   \  
.   |     \  '  
|   '      |  ' 
\    \     / /  
 `.   ` ..' /   
    '-...-'`    

}
sub parse_babble {
    my $self = shift;
    my $eval = shift;
    
    my $num = qr/(?:(\d+(?:\.\d+)?) )/;
    $eval =~ s/timer $num? \{(.+?)\}/\$G->timer($1, sub { $3 })/sg;
    $eval =~ s/waylay $num?(\w.+?);/\$G->timer("$1",sub { w $2; },"waylay $2");/sg;
    
    my $ulooks = 'U->';
    $eval =~ s/$ulooks(\w+)\(/\$G->U("$1", /sg;
    $eval =~ s/(0->\w+)\(/\$G->_0("$1", /sg;
    
    $eval =~ s/(?:(?<=\W)|^)([A-Za-z_]{1,4})((?:\.\w+)+)/"\$$1".join"",map {"->{$_}"} grep {length} split '\.', $2;/seg;
    
    $eval =~ s/Sw (?=\w+)/w \$S /sg;
    $eval =~ s/G TT /\$H->TT(\$G, \$O) /sg;
    $eval =~ s/Gf? ((?!Tw)\w+)(?=[ ;,])/\$G->Gf('$1')/sg;
    $eval =~ s/G\((\w+)\)/\$G->Gf('$1')/sg;
    $eval =~ s/Gf (\S+)/\$G->Gf('$1')/sg;
    $eval =~ s/(Say|Info|Err) (([^;](?! if ))+)/\$H->$1($2)/sg;
    $eval =~ s/T ((?!->)\S+)([ ;\)])/->T($1)$2/sg;
    $eval =~ s/T (?=->)/->T() /sg;
    
    
    while ($eval =~ /(A(\w+)?\[(.+?)\])/sg) {
        my ($old, $wp, $spec) = ($1, $2, $3);        
        $wp ||= "arr";
        $wp = "'$wp'";
        my ($round) = $spec =~ /^\((.+)\)$/;
        undef $spec if $round;
        my $are = $self->parse_babblar($round, $spec);
        
        my $tw = join ", ", 
            map { $_ || 'undef' }
            ("\$G->Gf('tractor')", $wp, $are, undef);

        $eval =~ s/\Q$old\E/\$G->Tw($tw)/
            || die "Ca't replace $1\n"
            ." in\n".ind("E ", $eval);
    }
    
    # $t->{G} Tw() splatgoes ();
    my $GG_Gf = qr/\$\S+(?:\(.+?\))?/;
    my $AR = qr/(?:\[(.+?)\]|(?:\((.+?)\)))/;
    while ($eval =~ /(($GG_Gf) Tw (\w+)$AR?(?: \((.*?)\))?(?=[ ;\)]))/g) {
        my ($old, $GG, $wp, $sqar, $war, $thing) = ($1, $2, $3, $4, $5, $6);
        
        $wp ||= "arr";
        $wp = "'$wp'";
        $war = $self->parse_babblar($war, $sqar);
        
        my $tw = join ", ", 
            map { $_ || 'undef' }
            ($GG, $wp, $war, $thing);
        
        $eval =~ s/\Q$old\E/\$G->Tw($tw)/
            || die "Ca't replace $1\n"
            ." in\n".ind("E ", $eval);
    }
     
    while ($eval =~ /(?<!\$)(w (\$\S+ )?([\w\/]+)$AR?)/sg) {
        my ($old, $gw, $path, $square, $are) = ($1, $2, $3, $4, $5);
        $gw = $gw ? ", $gw" : "";# way (chain) (motionless subway)
        $gw =~ s/ $//;
        $are = $self->parse_babblar($are, $square);
        $H->snooze(0.1);
        $eval =~ s/\Q$old\E/\$G->w("$path", $are$gw)/
            || die "Ca't replace $1\n"
            ." in\n".ind("E ", $eval);
    }
    $eval;
}
sub parse_babblar {
    my $self = shift;
    my $are = shift;
    my $square = shift;
    my $ape;
    if (!$are && $square) {
        $square =~ s/^\[|\]$//sg;
        $ape = $square =~ s/^\+//;
        $are = join ", ", map { (/\$(\w+)/)[0]." => $_" } split /, /, $square;
    }
    if ($ape || $are && $are =~ s/^\+ //) {
        $are =~ s/\)$//;
        $are = '{ %$ar, '.$are.'}';
    }
    elsif ($are) {
        $are = "{ $are }";
    }
    else {
        $are = '{ %$ar }';
    }
    return $are;
}
    
sub grep_chains {
    my $self = shift;
    my %s = @_;
    my @go;
    for my $c ($self->chains) {
        while (my ($k, $v) = each %s) {
            if ((!$k || exists $c->{$k}) && (!$v || $c->{$k} =~ $v)) {
                push @go, $c;
            }
        }
    }
    return @go;
}
sub event {
    my $self = shift;
    my $event = shift;
    #blah
}

1;

