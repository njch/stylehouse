package View;
use Mojo::Base 'Mojolicious::Controller';
use Scriptalicious;
use Texty;

has 'hostinfo';
has 'owner';
has 'divid';
has 'id';
has 'others';

sub new {
    my $self = bless {}, shift;
    shift->($self);

    $self->owner(shift);
    $self->divid(shift);
    my ($id) = $self->owner =~ /^(\w+)/;
    $self->hostinfo->screenthing($self);
    $self->id($id);
    $self->others(shift);

    $self;
}

# plugin for "And: $self->id"
# args: lines, hooks
sub text {
    my $self = shift;

    $self->{text} ||= Texty->new($self->hostinfo->intro, $self, @_);
}
sub kill {
    my $self = shift;
    $self->wipehtml;
}

sub wipehtml {
    my $self = shift;
    $self->hostinfo->send("\$('.".$self->id."').remove()");
}
sub hide {
    my $self = shift;
    $self->hostinfo->send("\$('.".$self->id."').hide()");
}
sub show {
    my $self = shift;
    $self->hostinfo->send("\$('.".$self->id."').show()");
}


sub takeover {
    my $self = shift;
    my $htmls = shift;
    my $append = shift;
    
    # other views .id set hidden
    $_->hide for @{ $self->others };

    $self->show;
   
    unless ($append) {
        # #divid span where id /&$self->id
        $self->hostinfo->send("\$('".$self->divid."').remove()");
    }
    
    my $divid = $self->divid;
    my @htmls = split /(?<=<\/span>)\s*(?=<span)/, join "", @$htmls;

    say "First: ". anydump(\@htmls);
    my @html_batches;
    my $b = [];
    for my $html (@htmls) {
        push @$b, $html;
        if (@$b > 10) {
            push @html_batches, [ @$b ];
            $b = [];
        }
    }
    push @html_batches, [ @$b ];
    say "Second: ". anydump(\@html_batches);

    for my $html_batch (@html_batches) {

        my $html = join "", @$html_batch;

        $html =~ s/'/\\'/;
        $self->hostinfo->send("  \$('#$divid').append('$html');");

    }
}

1;
