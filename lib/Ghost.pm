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

    $self->load_way("Travel");
    $self->load_way($name);
    if ($name =~ /^(\w+)-.+/) {
        $self->load_way($1);
    }

    $self->{wormhole} = new Wormhole($self->hostinfo->intro, $self, "wormholes/$name/0");

    return $self;
}
sub load_way {
    my $self = shift;
    my $name = shift;
    $self->{ways} ||= [];
    unless (-d "ghosts/$name") {
        say "Ghost ? $name";
        return;
    }
    for (glob "ghosts/$name/*") {
        push @{ $self->{ways} }, new Way($self->hostinfo->intro, $_);
        say "Ghost + $_";
    }
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
sub doo { # here we are in a node, facilitating the popup code that is Way
    my $self = shift;
    my $eval = shift;
    while ($eval =~ /(W (\w+)\((.+?)\))/sg) {
    	my $p = pos();
        my ($old, $way, $are) = ($1, $2, $3);
    	$eval =~ s/\Q$old\E/\$self->hookways("$way", $are)/
        	|| die "Ca't replace $1 at $p\n the: $1\t\t$2"
            ." in\n".ind("E ", $eval);
    }
    my $ar = shift;
    my $point = shift;
    my $thing = $self->{thing};
    my $download = join "", map { 'my $'.$_.' = $ar->{'.$_."};\n  " } keys %$ar;
    my $upload = join "", map { '$ar->{'.$_.'} = $'.$_.";\n  " } keys %$ar;
    
    my @return;
    my $evs = "$download ".'@return'." = (sub { $eval })->();  $upload";
    eval $evs;
    if ($@) {
        die "DOO Fuckup:\n"
            .(defined $point ? "point: $point\n" : "")
            ."args: ".join(", ", keys %$ar)."\n"
            .($@ !~ /DOO Fuckup/ ? ind("|-  ", $eval) : "|")."\n"
            .ind("|   ", $@)."\n^\n";
    }
    # more ^
    
    return @return;
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
