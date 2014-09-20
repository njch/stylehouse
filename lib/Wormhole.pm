package Wormhole;
use Mojo::Base 'Mojolicious::Controller';
use Scriptalicious;
use File::Slurp;
use JSON::XS;
use Term::ANSIColor;
use Texty;
my $json = JSON::XS->new->allow_nonref(1)->allow_unknown(1);
use HTML::Entities;
sub ddump { Hostinfo::ddump(@_) }

our $H;
sub new {
    my $self = bless {}, shift;
    shift->($self);
    delete $self->{hostinfo};
    
    $self->{G} = shift;
    $self->{n} = 0;

    $self->wormfile_load(shift);

    say $self->describe_size;

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

    my ($namg) = $W->{G}->{name} =~ /\(\S+[^\)]*\)$/;
    $namg = "$W->{G}->{name} ".
        join("",("  ")x$Ghost::T->{depth}||1)."l-$W->{n} ";
    my $L = {
        uuid => $H->make_uuid,
        name => $namg,
        n => $W->{n}++,
        
        t => $Ghost::T->{t},
        
        i => $Ghost::T->{i},
        o => $Ghost::T->{o},
        T => $Ghost::T,
        
        
        depth => $Ghost::T->{depth},
        
        G => $G,
    };

    $W->ob($L);
    
    
    print colored("Enters the $namg\t\ti:".Ghost::pint($L->{i})."\n",
    
        'black on_magenta');
        
    print colored("W: \t\tB{ ".Ghost::ki($L->{i}->{B})."\n", 'bright_red');
    print colored("   \tt = ".Ghost::gpty($L->{t})."\n", 'bright_blue');

    push @{$W->{script}}, $L;
    
    return $L;
}
sub wormfile_load {
    my $self = shift;
    $self->{file} = shift;
    if (-e $self->{file}) {
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

# here's a tube for reflecting this wormhole into Texty so development can basically see it without Travel
# Form would Ghost all sorts of data type munging and humanisation through geometric arrangements of thought process
# also space bending etc.
# it can help make a lot of tractograms under the smooth curve of the human show.
# here we call another branch of thought in Ghost Ghost

# this whole procedure should be mapped/plumbed, all the way out to the View, Elvi, etc
# and usable as a flowing with nice triggers and invisible but well organised complications.
# which is the whole stylehouse deal.
# it's the call stack/circuit fish tank, from state tube to layers & lingo tricks to items in a Texty.
# Form is a well-known bunch of Ghost
sub describe_size {
    my $self = shift;
    "W $self->{n}x".scalar(@{$self->{script}});
}
sub desize { shift->describe_size }
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

