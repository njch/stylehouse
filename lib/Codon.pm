package Codon;
use Scriptalicious;
use File::Slurp;

sub new {
    my $self = bless {}, shift;
    shift->($self);
    $self->{points} = shift || { 1 => 1 };
    $self;
}

sub display {
    my $self = shift;
    my $texty = shift;

    my $chunks = $self->{chunks};

    my @bits = (
        "!html <h2>$self->{name}</h2>"
    );
    my @open = ();

    for my $i (sort keys %$chunks) {
        my $v = $chunks->{$i};
        my $lines = $v->{lines};
        my $rows = scalar(@$lines);
        say "$i chunk";
        if ($self->{points}->{$i}) {
            # open
            my $code = join "\n", @{$v->{lines}};
            $code =~ s/"/\\"/g;
            $code =~ s/\n/\\n/g;
            say "$i Code is $rows lines\t\t$v->{first}";
            $rows = 25 if $rows > 25;
            push @bits,
                '!html !chunki='.$i.' '
                .'<textarea name="code" id="<<ID>>-ta" cols="77" rows="'.$rows.'"></textarea>'
                .'<input id="<<ID>>-up" type="submit" value="sav">'
        }
        else {
            # closed
            push @bits, $v->{first}." ($rows lines)";
        }
    }

    my $apo = sub {
        my $t = shift;
        my $s = shift;
        my $top = shift;
        my $n = { %$s };
        $n->{id} .= "-$t";
        $n->{left} -= 20;
        $n->{toppy} += $top;
        $n->{value} = $t;
        $n->{style} .= "border: 1px solid black;";
        $n;
    };
    $texty->{hooks}->{tuxts_to_html} = sub {
        my $self = shift;
        $self->{tuxts} = [
            map { $_->{chunki} ? ($_, $apo->("up", $_, 10), $apo->("x", $_, 30)) : $_ } @{$self->{tuxts}}
        ];
    };
    $texty->{origin} = $self; # same as $Codo->{the_codon} but not singular
    $texty->replace([
        @bits
    ]);
    $self->{text} = $texty;

    for my $s (@{ $texty->{tuxts} }) { # go through adding other stuff we can't throw down the websocket all at once
        my $id = $s->{id};
        my $i = $s->{chunki} || next;
        my $c = $chunks->{$i};
        say Codo::ddump($c);
        my $lines = $c->{lines};
        my $code = join "\n", @$lines;
        $code =~ s/"/\\"/g;
        $code =~ s/\n/\\n/g; # the escape is evaporated in JS string after the websocket
        say "Chunk $i is open to ".scalar(@$lines)." lines";
        $self->{hostinfo}->send(qq{\$('#$id-ta').append("$code"); }); # this could be partitioned easy
    }
}

sub up_load { # precursor to update
    my $self = shift;
    my $id = shift;
    my $sec = $self->{hostinfo}->claw_add( sub {
        my $e = shift;
        my $id = $e->{id};
        my $tuxt = $self->{text}->id_to_tuxt($id);
        my $chunki = $tuxt->{chunki} || die;
        $self->update($chunki => decode_entities($e->{code})); # only one codon on screen at a time, build fancier shit? can probably work around it fine.
    } );
    $self->{hostinfo}->send(
         "  ws.reply({claw: '$sec', id: '$id', code: document.getElementById('$id-ta').innerHTML}); "
    );
}

sub update {
    my $self = shift;
    my $i = shift;
    my $code = shift;
    my $chunks = $self->{chunks};

    $chunks->{$i}->{lines} = [ split "\n", $code ];

    my $lines = [];
    for my $i (sort keys %$chunks) {
        my $v = $chunks->{$i};
        push @$lines, @{$chunks->{$i}->{lines}};
    }
    write_file($self->{codefile}, join "\n", @$lines);
    $self->chunk();
}

sub load_file {
    my $self = shift;
    $self->{lines} = [map { $_ =~ s/\n$//s; $_ } read_file($self->{codefile})];
    $self->chunk();
}

sub chunk {
    my $self = shift;
# supposed to be a Tractor doing this

    my $lines = $self->{lines};

    # this consumes lines, should do wormhole at the end of init_wormhole
    my @stuff = ([]);
    for my $l (@$lines) {
        if ($l =~ /^\S+.+ \{$/gm) {
           push @stuff, [];
        }
        push @{ $stuff[-1] }, $l;
    }

    my $chunks;
    my $i = 0;
    for my $s (@stuff) {
        $chunks->{$i} = {
            first => $s->[0],
            length => @$s-1,
            lines => $s,
        };
        $i++;
    }
    $self->{chunks} = $chunks;
}

1;
