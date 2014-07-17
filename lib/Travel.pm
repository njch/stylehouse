package Travel;
use Mojo::Base 'Mojolicious::Controller';
use Scriptalicious;
use Texty;
use Ghost;
sub ddump { Hostinfo::ddump(@_) }
has 'cd';
our $H;
sub new {
    my $self = bless {}, shift;
    shift->($self);
    delete $self->{hostinfo};

    $self->{O} = shift || die "no O";
    $self->{from} = [$self->{O}, @_];
    $self->{name} = $self->{O}->{name} || $self->{O}->{id} || "$self->{O}";

    return $self;
}
sub watch_file_streams {
    my $self = shift;
    for my $st (@{ $self->{file_streams} }) {
        my ($ino, $ctime, $mtime, $size) =
        (stat $st->{filename})[1,10,9,7];

        my @diffs;
        if (!defined $st->{size}) {
            $st->{size} = $size;
            $st->{ctime} = $ctime;
            $st->{mtime} = $mtime;
            $st->{ino} = $ino;
        }
        else {
            push @diffs, "Size: $size < $st->{size}" if $size < $st->{size};
            push @diffs, "ctime: $ctime != $st->{ctime}" if $ctime != $st->{ctime};
            push @diffs, "modif time: $mtime != $st->{mtime}" if $mtime != $st->{mtime};
            push @diffs, "inode: $ino != $st->{ino}" if $ino != $st->{ino};
        }
        
        if (@diffs) {
            say "$st->{filename} has been REPLACED or something:";
            say "    $_" for @diffs;
        }
        
        if ($st->{lines}) {
            
            unless ($st->{handle}) {
                open(my $fh, '<', $st->{filename})
                    or die "cannot open $st->{filename}: $!";
                # TODO tail number of lines $st->{tail}
                while (<$fh>) {
                    unless (defined $st->{tail}) {
                        my $l = clean_text($_);
                        push @{$st->{lines}}, $l;
                        $st->{linehook}->($l);
                    }
                }
                $st->{handle} = $fh;
            }
            
            if (@diffs) {
                $st->{hook_diffs}->(\@diffs, $st);
            }
            
            if ($size > $st->{size}) {
                say "$st->{filename} has GROWTH";
                my $fh = $st->{handle};
                while (<$fh>) {
                    my $l = clean_text($_);
                    push @{$st->{lines}}, $l;
                    $st->{linehook}->($l);
                }
                $st->{size} = (stat $st->{filename})[7];
            }
            elsif ($size == $st->{size}) {
            }
            else {# size < $st->size means file was re-read for @diffs
            }
            
        }

        push @diffs, "Size: $size > > >  $st->{size}" if $size > $st->{size};
        
        if (my $gs = $st->{ghosts}) {
            if (@diffs) {
                my $gr = $self->{ghosts_to_reload} ||= do {
                    $self->timer(0.3, sub { $self->reload_ghosts });
                    {};
                };
                while (my ($gid, $gw) = each %$gs) {
                    for my $wn (keys %$gw) {
                        $gr->{$gid}->{$wn} = 1;
                    }
                }
            }
        }
        elsif ($st->{touch_restart} && @diffs) {
            $H->restarting;
        }
        else { die "something$size > $st->{size})  else?" }
        
        
        $st->{size} = $size;
        $st->{ctime} = $ctime;
        $st->{mtime} = $mtime;
        $st->{ino} = $ino;
    }
}
sub G {
    my $self = shift;
    $self->{G} ||= new Ghost($H->intro, $self, @_);
}
sub W {
    shift->G->W
}
sub ob {
    my $self = shift;
    return unless $self->{TT};
    
    my $ob = $H->enlogform(@_); # describes stack, etc
    push $ob, [@Ghost::F], pop $ob;
# we want to catch runaway recursion from here
    $self->{TT}->T($ob);
}

# the wormhole for self
# so G can make higher frequency W inside a singular T
# self awareness
sub T {
    my $T = shift;
    my $t = shift;
    my $G = shift || $T->G; # A...
    my $i = shift;
    my $depth = shift || 0;
    my $last_line = shift;
    
    $T->ob("Travel", $depth, $t);
    (my $td = $t||"~") =~ s/\n/\\n/g;
    say("$T->{id} ".$G->idname."            $depth to $td    ".($i?($i->{K}||$i->{name}):"?")) unless $G->{name} =~ /Lyrico\/ob/;
    
    my ($line, $o) = $G->haunt($T, $depth, $t, $i, $last_line);

    my @r = $T->W;
    for my $c (@$o) {
        if (exists $c->{travel_this}) {
            $T->T($c->{travel_this}, $G, $c, $depth+1, $line);
        }
        elsif (exists $c->{arr_returns}) {
            @r = @{$c->{arr_returns}};
        }
        else {
            die "what kind of way out is ".ddump($c);
        }
    }

    return @r;
}
sub event {
    my $self = shift;
    my $event = shift;
    #blah
}

1;

