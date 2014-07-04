package Codo;
use Mojo::Base 'Mojolicious::Controller';
use Mojo::ByteStream;
use Scriptalicious;
use YAML::Syck;
use Texty;
use Codon;
use Proc;
use utf8 'all';
=pod

Devel::ebug interface
slurpy other programs

Codo is for ghosting ghosts.
fishing around in the void.
flip through stuff.
so you can say, go here, what's this, watch this, find the pathway of its whole existence

context richness.

form.

and then they build 1s as Codons (genetic model for something like a travel/ghost/wormhole coupling)
where layers can be injected in space anywhere without breaking the fabric of it
right now time is not something we can flop out anywhere, depending on what we're going for
take that morality

=cut
our $H;
sub ddump { Hostinfo::ddump(@_) }
has 'ports' => sub { {} };
has 'ebuge' => sub { [] };
has 'output';
use Mojo::UserAgent;
use JSON::XS;
use File::Slurp;
sub new {
    my $self = bless {}, shift;
    shift->($self);

    $self->{git} = $H->getapp("Git");
    my $cd = $self->{git}->rbe("down");
    $cd = "../$cd/";
    die "No code dir: $cd" unless -d $cd;
    $self->{code_dir} = $cd;

    my $codoback = "3366FF"; #"001452"
    my $Codo =
    $H->{ground}->spawn_floozy($self, Codo => "width:58%; min-width: 600px; background: #$codoback; color: #afc; position: absolute;"
    ." z-index:4; opacity: 0.95; height: 100%;"
    ."overflow: scroll;", before => 'flood');

    $Codo->spawn_ceiling($self, 'codseal' => 'border: 1px solid beige;');
    $H->{flood}->spawn_floozy($self, codolist =>
        "padding: 1em; width:100%; z-index:3; background: #402a35; color: #afc; opacity: 1; hegith: 8em;");


    $Codo->spawn_floozy($self, blabs => "width:100%;  background: #301a30; color: #afc; font-weight: bold; height: 2em;");


    $self->init_codons();

    $self->codolist();

    my $ao = $self->{all_open} = [];
    $self->re_openness();

    $self->load_codon("Lyrico") unless @$ao;

    return $self;
}
sub menu {
    my $self = shift;
    my $m = $self->{menu} ||= [
        ܤ => sub { # they might wanna load new css/js too
            $H->error('restarting');
            `touch $0`;
        },
        ɤ => sub {
            $self->nah;
            $H->timer(4, sub { Codo->new($H->intro) });
        },
        Ꮉ => sub {
            $H->JS("\$('#mess').toggleClass('widdle').animate({'max-width': '39%'});");
        },
        '≲' => sub {
            $H->JS("\$('#splatselves').toggleClass('widdle');");
        },
    ];
    return { _spawn => [ [], {
        event => { menu => $m },
        tuxtstyle => "padding 5px; font-size: 35pt; "
            ." background-color: #1919FF;"
            ."text-shadow: 2px 4px 5px #4C0000;"
    } ] }
}
sub event {
    my $self = shift;
    my $event = shift;
    my $id = $event->{id};

    $H->info("Co do no e", $event);
}
sub init_codons {
    my $self = shift;

    say "\tI N I T   C O D ON S !";
    my @codefiles = $self->codefiles();

    for my $cf (@codefiles) {
        my $filename = $self->{code_dir}.$cf;
        my $codon = $self->codon_by_filename($filename);
        my $isnew = 1 if !$codon;

        my $mtime = (stat $filename)[9];

            if ($isnew) {
                $codon = new Codon($H->intro, {
                    filename => $filename,
                    codo => $self,
                });
            }

        if ($codon->{mtime} < $mtime) {
            say "$cf changed";
            $codon->{mtime} = $mtime;
            $isnew = 1;
        }
    }
}
sub codefiles {
    my $self = shift;

        my $dir = $self->{code_dir} || "";
        die "$dir not dir" unless -d $dir;
        $dir .= "/" unless $dir =~ /\/$/;
    
    map { Hostinfo::decode_utf8($_) }
        grep { !$dir || s/^$dir// } (
            glob($dir.'stylehouse.*'),
            glob($dir.'lib/*.pm'),
            glob($dir.'ghosts/*/*'),
        );
}
sub codolist {
    my $self = shift;

    my $codons = [$self->get_codons];
    die "no codons" unless $codons;
    say "Codons number ".@$codons;
    my $list = $self->{codolist};
    my $listy = $list->text;
    
    my $m = {
        h => sub {
            my ($ev, $s) = @_;
            my $codon = $s->{codon};
            return $self->{hostinfo}->error("No Codon attached to", $s)
                unless $codon;
            $self->load_codon($codon->{name});
        },
        ѷ => sub {
            $list->float();
        },
        ɷ => sub {
            $_->away for @{ $self->{all_open} };
        },
        ʚ => sub {
            $_->save_all("Collapse") for @{ $self->{all_open} };
        },
        ʗ => sub {
            $_->save_all for @{ $self->{all_open} };
        },
        Ш => sub {
            $self->{hostinfo}->JS(
                "\$.scrollTo(\$('#ground').offset().top, 360);"
                ."\$('#ground').scrollTo(\$('#self->{Codo}->{divid}').position().top, 360);"
                #."\$('#$self->{Codo}->{divid}').scrollTo(\$('#$codon->{show}->{divid}').offset().top, 360);"
            );
        },
        ƾ => sub {
            `rm Codo-openness.yml`;
            $self->{hostinfo}->info("deleted openness savefile");
        },
    };
    
    
    my @coli;
    my $coname = { map { $_->{name} => $_ } @$codons };
    for my $n (qw'stylehouse.pl stylehouse.js stylehouse.css',
               qw'Codo Codon Direction',
               qw'Travel Ghost Wormhole Lyrico Texty View') {

        push @coli, delete $coname->{$n} if $coname->{$n};
    }
    push @coli, values $coname;
    
    $listy->add_hooks({nospace => 1, class => 'menu'});
    $listy->replace([
    { _spawn => [ [ sort keys %$m ], {
        event => { menu => $m },
        nospace => 1,
        class => 'menu',
        style => 'border: 3px solid #bb3333;',
        tuxtstyle => "opacity: 0.9; padding-bottom: 2px; "
            ."color: #99FF66; font-size: 29pt; background-color: #FF5050; font-weight: 700; "
            ."text-shadow: 2px 4px 5px #4C0000;",
        
    } ] },
    { _spawn => [ [ @coli ], {
        event => sub { $m->{h}->(@_) },
        nospace => 1,
        class => 'menu',
        tuxtstyle => sub {
            my ($codon, $s) = @_;

            $s->{value} = $codon->{name};
            $s->{codon} = $codon;

            $s->{style} .= length($s->{value}) < 4 ?
                "font-size: 50pt;" : "font-size: 20pt;";

            $s->{menu} = "h";
            
            $s->{style} .= "opacity: 0.9; padding-bottom: 2px;"
                ." color: #99FF66; font-weight: 700;"
                ." text-shadow: 2px 4px 5px #4C0000;";
                            
            $s->{style} .= 'background-color:'
                .'#'.codoncolour($codon).';';
            
            $s->{style} .= 'color: #5A5AAF;'
                if $codon->{is}->{G};
            return undef;
        },
    } ] },
    ]);
}
sub codoncolour {
    my $codon = shift;
    my $n = $codon->{name};

    $n =~ /^ghost/ ? "99FF66" :
    $n =~ /Travel|Ghost|Wormhole/ ? "990906" :
    $n =~ /Texty/ ? "00FFFF" :
    $n =~ /View|Lyrico/ ? "CCFF66" :
    $n =~ /Hostinfo/ ? "3366FF" :
    $n =~ /Codo/ ? "3366FF" :
    $n =~ /Codon/ ? "3366FF" :
    $n =~ /stylehouse/ ? "00CCFF" :
    $n =~ /stylehouse\.pl/ ? "33CDDD" :
    $n =~ /Codon/ ? "3366FF" :
    "B8B86E"
}
sub re_openness {
    my $self = shift;

    my $codopenyl = "Codo-openness.yml";
    my $open = LoadFile($codopenyl) if -e $codopenyl;
    for my $o (@$open) {
        my ($name, $ope) = @$o;
        while (my ($k, $v) = each %$ope) {
            if ($v eq "Open") {
                $ope->{$k} = 'Opening';
            }
        }
        say "Ressur $name";
        $self->load_codon($name, $ope, "noscrolly");
    }
}
sub mind_openness {
    my $self = shift;
    my $codon = shift;

    if ($codon) {
        my $menut = $self->find_codolist_tuxt($codon);
        
        if ($menut) {
            $self->{hostinfo}->send(
                "\$('#$menut->{id}').addClass('onn');"
            );
        }
    }

    if ($codon && !grep { $_ eq $codon } @{$self->{all_open}}) {
        say "Codon minded: $codon->{name}";
        push @{$self->{all_open}}, $codon;
    }

    my @saveopen = map {
        [ $_->{name} => $_->{openness} ]
    } grep { defined $_ } @{$self->{all_open}};

    DumpFile("Codo-openness.yml", \@saveopen);
}
sub find_codolist_tuxt {
    my $self = shift;
    my $codon = shift;
    my $codlt = $self->{codolist}->{text};

    my $menut;
    for my $clt (@{ $codlt->{tuxts} }) {
        for my $cltt (@{ $clt->{value}->{tuxts} }) {
            $menut = $cltt
                if $cltt->{codon}
                && $cltt->{codon} eq $codon;
            last if $menut;
        }
        last if $menut;
    }
    unless ($menut) {
        $self->{hostinfo}->error("Non findo $codon->{name} in codolist");
    }
    return $menut;
}
sub lobo {
    my $self = shift;
    my $codon = shift;
    
    @{$self->{all_open}} =
        grep { $_ ne $codon } @{$self->{all_open}};
        
    $self->mind_openness();
    
    my ($menut) = $self->find_codolist_tuxt($codon);
    if ($menut) {
          $self->{hostinfo}->send(
              "\$('#$menut->{id}').removeClass('onn');"
          );
    }
}

