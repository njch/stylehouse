package View;
use Mojo::Base 'Mojolicious::Controller';
use Scriptalicious;
use Texty;
use Time::HiRes 'usleep';
sub ddump { Hostinfo::ddump(@_) }

has 'hostinfo';
has 'owner';
has 'divid';
has 'id';

my $div_styley = { # these go somewhere magical and together, like always
    hodu => "width:58%;  background: #352035; color: #afc; top: 50; height: 600px;",
    gear => "width:9.67%;  background: #352035; color: #445; top: 50; height: 20px;",
    view => "width:35%; background: #c9f; height: 500px;",
    hodi => "width:30%; background: #09f; height: 500px;",
    babs => "width:55%; background: #09f; height: 300px;",
};
sub new {
    my $self = bless {}, shift;
    shift->($self);
    my $this = $self->{owner} = shift;
    my $divid = $self->{divid} = shift;
    my $style = shift;
    my $attach = shift;
    my $where = shift;
    my $class = shift || "view";

    if (!$style) { # TODO rip out after get_view?
        $style = $div_styley->{$divid} || do{use Carp;confess};
    }

    my $div = '<div id="'.$divid.'" class="'.$class.'" style="'.$style.' ">'.$self->default_html.'</div>';

    $self->{hostinfo}->set('tvs/'.$divid.'/div', $div);
    $self->{hostinfo}->set('tvs/'.$divid.'/style', $style); # Tractorise

    my $exists = $self->{hostinfo}->get('tvs/'.$divid);
    if ($exists) {
        my $old = $self->{hostinfo}->get('tvs/'.$divid.'/top');
        say "View $divid already existed\n";
        $old->nah();
    }

    $self->{hostinfo}->accum('tvs/'.$divid, $self);

    say "Placing $this ->{$divid}";
    $this->{$divid} = $self unless $attach && $attach eq "not-on-this"; # TODO rip out unlessness after get_view

    $self->{hostinfo}->view_incharge($self);

    #say "\n # # (".($where||"?").")".($attach||"?")." $divid ";

    $where ||= "body";
    $where = "#".$where if $where =~ /^\w+$/;
    $attach ||= "append";

    # remember to say :first or :last etc in $where
    if ($attach && $attach eq "after") {
        $self->{hostinfo}->send("\$('$where').after('$div');");
    }
    elsif ($attach && $attach eq "before") {
        $self->{hostinfo}->send("\$('$where').before('$div');");
    }
    elsif ($attach && $attach eq "replace") {
        $self->{hostinfo}->send("\$('$where').replaceWith('$div');");
    }
    else {
        $self->{hostinfo}->send("\$('$where').append('$div');");
    }

    $self->{hostinfo}->send("\$('#$divid').fadeIn(300);");
    $self->wipehtml(); # set label
    $self->takeover();

    return $self;
}


# right so here we have an arc of stuff, going from motive to static
# menu items to text
# here's a travel too, that's kind of a mirage.
sub newtext {
    my $self = shift;
    delete $self->{text};
    $self->text(@_);
}
sub text {
    my $self = shift;

    $self->{text} ||= Texty->new($self->hostinfo->intro, $self, @_);
}

sub menu {
    my $self = shift;

    $self->{menu} ||= Menu->new($self->hostinfo->intro, $self, @_);
}

sub travel {
    my $self = shift;
    
    $self->{travel} ||= Travel->new($self->hostinfo->intro, $self);

    if (@_) {
        say "Travelling... A THING!";
        return $self->{travel}->travel([@_]);
    }
    return $self->{travel};
}

sub spawn_floozy {
    my $self = shift;
    my $this = shift if ref $_[0];
    my $divid = shift;
    my $style = shift || $self->{hostinfo}->get('tvs/'.$self->{divid}.'/style');
    my $attach = shift;
    my $where = shift;
    my $class = shift;

    if (!$attach && !$where) {
        if ($self->{ceiling}) {
            $attach = "after";
            $where = $self->{ceiling};
        }
        else {
            if ($self->{hostinfo}->get("floods/$self->{divid}")) {
                $attach = "before";
                $where = "#$self->{divid} *:first";
            }
            else {
                $attach = "append";
                $where = $self;
            }
        }
    }

    $where = "#$where->{divid}" if ref $where;

    my $floozy = $self->{hostinfo}->create_view(
        ($this || $self), $divid, $style,
        $attach => $where,
        $class,
    );

    $self->{hostinfo}->accum("floods/$self->{divid}", $floozy);
    $floozy->{floozal} = 1;

    $floozy;
}

