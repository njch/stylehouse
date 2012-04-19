use strict;
use warnings;

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
sub ensure_intuitions_exist {
    my $self = shift;
    return if $self->linked("Intuition");
# here we generate some intuitions and their matches 
# {{{
my $int_data = Load(<<'');
--- 
- 
  cer: maybe
  cog: { regex: / }
  match: 
    object: Text
  name: filename
- 
  cer: probly
  cog: { regex: "^\\.\\./" }
  match: &1 
    names: 
      - filename
    object: Intuition
  name: relative
- 
  cer: maybe
  cog: { regex: "^(?!/)" }
  match: *1
  name: relative
- 
  cer: probly
  cog: { regex: "^/" }
  match: *1
  name: absolute
- 
  cer: is
  cog: { code: " -e shift " }
  match: *1
  name: reachable
- 
  cer: is
  cog: { code: " -f shift " }
  match: &2 
    names: 
      - reachable
      - filename
    object: Intuition
  name: file
- 
  cer: is
  cog: { code: " -d shift " }
  match: *2
  name: dir
- 
  cer: is
  cog: { code: " -r shift " }
  match: &3 
    names: 
      - file
    object: Intuition
  name: readable
- 
  cer: is
  cog: { code: " (stat(shift))[7] " }
  match: *3
  name: size

for my $intt (@$int_data) {
    my $match = delete $intt->{match};
    $match = $match->{it} ||= new Pattern(%$match);
    
    my $cog = delete $intt->{cog};
    $intt->{cog} = qr"$cog->{regex}" if $cog->{regex};
    $intt->{cog} = eval " sub {$cog->{code}} " if $cog->{code};
    die $@ if $@;

    my $int = new Stuff('Intuition', %$intt);
    $int->link($match);
    $int->link($self);
}
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