sub load_codon {
    my $self = shift;
    my $codon = shift;
    my $ope = shift;
    my $noscrolly = shift;

    ($codon) = $self->codon_by_name($codon) unless ref $codon;
    return $self->{hostinfo}->error("Can't load codon: $codon") unless $codon;
    say "Codo load $codon->{name}";
    $codon || die;
    
    say "OPen Codons: ".join", ", map { $_->{name} } @{$self->{all_open}};
    unless (grep { $_ eq $codon } @{$self->{all_open}}) {
        $codon->display($self, $ope);
        $self->mind_openness($codon);
    }
    $self->{hostinfo}->send(
    "\$('#$self->{Codo}->{divid}').scrollTo(\$('#$codon->{show}->{divid}'), 360);"
    ." \$('#$codon->{show}->{text}->{id}-Head').fadeOut(300).fadeIn(500);"
    ) unless $noscrolly;
}
sub codon_by_name {
    my $self = shift;
    my $name = shift;
    my @codons;
    for my $c ($self->get_codons()) {
        push @codons, $c if $c->{name} eq $name
    }
    return @codons;
}
sub codon_by_filename {
    my $self = shift;
    my $filename = shift;
    my @codons;    
    for my $c ($self->get_codons()) {
        push @codons, $c if $c->{filename} eq $filename
    }
    return @codons;
}
sub get_codons {
    my $self = shift;
    my $codons = $H->get('Codon');
    return @$codons if $codons;
    return ();
}
sub readfile {
    my $self = shift;
    my $path = shift;
    $self->{hostinfo}->slurp($self->{code_dir}.$path);
}
sub writefile {
    my $self = shift;
    my $path = shift;
    $self->{hostinfo}->spurt($self->{code_dir}.$path, shift);
}
sub random_colour_background {
    my ($rgb) = join", ", map int rand 255, 1 .. 3;
    return "background: rgb($rgb);";
}



sub proc_killed {
    my $self = shift;
    my $proc = shift;
    delete $self->{$proc->{name}};
    $self->{codostate}->text->replace(["!html <h4>styleshed killed</h4>"]);
}
sub nah {
    my $self = shift;
    $H->nah($self);
}
sub DESTROY {
    my $self = shift;
    for my $ebuge (@{ $self->ebuge }) {
        unless ($ebuge) {
            say "weird, no ebuge...";
            next;
        }
        $ebuge->nah;
    }
    $self->ebuge([]);
}
sub new_ebuge {
    my $self = shift;
    my $ebuge = Ebuge->new($H->intro, "ebuge.pl");
    push @{ $self->ebuge }, $ebuge;
    return $ebuge;
}
1;

