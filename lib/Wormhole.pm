package Wormhole;
use Scriptalicious;
use File::Slurp;
use JSON::XS;
use Term::ANSIColor;
my $json = JSON::XS->new->allow_nonref(1)->allow_unknown(1);
use HTML::Entities;
sub ddump { Hostinfo::ddump(@_) }

our $H;
sub new {
    my $self = bless {}, shift;
    shift->($self);
    delete $self->{hostinfo};
    
    $self->{G} = shift;
    $self->{name} = $self->{G}->{name};
    $self->{n} = 0;

    $self->wormfile_load(shift);

    return $self;
}
sub ob {
    my $self = shift;
    $self->{G}->ob(@_);
}
sub CS {
    my $self = shift;
    [@{$self->{script}}]
}
sub continues {
    my ($W, $G) = @_; # %
    
    $Ghost::T = $G::T if ref $G eq "G";

    my ($namg) = $W->{G}->{name} =~ /\(\S+[^\)]*\)$/;
    $namg = "$W->{G}->{name} ".
        join("",("  ")x($Ghost::T->{depth}||1))."l-$W->{n} ";
    my $L = {
        uuid => (ref $H eq "H" ? $H->mkuid : $H->make_uuid),
        name => $namg,
        n => $W->{n}++,
        
        t => $Ghost::T->{t},
        
        i => $Ghost::T->{i},
        o => $Ghost::T->{o},
        T => $Ghost::T,
        G => $G,
        W => $W,
        
        depth => $Ghost::T->{depth},
    };
    
    if ($G->deeby) {
        print colored("Enters the $namg\t\ti:".Ghost::pint($L->{i})."\n",

            'black on_red');

        print colored("W: \t\tB{ ".Ghost::ki($L->{i}->{B})."\n", 'bright_red');
        print colored("   \tt = ".Ghost::gpty($L->{t})."\n", 'red');
    }
    
    push @{$W->{script}}, $L;
    $G->ob("continues...", $L);
    
    return $L;
}
sub wormfile_load {
    my $self = shift;
    $self->{file} = shift;
    if ($self->{file} && -e $self->{file}) {
        my $s = $self->{script} = LoadFile(Hostinfo::encode_utf8($self->{file}));
        die " script (loaded from $self->{file}) ne ARRAYref: ".($s||"~undef~")
            unless ref $s && $s eq "ARRAY";
        say "W $self->{file} loaded";
    }
    else {
        $self->{script} = [];
        #say "W ".($self->{file}||"~undef~ ->{file}")." not exist";
    }
}
sub encode_line {
    my $self = shift;
    my $yaml =  anydump([ shift ]);
# remove first line? indent? something to make it appendable to another array via yaml
    return $yaml;
}
sub wormfile_check {
    my $self = shift;
    my $file = $self->{file};
    unless (-e $file) {
        say "no $file";
        my ($wom) = $file =~ qr{(wormholes/.+)/};
        unless (-e $wom) {
            mkdir $wom;
        }
        `touch $file`;
    }
}

sub encode_thing {
    my $thing = shift;
    my $out = shift;
    $thing = "~undef~" unless defined $thing;
    return $thing;
}

sub uhigh {
    my $W = shift;
    my $n = $W->{n};
    my $u = scalar(@{$W->{script}});
    ($u ne $n ? $n : '')."x$u"; # acquire north, get high
}
sub pi {
    my $W = shift;
    "W ".$W->{name}." ".$W->uhigh
}
sub way_out {
    my $self = shift;
    if (my $T = $self->{G}->{T}) {
        # is connected to the..?
    }
    die "no way out";
}
sub event {
    my $self = shift;
    my $event = shift;
    #blah
}

1;

