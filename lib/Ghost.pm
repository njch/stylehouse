package Ghost;
use Mojo::Base 'Mojolicious::Controller';
use Scriptalicious;
use File::Slurp;
use JSON::XS;
use YAML::Syck;
use HTML::Entities;
use Way;
sub ddump { Hostinfo::ddump(@_) }
sub wdump { Hostinfo::wdump(@_) }

our $H;
our @F;
our @Flab;
our $G0;
our $L;
sub gname {
    my $g = shift;
    my $si = shift || 0;
    my $ish = ref $g;
    $ish = "" if $ish ne "Ghost";
    $ish = "" if $ish eq "Ghost";
    $ish = ref $g && ($g->{name} || $g->{id}) || "$g";
    
    
    $ish =~ s/^(\w+)=HASH.*$/$1\{/;
    $ish;
}
sub Flab {
    my $self = shift;
    ref $self eq "Ghost" || die "send Ghost";
    say $_[0] if $self->{db};
    push @Flab, Hostinfo->enlogform(@_);
}
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
    $name = "$name`s ($way)";
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
sub idname {
    my $self = shift;
    $self->{id}."-".$self->{name}
}
sub T {
    my $self = shift;
    $self->T->T(@_) if @_;
    $self->{T};
}
sub Tw {
    my $self = shift;    
    my ($GG, $wp, $war, $thing) = @_;
    $GG || die "NO Tw GG!";
    
    my $w = $self->nw();
    $w->{arr_hook} = $wp if $wp;
    $w->{arr_ar} = $war if $war;
    $w->{thing} = $thing if $thing;
    $w->{print} = '"$G->{way} Tw ".($thing||"")." $S->{arr_hook}"';
    # travel to a wp in another ghost
    # we see this somewhere
    # so we can interfere case left
    
    # here (but not constructed here) is where ways may pool
    #   for more thinking before travelling
    #   parallel, streaming...
    
    my @r = $GG->T->T($thing, undef, $w);
    return wantarray ? @r : $r[0];
}
sub Gf {
    my $self = shift;    
    my $way = shift;

    # TODO
    my @Gs =
        grep { $_->{way} =~ /$way/ } @{ $self->{GG} };
    
    #die "Gf = ".scalar(@Gs)." $self->{name}   $way " if @Gs != 1;
    
    shift @Gs;
}
sub W {
    my $self = shift;
    $self->{T}->{W} ||= Wormhole->new($H->intro, $self, "wormholes/$self->{name}/0");
}
sub RW {
    my $self = shift;
    my $OW = $self->W->{script};
    $self->W->{script} = [];
    $OW;
}
sub load_ways {
    my $self = shift;
    my @ways = @_;
    my $ws = $self->{ways} ||= [];
    my $wfs = $self->{wayfiles} ||= [];
    $self->{load_ways_count}++;
    
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
                say "$self->{id} +$self->{load_ways_count}+ ".($ow->{K}||$ow->{name}||$ow->{id}||"?").": $file";
                
            }
            else {
                my $nw = $self->nw;
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
    
    $self->_0('_load_ways_post');
}
sub _0 {
    my $G = shift;
    my ($point, $ar) = @_;
    unless ($G0) { # proto $G0 creation
        $G->w("load_ways_post") if $point eq "_load_ways_post";
        return;
    }
    $ar->{S} = $G;
    $G0->w($point, $ar);
}
sub nw {
    my $self = shift;
    new Way($H->intro, $self);
}
sub crank {
    my $self = shift;
    my $dial = shift;
    die "no $dial on $self->{name}" unless exists $self->{$dial};
    my $original = $self->{$dial};
    my $uncrank = sub { $self->{$dial} = $original };
    $self->{$dial} = shift;
    return $uncrank;
}
sub ob {
    my $self = shift;
    $self->{T}->ob(@_);
}
sub haunt { # arrives through here
    my $self = shift;
    my $T = shift; # A
    $self->{depth} = shift;
    $self->{t} = shift; # thing
    my $i = $self->{i} = shift; # way in
    my $o = $self->{o} = []; # way[] out
    
    $self->ob($self, T => $T);
    
    if ($i->{arr_hook}) { # could be moved into a crawl-like chain
        say " Tarr hook: $i->{arr_hook}: ".join" ",%{$i->{arr_ar}};
        my @r = $self->w($i->{arr_hook}, $i->{arr_ar});
        push @$o, $i->spawn()->from({ arr_returns => \@r });
        
    }
    else {
        $self->w("arr");
    }
    
    $self->ob($self);
    
    my $line;
    if (defined $self->{t}) {
        $line = $self->W->continues($self); # %
        $self->ob($line);
    }

    return ($line, $self->{o});
}
sub chains {
    my $self = shift;
    grep { !$_->{_disabled} }
    map { @{$_->{chains}||[]} } $self->ways
}

sub unrush {
    my $self = shift;
    my $point = shift;
    unless ($self->{_unrush}->{$point}) {
        $H->timer(0.2, sub {
            $self->{_unrush}->{$point} = 2;
            $self->w($point);
        });
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
sub ways {
    my $self = shift;
    
    grep { !$_->{_disabled} } @{$self->{ways}}
}
sub waystacken {
    my $self = shift;
    my $junk = $H->enlogform(@_);
    $self->ob("to",$junk);
    push @F, $junk;
    return sub {
        my $o = pop @F;
        $o ne $junk && die "stack bats:\n".wdump([$o, \@F]);
        $self->ob("back", $junk, \@Flab);
        @Flab = ();
    }
}
sub w {
    my $G = shift;
    my $point = shift;
    my $ar = shift;
    my $Sway = shift; # so we can get into chains/tractors
    # these might want to be a wormhole that travel mixes in
    # things gather along the spines
    # and be the big thing to do or a little thing to do
    # these stuff go together like that, hopefully, with language forming their surface tension
    # jelly pyramids...
    my @ways;
    
    my $talk = "w $point";
    
    if ($Sway) {
        $talk .= " S";
        if (ref $Sway eq 'Ghost') {
            @ways = $Sway->ways;
            $talk .= " G";
            $G->ob($talk, $Sway);
        }
        elsif (ref $Sway eq 'Way') {
            @ways = $Sway;
        }
        my $b = {};
        %$b = %{$Sway->{B}} if $Sway->{B};
        $ar = {%$ar, S => $Sway, %$b};
    }
    else {
        @ways = $G->ways;
    }
    
    my @returns;
    for my $w (@ways) {
        my $h = $w->find($point);
        next unless $h;
        my $u = $G->waystacken("$talk", $h);
        push @returns, [
            $G->doo($h, $ar, $point, $Sway, $w)
        ];
        if ($@) {
            $G->ob("Error", $@);
            $u->();
            die $@;
        }
        $u->();
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
sub doo {
    my $G = shift;
    my $babble = shift;
    my $ar = shift || {};
    my $point = shift;
    my $Sway = shift;
    my $w = shift;
    
    my $eval = $G->parse_babble($babble, $point);
    
    my $thing = $G->{t};
    my $O = $G->T->{O};
    $G->ob($point||$eval);
    
    $G->Flab(" $G->{name}    \N{U+263A}     ".($point ? "w $point" : "⊖ $eval"));
    
    my $download = $ar?join("", map { 'my$'.$_.'=$ar->{'.$_."};  " } keys %$ar):"";
    my $upload =   $ar?join("", map { '$ar->{'.$_.'}=$'.$_.";  "    } keys %$ar):"";
    
    my @return;
    my $evs = "$download\n".' @return = (sub { '."\n".$eval."\n })->(); $upload";
    
        
    my $back = $G->waystacken(
        G => $G, way => $w, point => $point, ar => $ar,
        ($Sway ? (Sway => $Sway): ()), stack => $H->enlogform()
    );
    
    eval $evs;
    
    $back->();
    
    if ($@) {
        my ($x) = $@ =~ /line (\d+)\.$/;
        $x = $1 if $@ =~ /syntax error .+ line (\d+), near/;
        my $eval = "";
        my @eval = split "\n", $evs;
        my $xx = 1;
        for (@eval) {
                if (!defined $x) {
                    $eval .= ind("⊘  ", $_)."\n"
                }
                elsif ($xx == $x) {
                    $eval .= ind("⊘  ", $_)."\n";
                    $eval .= ind("⊖r ", (split"\n",$babble)[$x - 3])."\n";
                }
                elsif ($xx > $x-5 && $xx < $x+5) {
                    $eval .= ind("|  ", $_)."\n"
                }
            $xx++;
        }
        
        my $DOOF;
        if ($@ !~ /DOOF/ && $@ !~ /^Yep/) {
            $DOOF .= "\n".<<"";
     .-'''-.     
   '   _    \   
 /   /` '.   \  
.   |     \  '  
|   '      |  ' 
\    \     / /  
 `.   ` ..' /   
    '-...-'`    

            
            $DOOF .= "Flab: ". wdump(\@Flab)."\n";
        }
        $DOOF .= "DOOF $G->{name}   ".($ar->{S} ? "S=$ar->{S}":"")
            ."  w $point  ".join(", ", keys %$ar)."\n"
            .($@ !~ /DOOF/ ? "$eval\n" : "")
            .ind("E   ", $@)."\n^\n";
        
        $G->Flab("Error: $@");
        $G->Flab(DOOF => $DOOF);
        $@ = $DOOF;
        
        my @ca = caller(1);
        if ($ca[3] eq "Ghost::w") {
            return;
        }
        else {
            die $@
        }
    }
    
    return wantarray ? @return : shift @return;
}
sub enc { encode_entities(shift) }
sub ind { "$_[0]".join "\n$_[0]", split "\n", $_[1] }
sub parse_babble {
    my $self = shift;
    my $eval = shift;
    
    $eval =~ s/timer (\d+(\.\d+)?) \{(.+?)\}/\$H->timer($1, sub { $3 })/sg;
    $eval =~ s/G TT /\$H->TT(\$G, \$O) /sg;
    $eval =~ s/Gf? (\w+)(?=[ ;,])/\$G->Gf('$1')/sg;
    $eval =~ s/G\((\w+)\)/\$G->Gf('$1')/sg;
    $eval =~ s/(Say|Info|Err) (([^;](?! if ))+)/\$H->$1($2)/sg;
    $eval =~ s/T ((?!->)\S+)([ ;\)])/->T($1)$2/sg;
    $eval =~ s/T (?=->)/->T() /sg;
    
    
    while ($eval =~ /(A(\w+)?\[(.+?)\])/sg) {
        my ($old, $wp, $spec) = ($1, $2, $3);        
        $wp ||= "arr";
        $wp = "'$wp'";
        
        my $are = $self->parse_babblar(undef, $spec);
        
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
     
    while ($eval =~ /(w (\$\S+ )?([\w\/]+)$AR?)/sg) {
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

