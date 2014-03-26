package Texty;
use Mojo::Base 'Mojolicious::Controller';
use Scriptalicious;

has 'owner';
has 'lines';
has 'id';

sub new {
    my $self = bless {}, shift;
    $self->owner(shift);
    $self->lines(shift);
    my $hostinfo = $self->owner->app->hostinfo;
    $hostinfo->screenthing($self);
    my $code = $self->encode_jquery();
    $self->owner->app->send($code);
}

sub set {
    my ($self, $i, $d) = @_;
}
sub encode_jquery {
    my $self = shift;
    my $es = $self->lines;
    my $id = $self->id;
    my $top = 20;
    my $left = 20;
    my @js;
    my $l = 0;
    for my $e (@$es) {
        if (ref $e) {
            die;
        }
        else {
            my $lspan = '<span class="data" style="'
                .'top: '.($top += 20).'px; '
                .'left: '.($left).'px;"'
                .' id="'.$id.'-'.$l++.'"'
                .'>'.$e.'</span>';
            
            push @js, "  \$('#view').append('$lspan');\n";
        }
    }
    if (@js) {
        # TODO controllers create views
        push @js, "  \$('#view').delegate('.data', 'click', function (event) {
            var data = {
                id: event.target.id,
                value: event.target.innerText,
                type: event.type,
                shiftKey: event.shiftKey,
                ctrlKey: event.ctrlKey,
                altKey: event.altKey,
            };
            console.log(event);
            ws.send('event '+JSON.stringify(data))
        })
";
    }

    return join("", @js);
};

sub event {
    my $self = shift;
    my $event = shift;

    $self->owner->app->send("\$('#$event->{id}').css('color', 'red');");
}

1;
