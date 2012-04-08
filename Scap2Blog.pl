
new Flow(
name => "scap2blog",
want => "satisfaction",
filename => do { use FindBin '$Script'; $Script },
be => sub {
    my $self = shift;
    my $tl = text_liner();
    # TODO see overload the Transducer, so:
    # my $sel = $tl->select(...)->trim_white;
    # pass $sel to blog stash...
    be($tl, {select => q[after 'use v5.10' and before 'my $junk =']});
    be($tl, {unselect => qr/^\s+$/});
    say Dump([
        map { $_->{1}->{text} } search("LineSelection->Text")
    ]);
    exit;
},
);

sub text_liner {
    my $tl =
new Transducer("TextLinerFile",
    be => sub {
        my $self = shift;
        unless ($self->linked("Text")) {
            use File::Slurp;
            my @lines = read_file($self->find_the("filename"));
            $self->link(new Text($_)) for @lines;
        }
        if (my $s = $self->find_the("select")) {
            my ($from, $froms, $to, $tos) = 
                $s =~ /(after) '(.+)' and (before) '(.+)'/;
            my $sle = new Stuff("LineSelection", spec => $s);
            $sle->link($self);
            my $region_match = 0;
            for my $t ($self->linked("Text")) {
                $_ = $t->{text};
                if (!$region_match && /\Q$froms\E/ && !/select.+\Q$s\E/) {
                    $sle->link($t) unless $from eq "after";
                    $region_match = 1;
                }
                elsif ($region_match && /\Q$tos\E/) {
                    $sle->link($t) unless $to eq "before";
                    $region_match = 0;
                }
                elsif ($region_match) {
                    $sle->link($t);
                }
            }
        }
        if (my $us = $self->find_the("unselect")) {
            my $sle = $self->linked("LineSelection");
            $DB::single = 1;
            my @linked_text = $sle->linked("Text");
            for my $t (@linked_text) {
                if ($t->{text} =~ $us) {
                    $sle->unlink($t);
                }
            }
            $sle->{spec} = {
                select => $sle->{spec},
                unselect => $us,
            };
        }
    },
);
    be($tl);
    return $tl;
}

1;
