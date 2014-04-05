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

sub ebug {
    my $self = shift;
    $self->{ebug} = shift if @_;
    $self->{ebug};
}
get '/hello' => sub {
    my $self = shift;

    unless ($self->ebug) {
        say "loading";
        $self->load();
    }

    $self->render(json => $self->output());
};
get '/exec/:command' => sub {
    my $self = shift;
    my $command = $self->stash('command');
    my $return = $self->ebug->$command();

    my $output = $self->output();
    $output->{return} = $return;
    $output->{command} = $command;

    $self->render(json => $output);
};

sub output {
    my $self = shift;
    my ($return, $time) = @_;
    my ($stdout, $stderr) = $self->ebug->output;
    return {
        line => $self->ebug->line,
        stdout => $stdout,
        stderr => $stderr,
        finished => $self->ebug->finished,
        package => $self->ebug->package,
        subroutine => $self->ebug->subroutine,
        line => $self->ebug->line,
        filename => $self->ebug->filename,
        codeline => $self->ebug->codeline,
    };
}

sub load {
    my $self = shift;
    $self->ebug(Devel::ebug->new);
    $self->ebug->program('test/stylehouse.pl');
    $self->ebug->load;

    # litter it with places to wait? explore
    my @filenames    = $self->ebug->filenames();
    @filenames = grep { /^lib|stylehouse\.pl$/ } @filenames;
    for my $filename (@filenames) {
        my $code = capture("cat $filename");
        my @codelines = split "\n", $code;
        my $line = 0;
        for my $codeline (@codelines) {
            if ($codeline =~ /my \$self = shift;/) {
                $self->ebug->break_point($filename, $line);
            }
            $line++;
        }
    }
}

app->start;
