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

    return $self;
}
sub T {
    my $self = shift;
    $self->{T}->travel($_) for @_;
    $self->{T};
}
sub W {
    my $self = shift;
    $self->{W} ||= Wormhole->new($H->intro, $self, "wormholes/$self->{name}/0");
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
            push @files, glob "$base/*";
        }
        
        for my $file (@files) {
            my ($ow) = grep { $_->{_wayfile} eq $file } @$ws;
            
            if ($ow) {
                $ow->load_wayfile(); # and the top level hashkeys will not go away without restart
                say "G ++ ".($ow->{K}||$ow->{name}||$ow->{id}||"?").": $file";
                
            }
            else {
                my $nw = new Way($H->intro, $name, $file);
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
sub ob {
    my $self = shift;
    $self->{T}->ob(@_);
}
sub chains {
    my $self = shift;
    grep { !$_->{_disabled} }
    map { @{$_->{chains}||[]} } $self->ways
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
        }
        elsif (ref $way eq 'Way') {
            @ways = $way;
        }
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
    my $eval = shift;
    my $ar = shift || {};
    my $point = shift;
    
    $eval = $G->parse_babble($eval);
    
    my $thing = $G->{t};
    my $O = $G->{travel}->{O};
    say "$G->{name}: ".($point||$eval);
    
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
        my $eval = "";
        my @eval = split "\n", $evs;
        my $xx = 1;
        for (@eval) {
                if (defined $x && $xx == $x) {
                    $eval .= ind("Ͱ->", $_)."\n"
                }
                else {
                    $eval .= ind("|  ", $_)."\n"
                }
            $xx++;
        }
        return say "DOO $point: $@\n$eval" unless $@;
        
        say <<"" if $@ !~ /^DONT/;
     .-'''-.     
   '   _    \   
 /   /` '.   \  
.   |     \  '  
|   '      |  ' 
\    \     / /  
 `.   ` ..' /   
    '-...-'`    

        die "DONT $point  ".join(", ", keys %$ar)."\n"
            .($@ !~ /^DONT/ ? "$eval\n" : "")
            .ind("E   ", $@)."\n^\n";
    }
    # more ^
    
    return wantarray ? @return : shift @return;
}
sub enc { encode_entities(shift) }
sub ind { "$_[0]".join "\n$_[0]", split "\n", $_[1] }
sub parse_babble {
    my $self = shift;
    my $eval = shift;
    
    $eval =~ s/timer (\d+(\.\d+)?) \{(.+)\}/\$H->timer(0.1, sub { $1 })/sg;
    $eval =~ s/G TT /\$H->TT(\$G, \$O) /sg;
    $eval =~ s/G (\w+) /\$H->Gf(\$G, '$1') /sg;
    $eval =~ s/T (\S+)([ ;\)])/->T($1)$2/sg;

    while ($eval =~ /(w (\$\S+ )?([\w\/]+)(:?\((.+?)\))?)/sg) {
        my ($old, $gw, $path, $are) = ($1, $2, $3, $4);
        $gw = ", $gw" if $gw; # ghost or way
        $gw ||= "";
        $gw =~ s/ $//;
        if ($are && $are =~ s/^\(\+ //) {
            $are =~ s/\)$//;
            $are = '{ %$ar, '.$are.'}';
        }
        elsif ($are) {
            $are = "{ $are }";
        }
        else {
            $are = '{ %$ar }';
        }
        $eval =~ s/\Q$old\E/\$G->w("$path", $are$gw)/
            || die "Ca't replace $1\n"
            ." in\n".ind("E ", $eval);
    }
    $eval;
}
sub haunt { # arrives through here
    my $self = shift;
    $self->{depth} = shift;
    $self->{t} = shift; # thing
    $self->{i} = shift; # way[] in
    $self->{last_state} = shift;
    $self->{o} = []; # way[] out
    
    $self->ob($self);
    $self->w("arr");
    $self->ob($self);
    
    my $line = $self->W->continues($self); # %
    $self->ob($line);

    return ($line, $self->{o});
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

