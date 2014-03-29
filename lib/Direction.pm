package Direction;
use Mojo::Base 'Mojolicious::Controller';
use Scriptalicious;
use Texty;

has 'cd';
has 'app';
has 'hostinfo';

sub new {
    my $self = bless {}, shift;
    $self->cd(shift);
    $self->hostinfo(shift->hostinfo);
    $self->hostinfo->set('Direction', $self);
    $self->dir;
    return $self;
}
sub redir {
    my $self = shift;
    $self->hostinfo->send("\$('#view span').remove();");
    say "for ".$self->cd;
    $self->dir();
}
sub dir {
    my $self = shift;
    my @etc = map { s/\n$//s; $_ } capture("ls", "-lh", $self->cd);
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
    my $tx = shift;
    my $event = shift;
    my $texty = shift; # texty has triggers, brings events back to here
    say "Thanksyou: ".anydump($event);
    my ($filename) = $event->{value} =~
        m/....................................(.+)$/;
    $self->cd($self->cd."/$filename");
    $self->redir;
    $tx->send("\$('#$event->{id}').css('color', 'red');");
}

1;
