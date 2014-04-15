package Codo;
use Mojo::Base 'Mojolicious::Controller';
use Scriptalicious;
use Texty;


has 'hostinfo';
has 'ports' => sub { {} };
has 'ebuge' => sub { [] };
has 'output';
use Mojo::UserAgent;
use JSON::XS;
use File::Slurp;

sub DESTROY {
    my $self = shift;
    $self->killall;
}
sub new {
    my $self = bless {}, shift;
    shift->($self);

    $self->hostinfo->get_view($self, run => "hodi");
    my $codem = $self->hostinfo->get_view($self, code => "hodu");

    $self->{pics} = $self->hostinfo->set("Codo/pics", {});




    $self->{codes} = $self->hostinfo->get("Codo/codes")
                  || $self->hostinfo->set("Codo/codes", []);

    for my $codefile (qw{ebuge.pl stylehouse.pl}, glob "lib/*.pm") {
        $self->resume_codefile($codefile);
    }

    $code_vie

    $self->code_focus('stylehouse.pl', {line => 50});

    return $self;
}

sub code_focus {
    my $self = shift;
    my $codefile = shift;
    my $point = shift;

    if ($self->{code_focus}) {
        $self->hostinfo->send("\$('.codocode').fadeOut(500);");
        # TODO carefully suspend their Texty + Ghosts
    }

    my $code = $self->get_code($codefile) || die;
    $code->{line} = $point->{line} if $point->{line};
    $self->{code_focus} = $code;

    my @lines = lines_for_file($codefile);

    my $current = $point->{line} || 0;

    if ($current) {
        my $from = $current - 10;
        $from = 0 if $from < 0;
        @lines = splice @lines, $from, 20;
        $current = 10;
    }

    my $text = new Texty(
        $self->hostinfo->intro,
        $self->ports->{code},
        [@lines],
        { class => 'codocode' },
    );

    $code->{texty}

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
}


sub lines_for_file {
    my $filename = shift;
    return split "\n", read_file($filename);
}

sub code_mirror {
    my $self = shift;

    # interrupt section of spans of code with a codemirror window of the same
    # hold all such patches of change open until the programmer commits a wander

#    ->text(['CodeMirrrrrrr']);
#    my $cm_init = 'CodeMirror(document.getElementById(\''.$codem->id.'-1\'), {mode:  "perl", theme: "cobalt"});';
#    say "Doing it! $cm_init\n\n\n";
#    $self->hostinfo->send($cm_init);
}

sub code_sheet {
    my $self = shift;

    # CODE
    my @lines = lines_for_file($output->{filename});

    my $spanid = $text->tuxts->[$current-1]->{id};
    $self->hostinfo->send("\$('#$spanid').addClass('on');");
sub thedump {
    my $self = shift;
    my $dumpo = $self->hostinfo->get("Dumpo") || die;
    $dumpo->thedump(@_);
}
sub view_code {
    my $self = shift;
    my $cv = $self->ports->{run};
    $cv}

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

sub killall {
    my $self = shift;
    for my $ebuge (@{ $self->ebuge }) {
        unless ($ebuge) {
            say "weird, no ebuge...";
            next;
        }
        $ebuge->kill;
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
    $menu->{"killall"} = sub { $self->killall };
    $menu->{"new"} = sub { $self->new_ebuge() };

    return $menu;
}



sub event {
    my $self = shift;
    my $event = shift;
    #blah
}

1;
