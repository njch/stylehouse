package Codo;
use Mojo::Base 'Mojolicious::Controller';
use Scriptalicious;
use Texty;
=pod

Devel::ebug interface
slurpy other programs

Codo is for ghosting ghosts.
fishing around in the void.
flip through stuff.
so you can say, go here, what's this, watch this, find the pathway of its whole existence

context richness.

form.

and then they build 1s as Codons (genetic model for something like a travel/ghost/wormhole coupling)
where layers can be injected in space anywhere without breaking the fabric of it
right now time is not something we can flop out anywhere, depending on what we're going for
take that morality

=cut

has 'hostinfo';
sub ddump { Hostinfo::ddump(@_) }
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
    $self->{code} = $self->hostinfo->get_view($self, code => "hodu");

    $self->{obsetrav} = $self->hostinfo->set("Codo/obsetrav", []); # observations of travel

    $self->{codes} = $self->hostinfo->get("Codo/codes")
                  || $self->hostinfo->set("Codo/codes", []);

    $self->init_wormcodes(
        qw(ebuge.pl stylehouse.pl),
        glob("lib/*.pm"),
        glob("ghosts/*/*"),
    );

    $self->init_codemenu();

    return $self;
}

sub menu { # {{{
    my $self = shift;
    my $menu = {};
    $menu->{"nah"} = sub { $self->nah };
    $menu->{"new"} = sub { $self->new_ebuge() };
    $menu->{"<views>"} = sub {
        say "Sending view dump\n\n";
        $self->{run}->text->replace(ddump($self->hostinfo->get("screen/views/*")));
    };
    $menu->{"<obso>"} = sub {
        say "Sending obsotrav dump\n\n";
        $self->{run}->text->replace(ddump($self->hostinfo->get("Codo/obsetrav")));
    };

    return $menu;
}


sub init_codemenu {
    my $self = shift;

    $self->ports->{code}->menu({
        tuxts_to_htmls => sub {
            my $self = shift;
            for my $s (@{$self->tuxts}) {
                my $code = $s->{value};
                say "A menu for $code->{name} ".join", ", keys %$code;
                $s->{value} = $code->{name};
                $s->{origin} = $code;
                $s->{style} = random_colour_background();
                $s->{class} = 'menu';
            }
        },
        spatialise => sub {
            return { horizontal => 40 } # space tabs by 40px
        },
    });

    $self->ports->{code}->menu->replace($self->{codes});
} # }}}

sub load_codon {
    my $self = shift;
    my $codon = shift;
    my $codeview = $self->ports->{code};
    my $text = $codeview->text;

    my $id = $codeview->id."-code";
    $text->{hooks}->{div} = "code";

    $text->replace([qq{}]);
    $self->hostinfo->send("\$(window).off('click', clickyhand);");
    $self->hostinfo->send(qq{jQuery.get('/Codon/$codon->{name}', }
        .qq{function(code){ cm = CodeMirror(document.getElementById('$id'), { mode: 'perl', value: 'la' }) });});
}

sub get_codon {
    my $self = shift;
    my $mojo = shift;
    my $name = $mojo->param('name');
    if (!$name) {
        return say "\nMojoparam\n\n".anydump($mojo->param);
    }
    my $codon = $self->codon_by_name($name);
    my $lines = $codon->{lines};

    $mojo->app->log->info("Codo get_codon for $name ".@$lines);

    my $code = join "\n", @$lines;

    # this consumes lines, should do wormhole at the end of init_wormhole
    my @stuff = ([]);
    my $code;
    for my $l (@$lines) {
        if ($l =~ /^\S+.+ \{$/gm) {
           push @stuff, [];
        }
        push @{ $stuff[-1] }, $l;
    }
    my @lines = ();
    for my $s (@stuff) {
        push @lines, "$s->[0] (+".(@$s-1)." lines)";
    }

    $code = join "\n", @lines;

    $mojo->render(text => $code);
}

sub codon_by_name {
    my $self = shift;
    my $name = shift;
    my ($code) = grep { $_->{name} eq $name } @{ $self->{codes} };
    $code;
}

{   package Codon;
    
    sub new {
        my $self = bless {}, shift;
        shift->($self);
        $self;
    }
    sub show {
        my $self = shift;
        return;
    }
}
# get the forms of that clouds of ghosts
sub init_wormcodes {
    my $self = shift;
    my @codefiles = @_;

    for my $cf (@codefiles) {
        my $name = (($cf =~ /(\w+).pm$/)[0] || $cf);
        my $codon = $self->codon_by_name($name);
        my $isnew = 1 if !$codon;

        my $mtime = (stat $cf)[9];
        if ($isnew) {
            $codon = new Codon($self->hostinfo->intro);
            $codon->{codefile} = $cf;
            $codon->{name} = $name;
            $codon->{mtime} = $mtime;
        }

        if ($codon->{mtime} < $mtime) {
            say "$cf changed";
            $codon->{mtime} = $mtime;
            $isnew = 1;
        }

        if ($isnew) {
            $codon->{lines} = [map { $_ =~ s/\n$//s; $_ } read_file($codon->{codefile})]; # travel: we would be building
            push @{ $self->{codes} }, $codon;
            say "new Codon: $codon->{name}\t\t".scalar(@{$codon->{lines}})." lines";
        }
    }
}

=pod
}
#hmm
    # invent pointing $code->{point}
    my $current = "?";
    my $from = $current - 10;
    $from = 0 if $from < 0;
    @lines = splice @lines, $from, 200;
    $current = 10;
    my $spanid = $texty->tuxts->[$current-1]->{id};
    $self->hostinfo->send("\$('#$spanid').addClass('on');");
=cut

sub code_unfocus {
    my $self = shift;
    return unless $self->{code};
    $self->hostinfo->send("\$('.".$self->ports->{code}->id."').fadeOut(500);");
}

sub random_colour_background {
    my ($rgb) = join", ", map int rand 255, 1 .. 3;
    return "background: rgb($rgb);";
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
    my $id = $event->{id};
    my $tuxt = $self->ports->{code}->menu->text->id_to_tuxt($id);
    if (ref $tuxt->{origin} eq "Codon") {
        $self->load_codon($tuxt->{origin});
    }
    else {
        say "Barf!"
    }
}

1;
