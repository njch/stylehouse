package Git;
use strict;
use warnings;
use feature 'say';
use Scriptalicious;
use File::Slurp;
use utf8;

our $H;
sub ddump { Hostinfo::ddump(@_) }
sub new {
    my $self = bless {}, shift;
    shift->($self);

    $self->wire_procs();

    my $G = $H->{flood}->spawn_floozy($self, Git => "width:100%;  background: #352035; color: #aff;");
    $G->spawn_ceiling($self, gitrack => "width:98%; background: #2E0F00; color: #afc; font-weight: bold; margin:1em;", undef, undef, "menu");

    $self->gitrack();

    return $self;
}
sub gitrack {
    my $self = shift;
    
    my $ps = sub {
        my $cmd = shift;
        $cmd = "$$: $cmd\n";
        write_file("proc/start", {append => 1}, $cmd);
    };
    
    my @m;
    for my $r ('styleshed') {
        my $menu = [
    '⏚' => sub {
        say" HEading to $r";
        $ps->("cd ../$r && git gui");
    },
    'ⵘ' => sub {
        my @hmm = grep /stylehouse\.pl SHED/, `ps faux | grep stylehouse`;
        my @har = split /\s+/, pop @hmm;
        `kill -KILL $har[1]`;
    },
    '᎒' => sub {
        my @hmm = grep /S\.pm/, `ps faux | grep perl.l/S.p`;
        my @har = split /\s+/, pop @hmm;
        `kill -KILL $har[1]`;
    },
    'ܤ' => sub {
        `touch /s/stylehouse.pl`
    },
    'r' => sub {
        `touch /s/l/S.pm`
    },
    '.' => sub { `touch stylehouse.pl` },
        ];
        push @m,
        { _spawn => [ [], {
        nospace => 1,
        event => { menu => $menu },
        class => 'menu en',
        }],
        S_attr => { style => "font-size:36pt;"},
        };
    }
    my $rt = $self->{gitrack}->text([@m], {
        tuxtstyle => sub {
            my ($v, $s) = @_;
            $s->{style} .= 'opacity: 0.5; text-shadow: -2px -3px 3px #9999FF; padding: 4.20px; color: black; font-size: 2em; '.$H->random_colour_background();
        },
        class => "menu",
        nospace => 1,
    });
}
sub wire_procs {
    my $self = shift;
    my $tower = "/h/proc";
    die "proc tower $tower not exist"                                   unless -e $tower;
    die "proc tower $tower is a link somewhere else: ".readlink($tower) if -l $tower;
    die "proc tower $tower not directory" unless -d $tower;
}

1;

