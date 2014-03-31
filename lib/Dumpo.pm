package Dumpo;
use Mojo::Base 'Mojolicious::Controller';
use Scriptalicious;
use Texty;

has 'cd';
has 'hostinfo';
has 'view';

sub new {
    my $self = bless {}, shift;
    $self->hostinfo(shift->hostinfo);
    $self->hostinfo->intro($self);
    my $object = shift;

    $self->view("hodi");

    $self->updump($object, "init");

    return $self;
}

sub menu {
    my $self = shift;
    return {
        updump => sub {
            $self->updump;
            my $event = shift;
            $self->hostinfo->send(
                "\$('#$event->{id}').delay(100).fadeOut().fadeIn('slow')");
        },
    };
}

sub updump {
    my $self = shift;
    my $object = shift;
    my $init = shift;
    if (!$init) {
        $self->hostinfo->send("\$('#".$self->view." span').fadeOut(500);");
    }
        

    use File::Slurp;
    write_file('public/dump2', "Balls\n\n".anydump($self->hostinfo->data));

    my $text = new Texty($self, [$self->thedump($self->hostinfo->data)],
        { view => $self->view,
        skip_hostinfo => 1 }
    );
}

sub thedump {
    my $self = shift;
    my $thing = shift;
    my $owner = shift;
    $owner ||= $self;
    my $hooks = $self->hostinfo->get('dumphooks');
    push @$hooks, {
        ref => "HASH",
        getlines => sub {
            my $thing = shift;
            my $hooks = shift;
            my $d = shift;
            my @ks = sort keys %$thing;
            my @sub;
            for my $k (@ks) {
                push @sub, "$k => ", dumpdeal($thing->{$k}, $hooks, $d+1)
            }
            return ("THIS $thing", @sub);
        },
    }, {
        ref => "Lyrico",
        getlines => sub {
            my $thing = shift;
            my $hooks = shift;
            my $d = shift;
            my @ks = sort keys %$thing;
            my @sub;
            for my $k (@ks) {
                push @sub, "$k => ", dumpdeal($thing->{$k}, $hooks, $d+1)
            }
            #return ('<span style="'.random_colour_background().'>'.$thing.'</span>', @sub);
            return new Texty($owner, ["Lyrico", @sub], { leave_spans => 1 });
        },
    }, {
        ref => "Texty",
        getlines => sub {
            my $thing = shift;
            my $hooks = shift;
            my $d = shift;
            my @ks = sort keys %$thing;
            my @sub;
            for my $k (@ks) {
                push @sub, "$k => ", dumpdeal($thing->{$k}, $hooks, $d+1)
            }
            #return ('<span style="'.random_colour_background().'>'.$thing.'</span>', @sub);
            return new Texty($owner, ["Texty owner=".$thing->{owner}, @sub], { leave_spans => 1 });
        },
    };
    my @dump = dumpdeal($thing, $hooks);
    return @dump;
}
sub dumpdeal {
    my $thing = shift;
    my $hooks = shift;
    my $depth = shift;
    $depth = 1;
    my @lines;
    my $ignore;

    my $dohook = sub {
        my $h = shift;
        my $d;
        if ($h->{getlines}) {
            push @lines, $h->{getlines}->($thing, $hooks, $depth);
        }
        else {
            say "                   NO SOLUTION?";
        }
    };
    my $scanhooks = sub {
        for my $h (@$hooks) {
            if ($h->{ref}) {
                if (ref $thing eq $h->{ref}) {
                    $dohook->($h) && return 1;
                    last;
                }
            }
        }
    };
    unless ($scanhooks->()) {
        push @lines, "? $thing";
    }
    ref $_ || s/^/('  ')x$depth/e for @lines;
    return @lines;
}

sub event {
    my $self = shift;
    my $event = shift;
    #blah
}

1;
