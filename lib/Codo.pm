package Codo;
use Mojo::Base 'Mojolicious::Controller';
use Scriptalicious;
use Texty;
=pod
Devel::ebug interface
slurpy other programs

Codo is one whole universe of code
flip through them, prepare another program execution behind the one the user is looking at
so you can say, go here, what's this, watch this, find the pathway of its whole existence


=cut

has 'hostinfo';
has 'ports' => sub { {} };
has 'ebuge' => sub { [] };
has 'output';
use Mojo::UserAgent;
use JSON::XS;
use File::Slurp;

sub DESTROY {
    my $self = shift;
    $self->nah;
}
sub new {
    my $self = bless {}, shift;
    shift->($self);

    $self->hostinfo->get_view($self, run => "hodi");
    $self->hostinfo->get_view($self, code => "hodu")->onunfocus(sub { $self->code_unfocus });

    $self->{pics} = $self->hostinfo->set("Codo/pics", {});




    $self->{codes} = $self->hostinfo->get("Codo/codes")
                  || $self->hostinfo->set("Codo/codes", []);

    my @files = (qw{ebuge.pl stylehouse.pl}, glob "lib/*.pm");
    for my $codefile (@files) {
        $self->resume_codefile($codefile);
    }

    $self->make_code_menu();

    $self->code_focus('stylehouse.pl');

    return $self;
}

sub make_code_menu {
    my $self = shift;

    $self->ports->{code}->menu({
        tuxts_to_htmls => sub {
            my $self = shift;
            for my $s (@{$self->tuxts}) {
                my $code = $s->{value};
                $s->{value} = $code->{codename};
                $s->{origin} = $code;
                $s->{style} = random_colour_background();
                $s->{class} = 'menu';
            }
        },
        spatialise => sub {
            return { horizontal => 40 } # space tabs by 40px
        },
    });

    $self->update_code_menu();
}

sub update_code_menu {
    my $self = shift;

    $self->ports->{code}->menu->replace($self->{codes});

    return $self;
}

sub code_unfocus {
    my $self = shift;
    $self->hostinfo->send("\$('.".$self->ports->{code}->id."').fadeOut(500);");
    # TODO carefully suspend their Texty + Ghosts
}

sub code_focus {
    my $self = shift;
    my $codefile = shift;
    my $point = shift;

    if ($self->{code_focus}) {
        $self->code_unfocus();
    }

    my $code = $self->get_code($codefile) || die;
    $code->{line} = $point->{line} if $point->{line};
    $self->{code_focus} = $code;

# make this out of Ghosts
    my @lines = lines_for_file($codefile);
    my @stuff = ([]);
    for my $l (@lines) {
        if ($l =~ /^\S+.+ \{$/gm) {
           push @stuff, []
        }
        push @{ $stuff[-1] }, $l;
    }
    @lines = ();
    for my $s (@stuff) {
        push @lines, "$s->[0] (+".(@$s-1)." lines)";
    }
    return \@lines;
    my $current = $point->{line} || 0;

    if ($current) {
        my $from = $current - 10;
        $from = 0 if $from < 0;
        @lines = splice @lines, $from, 200;
        $current = 10;
    }

    my $texty = new Texty( # auto takeover onto the screen
        $self->hostinfo->intro,
        $self->ports->{code},
        [@lines],
    );

    my $spanid = $texty->tuxts->[$current-1]->{id};
    $self->hostinfo->send("\$('#$spanid').addClass('on');");

    $texty->{code} = $code;
    $code->{texty} = $texty;
}

sub get_code {
    my $self = shift;
    my $codefile = shift;
    my ($code) = grep { $_->{codefile} eq $codefile } @{ $self->{codes} };
    return $code;
}

sub resume_codefile {
    my $self = shift;
    my $codefile = shift;

    my $code = $self->get_code($codefile);
    my $isnew = 1 if !$code;
    if ($isnew) {
        $code = {
            codefile => $codefile,
            codename => (($codefile =~ /(\w+).pm$/)[0] || $codefile),
            mtime => 0,
        };
    }
    my $mtime = (stat $codefile)[9];
    if ($code->{mtime} < $mtime) {
        say "$codefile changed";
        $code->{mtime} = $mtime;
        $code->{rogue_change_detected} = 1;
        # $self->ports->{code}->menu->flash($code, "mtime changed"); # do merge if problemo. later.
    }

    if ($isnew) {
        push @{ $self->{codes} }, $code;
    }
}

sub random_colour_background {
    my ($rgb) = join", ", map int rand 255, 1 .. 3;
    return "background: rgb($rgb);";
}

sub lines_for_file {
    my $filename = shift;
    return split "\n", read_file($filename);
}

sub code_mirror {
    my $self = shift;

# for Ghosts and Ways
# client side state for codemirrors
# put coloured blocks over different parts of the code to shade it pretty colours
# when clicked they relay the click to the codemirror?
# might be possible one day, maybe underneath transparent codemirror...

#    ->text(['CodeMirrrrrrr']);
#    my $cm_init = 'CodeMirror(document.getElementById(\''.$codem->id.'-1\'), {mode:  "perl", theme: "cobalt"});';
#    say "Doing it! $cm_init\n\n\n";
#    $self->hostinfo->send($cm_init);

}

sub thedump {
    my $self = shift;
    my $dumpo = $self->hostinfo->get("Dumpo") || die;
    $dumpo->thedump(@_);
}

# break happening
sub take_picture {
    my $self = shift;
    my $picid = shift;
    my @seen = @_;

    my $stack = [ map { [ caller($_) ] } 0..10 ];

    my $pic;
    unless ($pic = $self->{pics}->{$picid}) {
        say "Codo: no such $picid, adding";
        my $f = $stack->[0];
        $f = "$f->[0] $f->[3] ($f->[1] $f->[2])";
        $pic = $self->{pics}->{$picid} = {
            picid => $picid,
            name => "Rogue from $f",
            pics => [],
        };
    }

    my $picturehooks = $pic->{hooks};

    my $picture = [$self->thedump(\@seen, $picturehooks)];
    push @{$pic->{pics}}, {
        stack => $stack,
        picture => $picture,
    };
}

sub nah {
    my $self = shift;
    for my $ebuge (@{ $self->ebuge }) {
        unless ($ebuge) {
            say "weird, no ebuge...";
            next;
        }
        $ebuge->nah;
    }
    $self->ebuge([]);
}

sub new_ebuge {
    my $self = shift;
    my $ebuge = Ebuge->new($self->hostinfo->intro, "ebuge.pl");
    push @{ $self->ebuge }, $ebuge;
    return $ebuge;
}

sub menu {
    my $self = shift;
    my $menu = {};
    $menu->{"nah"} = sub { $self->nah };
    $menu->{"new"} = sub { $self->new_ebuge() };

    return $menu;
}



sub event {
    my $self = shift;
    my $event = shift;
    #blah
}

1;
