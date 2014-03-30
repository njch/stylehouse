package Direction;
use Mojo::Base 'Mojolicious::Controller';
use Scriptalicious;
use Texty;
use HTML::Entities;

has 'cd';
has 'app';
has 'hostinfo';

sub new {
    my $self = bless {}, shift;
    $self->cd(shift);
    $self->hostinfo(shift->hostinfo);
    $self->hostinfo->intro($self);
    $self->dir;
    return $self;
}
sub redir {
    my $self = shift;
    $self->hostinfo->send("\$('#view span').remove();");
    $self->dir();
}
sub dir {
    my $self = shift;
    my @etc = map { decode_entities($_) }
        map { s/\n$//s; $_ } capture("ls", "-lh", $self->cd);
    my $text = new Texty($self, [@etc], { view => "view" });
}
sub menu {
    my $self = shift;
    return {
        close => sub {
            $self->hostinfo->send("\$('#view span').remove();");
            # nuke from hostinfo
        },
        up => sub {
            my $cd = $self->cd;
            say "CD: $cd";
            $cd =~ s{/[^/]+?$}{};
            say "CD: $cd";
            $self->cd($cd);
            $self->redir;
        },
    };
}

sub event {
    my $self = shift;
    my $event = shift;
    my $texty = shift; # texty has triggers, brings events back to here
    say "Thanksyou: ".anydump($event);
    my ($filename) = $event->{value} =~
        m/....................................(.+)$/;
    $self->cd($self->cd."/$filename");
    if (-f $self->cd) {
        $self->hostinfo->send("\$('#$event->{id}').append('<span style=\"left: $event->{x}; top: $event->{y};\"><img src=\"file://".$self->cd."\"></img></span> ');");
        
    }
    else {
        $self->redir;
    }
}

1;