sub spawn_ceiling {
    my $self = shift;
    my $this = shift if ref $_[0];
    my $divid = shift || $self->{divid}."_ceiling";
    my $style = shift;
    my $staticness = shift;
    
    $style .= " position: fixed;" if $staticness;

    my $c = $self->{ceiling} = $self->spawn_floozy(($this || $self), $divid, $style);

    if ($staticness) {
        $c->spawn_floon();
    }

    $c
}

sub spawn_floon { # floozy becomes fixed to a space above the floozal cortex
    my $self = shift;

    my $style = $self->{hostinfo}->get('tvs/'.$self->{divid}.'/style');
    my ($height) = $style =~ /(height:.+?;)/;
    my ($width) = $style =~ /(width:.+?;)/;
    $style = "$height $width opacity:0.1;";

    $self->{floon} = $self->spawn_floozy($self, $self->{divid}."_floon", $style, before => $self);
}

# Tractorise this thing, watch it
sub flooz {
    my $self = shift;
    my $what = shift;

    $self->{hostinfo}->flood($what => $self);
}

sub nah {
    my $self = shift;
    say "View removing ".$self->label;
    $self->hostinfo->send("\$('#$self->{divid}').slideUp(500, function () { this.remove(); });");
}

sub resume {
    my $self = shift;
    say "cannot be bothered resuming right now";
}

sub label {
    my $self = shift;
    my $o = $self->{owner};
    return do {
        if ($o->{divid} && $self->{divid} =~ /^$o->{divid}(.+)/) {
            "$1"
        }
        elsif ($o->{divid}) {
            "$o->{divid}/$self->{divid}"
        }
        else {
            ref($o).": $self->{divid}"
        }
    } . ($self->{extra_label} ? "<br/>$self->{extra_label}" : "");
}

sub default_html {
    my $self = shift;
       '<span class="'.$self->{id} .' divlabel'
       .'" style="position: absolute; right:0px; opacity: 0.1;">'
       .$self->label.'</span>'
}

sub html {
    my $self = shift;
    my $html = shift;
    if (defined $html) {
        $self->{html} = $self->default_html().$html;
    }
    else {
        $self->{html};
    }
}

sub wipehtml {
    my $self = shift;
    $self->hostinfo->send("\$('#".$self->{divid}." > *').remove();") if $self->html;
    $self->html("");
    # $self->fit_div(); TODO how to?
    1;
}

sub event {
    my $self = shift;
    my $event = shift;
    my $this = shift;

    say "Event in ".$self->label." heading for "
        .$self->owner.($self->{owner}->{name} ? " ($self->{owner}->{name})" : "");

    $self->owner->event($event, $this, $self);
}

sub takeover {
    my $self = shift;
    my $html = concat_array(shift);
    my $texty = shift;

    if (!defined $html) {
        say " $self->{divid} reload,";
        $html = $self->html;
    }
    elsif ($texty->{hooks}->{append}) {
        $self->{html} .= $html;
    }
    else {
        $self->hostinfo->send("\$('#".$self->{divid}." > *').remove();") if $self->html;
        $self->html($html);
    }

    $self->hostinfo->view_incharge($self);

    $self->append_spans($self->{divid} => $html);
    
#    $self->{hostinfo}->send("\$.scrollTo(\$('#$self->{divid}').offset.top(), 800);");
    $texty->tookover() if $texty;
}

sub append_spans {
    my $self = shift;
    my $divid = shift;
    my $html = shift;

    return say "\n\nno html\n\n" unless $html;

    if (length($html) < 30000) {
        $html =~ s/'/\\'/;
        $self->hostinfo->send("  \$('#$divid').append('$html');");
    }
    else {
        my @htmls = split /(?<=<\/span>)\s*(?=<span)/, $html;

        my @html_batches;
        my $b = [];
        for my $html (@htmls) {
            push @$b, $html;
            if (@$b > 10) {
                push @html_batches, [ @$b ];
                $b = [];
            }
        }
        push @html_batches, [ @$b ] if @$b;
        say anydump($html_batches[0]->[0]);
        say anydump($html_batches[1]->[0]);
        say "batchified htmls heading for #$divid from ".$self->owner.": ".(scalar(@html_batches)-1)." x 10 + ".scalar(@{$html_batches[-1]});

        for my $html_batch (@html_batches) {
            my $batch = join "", @$html_batch;

            $batch =~ s/'/\\'/;
            $self->hostinfo->send("  \$('#$divid').append('$batch');");
            usleep 10000;
        }
    }
}

sub concat_array {
    my $a = shift;
    return unless $a;
    if (ref \$a eq "SCALAR") {
        return $a;
    }
    else {
        return join "", map { concat_array($_) } @$a;
    }
}

1;
