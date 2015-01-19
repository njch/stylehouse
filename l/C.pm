package C;
our $H;
use strict;
use warnings;
use utf8;
use lib 'lib';
use feature 'say';
use YAML::Syck;
$YAML::Syck::ImplicitUnicode = 1;

sub new {
    my $C = shift;
    $C->{G} = $C->{A}->fiu('G');
    die "waying non G : $C->{A}->{u}->{i}", $C, $C->{A} unless $C->{G} && ref $C->{G} eq "G";

    $C
}

sub pi {
    my $C = shift;
    my $some = "C ".$C->pint();
    if (length($some) < 6) {
        my $ki = G::ki($C);
        my ($wf) = $ki =~ s/(_wayfile\S+\s*)//;
        $ki = "$wf$ki" if $wf;
        $some .= " $ki";
    }
    $some
}

sub pint {
    my $C = shift;
    my $K = $C->{K};

    my $p;
    $p = eval { $C->{G}->w(print => {}, $C); }
        if (defined $C->{print} || $C->{Gw}) && G::wish(G=>$C->{G});
    $@ = "" if $@;

    $p = $C->{B}->{name} if $C->{B}->{name};

    if ($C->{name} eq 'D') {
        $p = $C->{G}->pi." $C->{K} $C->{point} % ".join' ', sort keys %{$C->{ar}};
    }

    my $B;
    if ($C->{B} && !$p) {
        if (join(",", sort keys %{$C->{B}}) eq "Lu,ui") {
            $B = "ui=(".$C->{B}->{ui}->pint();
        }
        $B ||= G::slim(50,30,G::ki($C->{B}))        
    } 
    my $s = "$K↯$p".($B?"↯$B":"");
    return $s;
}

sub send {
    my $C = shift;
    my ($m, $cb) = @_;
    my $Elvis = $C;
    $H->{G} ->w("send_Elvis", {m => $m, cb => $cb, Elvis => $Elvis});
}

sub s {
    my $C = shift;
    my $s = $C->{A}->spawn("C");
    $s->from({@_}) if @_;
    $s
}

sub spawn {
    my $C = shift;
    my $from = shift || $C;
    my $u = $C->{G}->nw();
    $u->from($from);
    $u;
}

sub name {
    my $C = shift;
    $C->{name} = shift;
    $C;
}

sub init_way {
    my $C = shift;
    my $d = shift;

    # merge the ways into us
    for my $i (keys %$d) {
        $C->{$i} = $d->{$i};
    }
    # TODO should be in G or so as we thrust down many ways to here
    # leveridge A into way
    if (my $i = $C->{Oi}) {
        $i->{includome} || die"?";
        for my $Dome (split ' ', $i->{includome}) {
            my $CDs = $C->s->load("ghosts/$Dome")->{Ds} || die "no domes in $Dome";
            push @{$C->{Ds}}, @$CDs;
        }
    }
    for my $d ("dials") {
        next unless $C->{$d};
        while (my ($k, $v) = each %{$C->{$d}}) {
            $C->{G}->{$k} = $v;
        }
    }
}

sub from {
    my $C = shift;
    my $s = shift;

    $C->dfrom({u=>$C, s=>$s});
    return $C;
}

sub dfrom {
    my $C = shift;
    my $a = shift;
    my $u = $a->{u};
    my $s = $a->{s};

    my $sk = {map{$_=>1}qw"uuid id G A T"};
    my $axi = ref $u ne "HASH"; # on ACGTR or so

    for my $k (keys %$s) {
        next if $axi && $sk->{$k};
        # Li or Lo? TODO gonerism and schemas dusly
        my $t = $u->{$k};
        my $f = $s->{$k};

        $f = { %$t, %$f } if $t && $f && $k =~ /^(B|S)$/;

        $u->{$k} = $f;
    }
    return $u;
}

sub load {
    my $C = shift;
    $C->{_wayfile} = shift if @_;
    $C->{_wayfile} || die;
    $C->load_file($C->{_wayfile});
    my $data = delete $C->{_wayfiledata}; # could hang, could come back
    $C->{name} ||= ($C->{_wayfile} =~ /ghosts\/(.+)/)[0] || $C->{_wayfile};
    $C->init_way($data);
    $C
}

sub load_file {
    my $C = shift;
    my $yamlfile = shift;
    die "no $C->{_wayfile} " unless $yamlfile;
    my $yaml = $H->slurp($yamlfile);
    my $w = eval { Load($yaml) };
    if ($@ || !$w || ref $w ne 'HASH' || $@) {
        say $@;
        my ($x, $y) = $@ =~
              /parser \(line (\d+), column -?(\d+)\)/;

        my @file = split "\n",  $yaml;
        my $xx = 1;
        my $vision = SYCK();
        for (@file) {
          if ($x - 8 < $xx && $xx < $x + 5) {
            if ($xx == $x) {
              $vision .= "HERE > $_\n";
              $vision .= "HERE > ".join("", (" ")x$y)."^\n";
            }
            else {
              $vision .= "       $_\n";
            }
          }
          $xx++;
        }
        die "! YAML load $yamlfile failed: "
        .($@ ? $@ : "got: ".($w || "~"))
        ."\n\n".$vision;
    }
    $C->{_wayfiledata} = $w;
}

sub SYCK {
    my $C = shift;
    <<'';
                                 _..._                   
                              .-'_..._''.                
                            .' .'      '.\    .          
           .-.          .- / .'             .'|          
            \ \        / /. '             .'  |          
             \ \      / / | |            <    |          
           _  \ \    / /  | |             |   | ____     
         .' |  \ \  / /   . '             |   | \ .'     
        .   | / \ `  /     \ '.          .|   |/  .       
      .'.'| |//  \  /       '. `._____.-'/|    /\  \     
    .'.'.-'  /   / /          `-.______ / |   |  \  \    
    .'   \_.'|`-' /                    `  '    \  \  \   
              '..'                       '------'  '---' 


    # etc
}

sub find {
    my $C = shift;
    my $point = shift;
    my @path = split /\/|\./, $point;
    my $h = $C->{hooks} || $C;
    $h = $C if @_; # as
    for my $p (@path) {
        $h = $h->{$p};
        unless ($h) {
            return undef;
        }
    }
    return $h
}

sub LioO {
    my $C = shift;
    my $O = shift;
    die "$C->{K} has no Li!" unless $C->{Li};
    my @a = G::findO($O => $C->{Li}->{o});
    wantarray ? @a : shift @a;
}

9;

