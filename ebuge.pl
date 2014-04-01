#!/usr/bin/perl
use strict;
use warnings;
use JSON::XS;
use Scriptalicious;
use Carp 'confess';
use v5.18;
use FindBin '$Bin';
say "\n\n\nwe are $Bin/$0";

use Mojolicious::Lite;

my $ebug;
websocket '/ebuge' => sub {
    my $self = shift;
    say "Blahh!";

    $self->app->log->info("WebSocket opened");

    my $output = sub {
        my ($return, $time) = @_;
        my ($stdout, $stderr) = $ebug->output;
        $self->tx->send(encode_json({
            line => $ebug->line,
            stdout => $stdout,
            stderr => $stderr,
            finished => $ebug->finished,
            package => $ebug->package,
            subroutine => $ebug->subroutine,
            line => $ebug->line,
            filename => $ebug->filename,
            code => $ebug->codeline,
            return => $return,
        })."\n");
    };

    $self->on(message => sub {
        my ($self, $msg) = @_;

        $self->app->log->info("WebSocket: $msg");

        if ($msg =~ /hello/) {
            $ebug = _load();
            $output->(undef);
        }
        elsif ($msg =~ /exec (.+)/) {
            my $command = $1;
            my $return = $ebug->$command();
            $output->($return);
        }
    });

    $self->on(finish => sub {
      my ($self, $code, $reason) = @_;
      $self->app->log->debug("WebSocket closed with status $code.");
    });

};

sub _load {

    my $ebug = Devel::ebug->new;
    $ebug->program('test/stylehouse.pl');
    $ebug->load;

    # litter it with places to wait
# might even need a middleware so we can consider the jam instead of just jamming
    my @filenames    = $ebug->filenames();
    @filenames = grep { /^lib|stylehouse\.pl$/ } @filenames;
    for my $filename (@filenames) {
        my $code = capture("cat $filename");
        my @codelines = split "\n", $code;
        my $line = 0;
        for my $codeline (@codelines) {
            if ($codeline =~ /my \$self = shift;/) {
                $ebug->break_point($filename, $line);
            }
            $line++;
        }
    }
}

app->start;
