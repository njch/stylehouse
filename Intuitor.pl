use strict;
use warnings;

new Flow(
name => "Intuitor", # {{{
want => new Pattern(object => "Text"),
be => sub {
    my $self = shift;
    my $it = shift;

    unless ($self->linked("Intuition")) {
# here we generate some intuitions and their matches 
# {{{
my @giv = split "\n", <<"";
string:
    /\// maybe filename
filename:
    /^\\.\\.//  probly relative
    /^(?!/)/ maybe relative
    /^//    probly absolute
    { -e shift } is reachable
relative or absolute
reachable filename:
    { -f shift } is file
    { -d shift } is dir
file or dir
file:
    { -r shift } is readable
    { (stat(shift))[7] } is size

sub shift_until { # TODO util functions
    my ($shift, $until) = @_;
    my @ret;
    until (!@$shift || $until->()) {
        push @ret, shift @$shift;
    }
    return @ret;
}

while (defined($_ = shift @giv)) {
    if (/^([\w ]+):/) {

        my $in_match = $1 eq "string" ?
            new Pattern(
                object => "Text"
            ) :
            new Pattern(
                object => "Intuition",
                names => [split /\s+/, $1]
            );

        my @ints = shift_until(\@giv, sub { $giv[0] =~ /^\S/ });

        for (@ints) {
            s/^\s+//;
            my $cog =
                s/^\/(.+)\/ // ? qr"$1" :
                s/^\{(.+)\} // ? eval "sub { $1 }" :
                die $_;
            my ($cer, $to) = /^\s*(\w+)\s+(\w+)$/;
            $cer && $to || die;
            my $int = new Stuff("Intuition",
#   name => "word", the word describing a positive intuition
#   cer => is|probly|maybe|slight, security of knowledge
#           greater arrangements made out of uncertainties should be upgraded
#   cog => regex or code->($_) to test
                name => $to,
                cer => $cer,
                cog => $cog,
            );
            $int->link($in_match);
            $int->link($self);
        }

    }
    elsif (/^([\w ]+)$/) {
        my @mutex = split / or / || die;
        # things that cannot be all true
        # should work like Intuitions except it projects LIES unto the
        # stuff that's wrong
    }
    else { die $_ }
}
# }}}
    }
    else {
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
is_deeply(\%fin, Load(johnfaheys()), "John Fahey files discovered");

}

sub johnfaheys {
    return <<''
--- 
../Music/Fahey/Death Chants, Breakdowns and Military Waltzes/Fahey, John - 04 - Some Summer Day.flac: 
  - Intuition	1	maybe filename	(?-xism:/)
  - Intuition	1	probly relative	(?-xism:^\.\./)
  - Intuition	1	maybe relative	(?-xism:^(?!/))
  - Intuition		probly absolute	(?-xism:^/)
  - Intuition	1	is reachable
  - Intuition	1	is file
  - Intuition	""	is dir
  - Intuition	1	is readable
  - Intuition	8115090	is size
../Music/Fahey/Death Chants, Breakdowns and Military Waltzes/Fahey, John - 08 - The Downfall Of The Adelphi Rolling Grist Meal.flac: 
  - Intuition	1	maybe filename	(?-xism:/)
  - Intuition	1	probly relative	(?-xism:^\.\./)
  - Intuition	1	maybe relative	(?-xism:^(?!/))
  - Intuition		probly absolute	(?-xism:^/)
  - Intuition	 	is reachable
../Music/Fahey/Death Chants, Breakdowns and Military Waltzes/Fahey, John - 08 - The Downfall Of The Adelphi Rolling Grist Mill.flac: 
  - Intuition	1	maybe filename	(?-xism:/)
  - Intuition	1	probly relative	(?-xism:^\.\./)
  - Intuition	1	maybe relative	(?-xism:^(?!/))
  - Intuition		probly absolute	(?-xism:^/)
  - Intuition	1	is reachable
  - Intuition	1	is file
  - Intuition	""	is dir
  - Intuition	1	is readable
  - Intuition	9056908	is size
/home/steve/Music/Fahey/Death Chants, Breakdowns and Military Waltzes/Fahey, John - 04 - Some Summer Day.flac: 
  - Intuition	1	maybe filename	(?-xism:/)
  - Intuition		probly relative	(?-xism:^\.\./)
  - Intuition		maybe relative	(?-xism:^(?!/))
  - Intuition	1	probly absolute	(?-xism:^/)
  - Intuition	1	is reachable
  - Intuition	1	is file
  - Intuition	""	is dir
  - Intuition	1	is readable
  - Intuition	8115090	is size


}

1;
