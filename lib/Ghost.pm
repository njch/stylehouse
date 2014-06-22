package Ghost;
use Mojo::Base 'Mojolicious::Controller';
use Scriptalicious;
use File::Slurp;
use JSON::XS;
use YAML::Syck;
use HTML::Entities;
use Way;
sub ddump { Hostinfo::ddump(@_) }

has 'hostinfo';
sub new {
    my $self = bless {}, shift;
    shift->($self);

    my $travel = shift;
    $self->{travel} = $travel;
    my $name = $self->{name} = $travel->{name};
    say "Ghost named $name";

    my @wayns = ("Travel", $name);
    push @wayns, $1 if $name =~ /^(\w+)-.+/;
    $self->load_ways(@wayns);

    return $self;
}
sub W {
    my $self = shift;
    $self->{wormhole} ||= Wormhole->new($self->hostinfo->intro, $self, "wormholes/$self->{name}/0");
}
sub load_ways {
    my $self = shift;
    my @wayns = @_;
    my $ows = $self->{ways} ||= [];
    
    for my $name (@wayns) {
        unless (-d "ghosts/$name") {
            say "Ghost ? $name"; # might be gone since last load, this all very additive
            next;
        }
        
        for my $file (glob "ghosts/$name/*") {
        
            my ($ow) = grep { $_->{file} eq $file } @$ows;
            
            if ($ow) {
                $ow->load_wayfile(); # and the top level hashkeys will not go away without restart
                say "Ghost U $ow->{id}: $file";

            }
            else {
                $ow = new Way($self->hostinfo->intro, $name, $file);
                
                say "Ghost + $ow->{id}: $file";
                push $ows, $ow;
            }
        }
        
        $self->{hostinfo}->watch_ghost_way($self, $name);
    }
    
    $self->hookways("load_ways_post");
}
sub ob {
    my $self = shift;
    $self->{travel}->ob(@_);
}

sub chains {
    my $self = shift;
    map { $_->{chains} ? @{ $_->{chains} } : () } @{ $self->{ways} }
}

sub w {
    my $self = shift;
    my $point = shift;
    my $ar = shift;
    my $wayspec = shift;

    # these might want to be a wormhole that travel mixes in
    # things gather along the spines
    # and be the big thing to do or a little thing to do
    # these stuff go together like that, hopefully, with language forming their surface tension
    # jelly pyramids...
    my @returns;
    for my $w (@{ $self->{ways} }) {
        next if $wayspec && $w ne $wayspec;
        my $h = $w->find($point);
        next unless $h;
            push @returns, [
                $self->doo($h, $ar, $point)
            ];
    }
    return say "Multiple returns from ".($point||'some?where')
                            if @returns > 1;    
    return 
                            if @returns < 1;
    my @return = @{$returns[0]};
    if (wantarray) {
        return @return
    }
    else {
        my $one = shift @return;
        return $one;
    }
}
sub doo {
    my $G = shift;
    my $eval = shift;
    my $ar = shift;
    my $point = shift;
    
    while ($eval =~ /(w (\$\w+ )?([\w\/]+)(:?[\(\{](.*?)[\}\)]|))/sg) {
        my ($old, $ghost, $way, $are) = ($1, $2, $3, $4);
        $ghost ||= '$G';
        $are =~ s/^\{(.+)\}$/({\%\$ar, $1})/;
        $eval =~ s/\Q$old\E/$ghost->w("$way", $are)/
            || die "Ca't replace $1\n"
            ." in\n".ind("E ", $eval);
    }
    
    my $thing = $G->{thing};
    my $O = $G->{travel}->{owner};
    my $H = $G->{hostinfo};
    
    my $download = join "", map { 'my $'.$_.' = $ar->{'.$_."};  " } keys %$ar if $ar;
    my $upload = join "", map { '$ar->{'.$_.'} = $'.$_.";  " } keys %$ar if $ar;
    
    my @return;
    my $evs = ($download||'')
        ."\n".' @return = (sub { '
        ."\n".$eval."\n".
        ' })->(); '."\n"
        .($upload||'');
    eval $evs;
    
    if ($@) {
        say $@;
        my ($x) = $@ =~ /line (\d+)\.$/;
        my $eval = "";
        my @eval = split "\n", $evs;
        my $xx = 1;
        for (@eval) {
            if ($x - 8 < $xx && $xx < $x + 5) {
                if ($xx == $x) {
                    $eval .= ind("Ͱ->", $_)."\n"
                }
                else {
                    $eval .= ind("|  ", $_)."\n"
                }
            }
            $xx++;
        }
        die "DOO Fuckup:\n"
            .(defined $point ? "point: $point\n" : "")
            ."args: ".join(", ", keys %$ar)."\n"
            .($@ !~ /DOO Fuckup/ ? $eval : "|")."\n"
            .ind("|   ", $@)."\n^\n";
    }
    # more ^
    
    return wantarray ? @return : shift @return;
}
sub enc { encode_entities(shift) }
sub ind { "$_[0]".join "\n$_[0]", split "\n", $_[1] }
sub haunt { # arrives through here
    my $self = shift;
    $self->{depth} = shift;
    $self->{t} = shift; # thing
    $self->{i} = shift; # way[] in
    $self->{last_state} = shift;
    $self->{o} = []; # way[] out
    $self->{T} = []; # traveling
    
    $self->ob($self);
    $self->w("arr");
    $self->ob($self);
    
    my $line = $self->W->continues($self); # %
    $self->ob($line);

    return ($line, $self->{o});
}
sub grep_chains {
    my $self = shift;
    my %s = @_;
    my @go;
    for my $c ($self->chains) {
        while (my ($k, $v) = each %s) {
            if ((!$k || exists $c->{$k}) && (!$v || $c->{$k} =~ $v)) {
                push @go, $c;
            }
        }
    }
    return @go;
}
sub event {
    my $self = shift;
    my $event = shift;
    #blah
}

1;

