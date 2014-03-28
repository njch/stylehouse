package Conty;
use Mojo::Base 'Mojolicious::Controller';
use Scriptalicious;
use Texty;

my @apps;

sub initiate {
    my $self = shift;

    $self->hostinfo->set("screen"); # just because
    # this bit could be like a transaction, handler hooked into message
    $self->app->send("ws.send('screen: '+screen.availWidth+'x'+screen.availHeight.')");
    # startup applications:
    push @apps, Lyrico->new();
    push @apps, Direction->new("/home/s/Music");
    push @apps, Dumpo->new();
}


sub message {
    my $self = shift;
    my $msg = shift;

    # all sorts of things want to get in here...
    if ($msg eq "Hello!") {
        # clear the way, or merge with it?
        # need to blow away
    }
    elsif ($msg =~ /^screen: (\d+)x(\d+)$/) {
        $self->hostinfo->set("screen/width" => $1); # per client?
        $self->hostinfo->set("screen/height" => $2); # per client?
    }
    elsif ($msg =~ /^event (.+)$/s) {
        my $event = decode_json($1);
        
        my $thing = $self->hostinfo->event_id_thing_lookup($event);
        
        unless ($thing) {
            # probably a Dumpo which hides texts to avoid loops
            $self->app->log->error("Thing lookup failed for $event->{id}");
            $self->app->send(
                "\$(body).addStyle('dead').delay(250).removeStyle('dead');"
            );
        }
        else {
            $self->app->log->info("Thing lookup $event->{id} -> $thing->{thing}");
            $thing->{thing}->event($event);
            # route to $1 via hostinfo register of texty thing owners
        }
    }
    else {
        $self->send("// echo: $msg");
    }
}

1;
