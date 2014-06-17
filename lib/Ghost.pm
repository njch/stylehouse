package Ghost;
use Mojo::Base 'Mojolicious::Controller';
use Scriptalicious;
use File::Slurp;
use JSON::XS;
use YAML::Syck;
use HTML::Entities;
use Way;
sub ddump { Hostinfo::ddump(@_) }

has 'hostinfo';
sub new {
    my $self = bless {}, shift;
    shift->($self);

    my $travel = shift;
    $self->{travel} = $travel;
    my $name = $self->{name} = $travel->{name};
    say "Ghost named $name";

    my @wayns = ("Travel", $name);
    push @wayns, $1 if $name =~ /^(\w+)-.+/;
    $self->load_ways(@wayns);

    $self->{wormhole} = new Wormhole($self->hostinfo->intro, $self, "wormholes/$name/0");

    return $self;
}
sub load_ways {
    my $self = shift;
    my @wayns = @_;
    my $ows = $self->{ways} ||= [];
    
    for my $name (@wayns) {
        unless (-d "ghosts/$name") {
            say "Ghost ? $name"; # might be gone since last load, this all very additive
            next;
        }
        
        for my $file (glob "ghosts/$name/*") {
        
            my ($ow) = grep { $_->{file} eq $file } @$ows;
            
            if ($ow) {
                $ow->load_wayfile(); # and the top level hashkeys will not go away without restart
                say "Ghost U $ow->{id}: $file";

            }
            else {
                $ow = new Way($self->hostinfo->intro, $name, $file);
                
                say "Ghost + $ow->{id}: $file";
                push $ows, $ow;
            }
        }
        
        $self->{hostinfo}->watch_ghost_way($self, $name);
    }
    
    $self->hookways("load_ways_post");
}
sub ob {
    my $self = shift;
    $self->{travel}->ob(@_);
}
sub colorf {
    my $fing = shift;
    my ($l,$r,$b) = @_;
    my ($color) = ($fing || "0") =~ /\(0x....(...)/;
    $color ||= $fing if $fing && ref \$fing eq "SCALAR" && $fing =~ /^(\x{3}|\x{6})$/;
    $color ||= "663300";
    $l ||= 0;
    $r ||= 0;
    $b ||= 3;
    return "text-shadow: ${l}px ${r}px ${b}px #$color;";
}
sub chains {
    my $self = shift;
    map { $_->{chains} ? @{ $_->{chains} } : () } @{ $self->{ways} }
}
sub hookways {
    my $self = shift;
    my $point = shift;
    my $ar = shift;
    my $wayspec = shift;

    # these might want to be a wormhole that travel mixes in
    # things gather along the spines
    # and be the big thing to do or a little thing to do
    # these stuff go together like that, hopefully, with language forming their surface tension
    # jelly pyramids...
    my @returns;
    for my $w (@{ $self->{ways} }) {
        next if $wayspec && $w ne $wayspec;
        if (exists $w->{hooks}->{$point}) {
            push @returns, [
                $self->doo($w->{hooks}->{$point}, $ar, $point)
            ];
        }
    }
    return say "Multiple returns from ".($point||'some?where')
                            if @returns > 1;    
    return say " NO REty ".($point||'some?where')
                            if @returns < 1;
    my @return = @{$returns[0]};
    if (wantarray) {
        say "Returning ".($point||'somewhere').": @return";
        return @return
    }
    else {
        my $one = shift @return;
        say "Returning ".($point||'somewhere').": ".($one||"~");
        return $one;
    }
}
sub wdump { shift->hookways('wdump', { in => shift }) }
sub doo {
    my $G = shift;
    my $eval = shift;
    my $ar = shift;
    my $point = shift;
    
    while ($eval =~ /(W (\$\w+ )?(\w+)\((.*?)\))/sg) {
        my ($old, $ghost, $way, $are) = ($1, $2, $3, $4);
        $ghost ||= '$G';
        $eval =~ s/\Q$old\E/$ghost->hookways("$way", $are)/
            || die "Ca't replace $1\n"
            ." in\n".ind("E ", $eval);
    }
    
    my $thing = $G->{thing};
    my $O = $G->{travel}->{owner};
    my $H = $G->{hostinfo};
    
    my $download = join "", map { 'my $'.$_.' = $ar->{'.$_."};\n  " } keys %$ar if $ar;
    my $upload = join "", map { '$ar->{'.$_.'} = $'.$_.";\n  " } keys %$ar if $ar;
    
    my @return;
    my $evs = ($download||'')
        .' @return = (sub { '.$eval.' })->(); '
        .($upload||'');
    eval $evs;
    if ($@) {
        die "DOO Fuckup:\n"
            .(defined $point ? "point: $point\n" : "")
            ."args: ".join(", ", keys %$ar)."\n"
            .($@ !~ /DOO Fuckup/ ? ind("c  ", $eval) : "|")."\n"
            .ind("|   ", $@)."\n^\n";
    }
    # more ^
    
    return wantarray ? @return : shift @return;
}
sub enc { encode_entities(shift) }
sub ind { "$_[0]".join "\n$_[0]", split "\n", $_[1] }
sub haunt { # arrives through here
    my $self = shift;
    $self->{depth} = shift;
    $self->{thing} = shift;
    $self->{wayin} = shift;
    $self->{last_state} = shift;

    $self->ob($self);
    
    $self->{wayout} = [];
    $self->hookways("arr");

    $self->ob($self);

    $self->{away} = []; # of {} args to Travel
    $self->hookways("umm");

    $self->ob($self);

    my $state = $self->{wormhole}->continues($self); # %

    $self->ob($self);

    $self->hookways("and");

    $self->ob($self);

    return ($state, $self->{away});
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

