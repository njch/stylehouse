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
sub new {
    my $self = bless {}, shift;
    shift->($self);
    delete $self->{hostinfo};

    my $travel = shift;
    $self->{T} = $travel;
    my $name = $travel->{name};
    my @ways = @_;
    unless (@ways) {
        @ways = "Elvis";
    }
    $name = "$name - ".join", ",@ways;
    $self->{name} = $name;
    say "Ghost named $name";
    $self->load_ways(@ways);

    if ($self->tractors) {
        $H->TT($self)->G("Wormhole/tractor");
    }

    return $self;
}
sub T {
    my $self = shift;
    $self->{T}->travel($_) for @_;
    $self->{T};
}
sub Tw {
    my $self = shift;    
    my ($GG, $Twar, $wp, $war, $thing) = @_;
    
    my $w = $self->nw();
    $w->{GG} = $self; # reflection of $GG
    $w->{arr_hook} = $wp if $wp;
    $w->{arr_ar} = $war if $war;
    $w->{thing} = $thing if $thing;
    # on some levels, travel_this hooks arr with thing
    # we want to impose the case left by $G straight into wp
    die $thing if $thing && $wp;
    # $thing could be passed the wp in $war
    # or it could be something else altogether... 
    # here (but not constructed here) is where ways may pool
    #   for more thinking before travelling
    
    my @r = $GG->T->travel($thing, undef, $w);
    # TODO stop passing ghost through travel
    
    die "Many returns for Tw to $GG->{name}\nway: $wp".ddump(\@r) if @r != 1;
    die "TRravel treutnrs:". Hostinfo::ddump($r[0]);
    return @{ $r[0] };
    ($GG, $Twar, $wp, $war, $thing);
}
sub W {
    my $self = shift;
    $self->{T}->{W} ||= Wormhole->new($H->intro, $self, "wormholes/$self->{name}/0");
}
sub RW {
    my $self = shift;
    $self->W->{script} = [];
}
sub load_ways {
    my $self = shift;
    my @ways = @_;
    my $ws = $self->{ways} ||= [];
    
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
                say "G ++ ".($ow->{K}||$ow->{name}||$ow->{id}||"?").": $file";
                
            }
            else {
                my $nw = $self->nw;
                $nw->name($name);
                $nw->load($file);
                say "G + ".($nw->{K}||$nw->{name}||$nw->{id}||"?").": $file";
                push @$ws, $nw;
            }
        }
        
        if (@files) {
            $H->watch_ghost_way($self, $name);
        }
        else {
            $H->error("No way! $name");
        }
    }
    
    $self->w("load_ways_post");
}
sub nw {
    my $self = shift;
    new Way($H->intro, $self);
}
sub ob {
    my $self = shift;
    $self->{T}->ob(@_);
}
sub haunt { # arrives through here
    my $self = shift;
    $self->{depth} = shift;
    $self->{t} = shift; # thing
    my $i = $self->{i} = shift; # way in
    $self->{last_state} = shift;
    my $o = $self->{o} = []; # way[] out
    
    $self->ob($self);
    
    if ($i->{arr_hook}) { # could be moved into a crawl-like chain
        my @r = $self->w($i->{arr_hook}, $i->{arr_ar});
        push @$o, $i->spawn()->from({ travel_returns => \@r });
    }
    else {
        $self->w("arr");
    }
    
    $self->ob($self);
    
    my $line = $self->W->continues($self); # %
    $self->ob($line);

    return ($line, $self->{o});
}
sub chains {
    my $self = shift;
    grep { !$_->{_disabled} }
    map { @{$_->{chains}||[]} } $self->ways
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
sub w {
    my $self = shift;
    my $point = shift;
    my $ar = shift;
    my $way = shift; # so we can get into chains
    # these might want to be a wormhole that travel mixes in
    # things gather along the spines
    # and be the big thing to do or a little thing to do
    # these stuff go together like that, hopefully, with language forming their surface tension
    # jelly pyramids...
    my @ways;
    if ($way) {
        if (ref $way eq 'Ghost') {
            @ways = $way->ways;
            die "really?";
        }
        elsif (ref $way eq 'Way') {
            @ways = $way;
        }
        $ar = {%$ar, way => $way}; # TODO should s/way/c/
    }
    else {
        @ways = $self->ways;
    }
    
    my @returns;
    for my $w (@ways) {
        my $h = $w->find($point);
        next unless $h;
        push @returns, [
            $self->doo($h, $ar, $point)
        ];
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
    
    my $eval = $G->parse_babble($babble, $point);
    
    my $thing = $G->{t};
    my $O = $G->T->{O};
    $G->ob($point||$eval);
    
    say " $G->{name}         ".($point ? "w $point" : "⊖ $eval");
    
    my $download = join "", map { 'my $'.$_.' = $ar->{'.$_."};  " } keys %$ar if $ar;
    my $upload = join "", map { '$ar->{'.$_.'} = $'.$_.";  " } keys %$ar if $ar;
    
    my @return;
    my $evs = ($download||'')
        ."\n".' @return = (sub { '
        ."\n".$eval."\n".
        ' })->(); '."\n"
        .($upload||'');
    eval $evs;
    
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
        $DOOF .= "\n".<<"" if $@ !~ /DOOF/;
     .-'''-.     
   '   _    \   
 /   /` '.   \  
.   |     \  '  
|   '      |  ' 
\    \     / /  
 `.   ` ..' /   
    '-...-'`    

        $DOOF .= "DOOF $point  ".join(", ", keys %$ar)."\n"
            .($@ !~ /DOOF/ ? "$eval\n" : "")
            .ind("E   ", $@)."\n^\n";
        
        $H->error($DOOF) if $@ !~ /^DONT/;
        
        die $DOOF;
    }
    # more ^
    
    return wantarray ? @return : shift @return;
}
sub enc { encode_entities(shift) }
sub ind { "$_[0]".join "\n$_[0]", split "\n", $_[1] }
sub parse_babble {
    my $self = shift;
    my $eval = shift;
    
    $eval =~ s/timer (\d+(\.\d+)?) \{(.+?)\}/\$H->timer($1, sub { $3 })/sg;
    $eval =~ s/G TT /\$H->TT(\$G, \$O) /sg;
    $eval =~ s/G (\w+)(?=[ ;,])/\$H->Gf(\$G,'$1')/sg;
    $eval =~ s/G\((\w+)\)/\$H->Gf(\$G,'$1')/sg;
    $eval =~ s/Say (([^;](?! if ))+)/\$H->Say($1)/sg;
    $eval =~ s/T ((?!->)\S+)([ ;\)])/->T($1)$2/sg;
    $eval =~ s/T (?=->)/->T() /sg;
    #A[$splatname, $wormhole];
    
    
    while ($eval =~ /(A\[(.+)\])/sg) {
        my ($old, $spec) = ($1, $2, $3, $4, $5);
        
        my $are = $self->parse_babblar(undef, $spec);
        
        
        $eval =~ s/\Q$old\E/G tractor Tw arr($are)/
            || die "Ca't replace $1\n"
            ." in\n".ind("E ", $eval);
    }
    
    # $t->{G} Tw() splatgoes ();
    my $GG_Gf = qr/\$\S+(?:\(.+?\))?/;
    while ($eval =~ /(($GG_Gf) Tw(?:\((.*?)\))? (\w+)(?:\((.*?)\))?(?: \((.*?)\))?(?=[ ;\)]))/g) {
        my ($old, $GG, $Twar, $wp, $war, $thing) = ($1, $2, $3, $4, $5);
        
        $wp = "'$wp'" if $wp;
        $war = $self->parse_babblar($war) if $war;
        
        my $tw = join ", ", 
            map { $_ || 'undef' }
            ($GG, $Twar, $wp, $war, $thing);
        
        $eval =~ s/\Q$old\E/\$G->Tw($tw)/
            || die "Ca't replace $1\n"
            ." in\n".ind("E ", $eval);
    }
    
    while ($eval =~ /(w (\$\S+ )?([\w\/]+)(:?\((.+?)\))?(:?\[(.+?)\])?)/sg) {
        my ($old, $gw, $path, $are, $square) = ($1, $2, $3, $4, $5);
        
        $gw = $gw ? ", $gw" : "";# way (chain) (motionless subway)
        $gw =~ s/ $//;
        $are = $self->parse_babblar($are, $square);
        
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
    if (!$are && $square) {
        $are = join ", ", map { (/^\$(\w+)/)[0]." => $_" } split /, /, $square;
    }
    if ($are && $are =~ s/^\+ //) {
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

