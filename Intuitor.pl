use strict;
use warnings;

$main::junk->link(new Text($_)) for (
    "../Music/Fahey/Death Chants, Breakdowns and Military Waltzes/Fahey, John - 08 - The Downfall Of The Adelphi Rolling Grist Mill.flac",
    "../Music/Fahey/Death Chants, Breakdowns and Military Waltzes/Fahey, John - 08 - The Downfall Of The Adelphi Rolling Grist Meal.flac",
    "../Music/Fahey/Death Chants, Breakdowns and Military Waltzes/Fahey, John - 04 - Some Summer Day.flac",
    "/home/steve/Music/Fahey/Death Chants, Breakdowns and Military Waltzes/Fahey, John - 04 - Some Summer Day.flac"
);

new Flow(
name => "Intuitor", # {{{
want => new Pattern(object => "Text"),
be => sub {
    my $self = shift;

    ensure_intuitions_exist($self);

    my @its = map { $_->{it} } $self->linked("In");
    for my $it (@its) {
        my @patterns = $self->linked("Intuition->Pattern");
        my @matching = grep { $_->match($it) } @patterns;
        my @ints = map { $_->linked("Intuition") } @matching;

        for my $int (@ints) {
            next if $int->links($it); # already

            # say " looking: $self->{cer} $self->{name}...";
            my $cog = $int->{cog};
            my $t = $it->text;
            my @val = 
                ref $cog eq "Regexp" ? $t =~ $cog :
                ref $cog eq "CODE" ? $cog->($t) :
                die;
            # say @val ? "   @val" : "NOPE";
            @val = [@val] if @val > 1;
            @val = (1) if @val == 0 && ref $cog ne "Regexp";

            # say "intuited $self->{name}";
            $int->link($it, @val);
        }
    }
},
); # }}}


sub END {
    return;
    my @ints = search("Junk->Text->Intuition");
    my @texts = sort map { "$_->{0}" } @ints;
    my %fin;
    for my $text (uniq @texts) {
        my @ours = grep { $text eq "$_->{0}" } @ints;
        my @links = map { summarise($_->{1}, $_->{val}) } @ours;
        $fin{$ours[0]->{0}->{text}} = \@links;
    }
    use Test::More "no_plan";
    say Dump(\%fin);
    say "There are: ".@main::links." links";
    is_deeply(\%fin, LoadFile("johnfahey.yml"), "John Fahey files discovered")
        || do {
            prompt_yN("Update test data?") && do {
                DumpFile("johnfahey.yml", \%fin);
                say "Updated";
            };
        };
}

sub ensure_intuitions_exist {
    my $self = shift;
    return if $self->linked("Intuition");
# here we generate some intuitions and their matches 
# {{{
    my $int_data = LoadFile("intuition_data.yml");
    for my $intt (@$int_data) {
        my $match = delete $intt->{match} || die "Urph: ". Dump($intt);
        $match = new Pattern(%$match);
        
        my $cog = delete $intt->{cog};
        $intt->{cog} = qr"$cog->{regex}" if $cog->{regex};
        $intt->{cog} = eval " sub {$cog->{code}} " if $cog->{code};
        die $@ if $@;

        my $int = new Stuff('Intuition', %$intt);
        $int->link($match);
        $int->link($self);
    }
# }}}
}

1;
