package Ghost;
use Mojo::Base 'Mojolicious::Controller';
use Scriptalicious;
use File::Slurp;
use JSON::XS;
use YAML::Syck;
use Texty;
use Wormhole;

has 'hostinfo';

sub new {
    my $self = bless {}, shift;
    shift->($self);

    $self->{travel} = shift;

    $self->hostinfo->loadghost($self); # ways & wormhole

    
    # Way also something big to join up to
    # it looks like the fuzz of how you want to act while Traveling. yay.
    # which is just the place to join to liquified language
    # there may be more structure through/around a list of lingos we hard code for now
    # it's a tube with no phases yet, just "select ways" and misc chewing

    # we eat all the ways and fire their hooks through our flow
    # so expression can be ordered more by theme, not scattered over variation
    # anyway this gets stored somehow and edited in codemirror, via Codo?
#    push @{ $self->{ways} ||= [] },
    my $i = 0; # we write the next cell of Ghost into 0 until it merges spiritually
        map { $i++; write_file("ghosts/Ghost/$i", $_); } <<'YAML',
name: ghost
hooks:
  donetravels: |
    for my $c ($self->chains) {
        $self->hookways("donetravels_chain", {c => $c});
    }
  maketravels: |
    for my $c (@{$self->{wayout}}) {
        $self->hookways("maketravels_chain", {c => $c});
    }
    $self->hookways("maketravels_post");
YAML
<<'YAML',
name: ghost refs
hooks:
  donetravels_chain: |
    if ($c->{ref}) {
        if ($c->{ref} eq ref $thing) {
            if ($c->{as}) {
                my @really = $self->grep_chains("ref" => $c->{as});
                die "cannot find ref=$c->{as}".ddump(@really) if @really != 1;
                my $new_c = shift @really;
                $c = { %$new_c, as_from => $c };
            }
            push @{$self->{wayout}}, $c;
        }
    }
  maketravels_chain: |
    if ($c->{for}) {
        my $i = 0;
        for my $for (@{ $self->doo($c->{for}) }) {
            if (my $t = $c->{travel}) {
                push @{$self->{away}}, {
                    travel => {
                        thing => $self->doo($t, {for => $for}),
                        way => { %$c, i => $i++, value => $for }
                    }
                };
            }
        }
    }
  chain_to_tuxts: |
    my $line = $s->{value};
    $ar->{line} = $line;
    $self->{tuxts} = [];
    $s->{left} += $line->{depth} * 40;
    
    $self->hookways("tuxt_way_in", $ar);
    $self->hookways("tuxt_ways_out", $ar);
    $self->hookways("tuxt_etc", $ar);
    $self->hookways("tuxt_this", $ar);
    
    $_->{value} =~ s/\n/<br>/ for @{ $self->{tuxts} };
  tuxt_way_in: |
    my $wins = { %$s };
    $wins->{id} .= "-wayin";
    my $wi = $line->{wayin};
    $wins->{value} = "(nowhere)";
    $wins->{value} = encode_entities(getway($wi)) if $wi;
    $wins->{style} .= colorf(!$wi ? $wi : $wi->{way});
    $wins->{top} -= 10;
    $wins->{style} .= "font-size: 5pt; opacity:0.4;";
    push @{$self->{tuxts}}, $wins;
  tuxt_ways_out: |
    my $wous = { %$s };
    $wous->{id} .= "-waysout";
    my $wo = $line->{wayout} || [];
    my @ways;
    for my $chain (@$wo) {
        my $argc = { %$ar, waydisplay => undef, chain => $chain };
        $self->hookways("tuxt_chain", $argc);
        push @ways, $argc->{waydisplay};
        die "doo() upload didn't work" unless $argc->{waydisplay};
    }
    $eg ||= "(no futher)";
    $wous->{value} = "$sum $eg";
    $wous->{style} .= colorf($wo);
    $wous->{top} += 10;
    $wous->{style} .= "font-size: 5pt; opacity:0.4;";
    push @{$self->{tuxts}}, $wous;
  tuxt_chain: |
    my $junk = join "\n", map { "$_: $way->{$_}" } keys %$chain;
    $junk .= "\n as_from:\n".join "\n", map { "$_: $way->{$_}" } keys %{$way->as_from} if $way->{;
    $waydisplay = encode_entities(getway($chain));
  tuxt_etc: |
    my $etcs = { %$s };
    $etcs->{id} .= "-etcs";
    $etcs->{value} = encode_entities(anydump($line->{etc}));
    $etcs->{value} =~ s/\$x = {};//;
    $etcs->{style} .= colorf($line->{etc});
    $etcs->{style} .= "font-color: #434; font-size: 5pt; opacity:0.4;";
    $etcs->{top} += 20;
    delete $etcs->{left};
    $etcs->{right} = 5;
    push @{$self->{tuxts}}, $etcs;
  tuxt_this: |
    my $this = { %$s };
    $this->{id} .= "-this";
    $this->{value} = encode_entities($line->{thing});
    $this->{style} .= "font-color: #bb3564; font-size: 15pt; ".colorf($line->{thing})." opacity:0.4; padding: 0.9em; ";
    $this->{style} .= "border: 2px dotted red;" if ref $line->{thing};
    $this->{top} -= 30;
    $this->{left} += 50;
    push @{$self->{tuxts}}, $this;
chains:
 - ref: HASH
   for: ' [ sort keys %$thing ] '
   travel: ' $thing->{$for} '
 - ref: ARRAY
   for: ' [ @$thing ] '
   travel: ' $for '
 - as: HASH
   note: ' { owner => $thing->view->owner } '
   ref: Texty
YAML
# {{{
<<'YAML',
name: ghost notes
hooks:
  donethinking: |
    for my $c (@{$self->{out}}) {
        if ($c->{note}) {
            push @{ $self->{etc}->{note}||=[] }, $self->doo($c->{note});
        }
    }
YAML
<<'YAML',
name: ghost default
hooks:
  maketravels_post: |
    if (!@{$self->{away}}) {
        for my $dc (grep { $_->{default} } $self->chains) {
            if (!$dc->{unless} || !$self->doo($dc->{unless})) {
                push @{$self->{away}}, { travel => { thing => $self->doo($dc->{default}), way => { %$dc } } };
            }
        }
    }
chains:
 - default: " \"? '$thing' \""
   unless: ' ref \$thing eq "SCALAR" '
YAML
    ;

    for my $w (@{$self->{ways}}) {
        for my $c (@{$w->{chains}}) {
            $c->{way} ||= $w;
        }
    }

    return $self;
}
# }}}

sub colorf {
    my $fing = shift;
    my ($color) = ($fing || "0") =~ /\(0x....(...)/;
    return "border: 1px solid black;" unless $color;
    $color ||= "fff";
    return "background-color: #".($color || "fe9").";";
}
sub chains {
    my $self = shift;
    map { @{ $_->{chains} } } @{ $self->{ways} }
}

sub hookways {
    my $self = shift;
    my $point = shift;
    my $ar = shift;
    my $wayspec = shift;
    # these might want to be ordered
    # so things can gather at points of the program workflow like "maketravels"
    # and be the big thing to do or a little thing to do
    # these stuff go together like that, hopefully, with language forming their surface tension
    for my $w (@{ $self->{ways} }) {
        next if $wayspec && $w ne $wayspec;
        if (exists $w->{hooks}->{$point}) {
            $self->doo($w->{hooks}->{$point}, $ar);
        }
    }
}

sub doo {
    my $self = shift;
    my $eval = shift;
    my $ar = shift;
    my $thing = $self->{thing};
    my $download = map { 'my $'.$_.' = $ar->{'.$_."};\n  " } keys %$ar;
    my $upload = map { '$ar->{'.$_.'} = $'.$_.";\n  " } keys %$ar;
    
    my $for = $ar->{for};
    my $c = $ar->{c};

    my @return;
    my $evs = "$download \@return = (sub { $eval })->();  $upload";
    eval $evs;
    die anydump({dooing => [$@, $eval]}) if $@;

    return wantarray ? @return : $return[0]
}

sub haunt {
    my $self = shift;
    $self->{depth} = shift;
    $self->{thing} = shift;
    $self->{wayin} = shift;
    $self->{last_state} = shift;

    $self->{wayout} = [];
    $self->hookways("donetravels");
    $self->{away} = []; # of {} args to Travel
    $self->hookways("donethinking");

    my $state = $self->{wormhole}->continues($self); # %

    $self->hookways("maketravels");
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
