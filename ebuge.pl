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

use Devel::ebug;

our $ebug;
get '/hello' => sub {
    my $self = shift;

    load();

    $self->render(json => output());
};
get '/exec/:command' => sub {
    my $self = shift;
    my $command = $self->params('command');
    my $return = $ebug->$command();
    my $output = output($return);
    $self->render(json => $output);
};

sub output {
        my ($return, $time) = @_;
        my ($stdout, $stderr) = $ebug->output;
        return {
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
        };
}

sub load {

    $ebug = Devel::ebug->new;
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
