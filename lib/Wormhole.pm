package Wormhole;
use Mojo::Base 'Mojolicious::Controller';
use Scriptalicious;
use File::Slurp;
use JSON::XS;
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
    my ($self, $ghost) = @_; # %

    my $line = {
        uuid => $H    ->make_uuid,
        n => $self->{n}++,
        
        t => encode_thing($ghost->{t}),
        
        i => $ghost->{i},
        o => $ghost->{o},
        T => $ghost->{T},
        
        e => ($ghost->{etc}),
        depth => $ghost->{depth},
        
        ghost => $ghost,
    };
    for my $o (@{$line->{o}}) {
        $o->{L} = $line;
    }

    $self->ob($line);

    push @{$self->{script}}, $line;
    
    return $line;
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

