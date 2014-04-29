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

    $self->{run} = $self->hostinfo->get_view($self, run => "hodi");
    $self->{code} = $self->hostinfo->get_view($self, code => "hodu")->onunfocus(sub { $self->code_unfocus });

    $self->{pics} = $self->hostinfo->set("Codo/pics", {}); # stuff goin on live in this process

    $self->{codes} = $self->hostinfo->get("Codo/codes")
                  || $self->hostinfo->set("Codo/codes", []);

    $self->init_wormcodes(qw{ebuge.pl stylehouse.pl}, glob "lib/*.pm");

    $self->make_code_menu();

    $self->code_focus('stylehouse.pl');

    return $self;
}

sub menu {
    my $self = shift;
    my $menu = {};
    $menu->{"nah"} = sub { $self->nah };
    $menu->{"new"} = sub { $self->new_ebuge() };
    $menu->{"<views>"} = sub { $self->show_views(); };

    return $menu;
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
}
sub show_views {
    my $self = shift;
    $self->{run}->travel($self->hostinfo->get("screen/views/*"))->appear();
}

sub code_unfocus {
    my $self = shift;
    $self->hostinfo->send("\$('.".$self->ports->{code}->id."').fadeOut(500);");
    # TODO carefully suspend their Texty + Ghosts
}

sub code_focus {
    my $self = shift;
    my $codename = shift;
    my $point = shift;

    if ($self->{code_focus}) {
        $self->code_unfocus();
    }

    my $code = $self->code_by_name($codename) || die;
    $code->{point} = $point;

    $self->{code_focus} = $code;


    # gather outselves to point :D!
    # this consumes lines, should do wormhole at the end of init_wormhole
    my @stuff = ([]);
    for my $l (@{$code->{lines}}) {
        if ($l =~ /^\S+.+ \{$/gm) { # travel... as we see this branch a lines from the spine route
           push @stuff, [];
        }
        push @{ $stuff[-1] }, $l;
    }
    my @lines = ();
    for my $s (@stuff) {
        push @lines, "$s->[0] (+".(@$s-1)." lines)";
    }

    my $texty = new Texty( # auto takeover onto the screen
        $self->hostinfo->intro,
        $self->ports->{code},
        [@lines],
    );

    $texty->{code} = $code;
    $code->{texty} = $texty;

    if (0) {
        # invent pointing $code->{point}
        my $current = "?";
        my $from = $current - 10;
        $from = 0 if $from < 0;
        @lines = splice @lines, $from, 200;
        $current = 10;
        my $spanid = $texty->tuxts->[$current-1]->{id};
        $self->hostinfo->send("\$('#$spanid').addClass('on');");
    }
}

sub init_wormcodes {
    my $self = shift;
    my @codefiles = @_;

    for my $cf (@codefiles) {
        my $codename = (($cf =~ /(\w+).pm$/)[0] || $cf);
        my $code = $self->code_by_name($codename);

        my $isnew = 1 if !$code;

        my $mtime = (stat $cf)[9];
        if ($isnew) {
            $code = {
                codefile => $cf,
                codename => $codename,
                mtime => $mtime,
            };
        }

        if ($code->{mtime} < $mtime) {
            say "$cf changed";
            $code->{mtime} = $mtime;
            $isnew = 1;
        }

        if ($isnew) {
            $code->{lines} = [read_file($code->{codefile})]; # travel here
            push @{ $self->{codes} }, $code;
        }
    }
}

sub code_by_name {
    my $self = shift;
    my $name = shift;
    my ($code) = grep { $_->{codename} eq $name } @{ $self->{codes} };
    $code;
}


sub random_colour_background {
    my ($rgb) = join", ", map int rand 255, 1 .. 3;
    return "background: rgb($rgb);";
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

    my $picture = Hostinfo::ddump(\@seen);
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



sub event {
    my $self = shift;
    my $event = shift;
    #blah
}

1;
