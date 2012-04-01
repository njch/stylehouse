#!/usr/bin/perl

# programmable graph traversal!?

# trav -> scans
# scan -> compares
# compare progresses pattern

sub make_code {
    my $rule = shift;
    # either linked thing in $tree already, attach there
    
    my @tree = map { [ $_ ] } split " ", $rule;

    my $c = {
        "linked thing" => '$l->{1}',
        "in .+? already" => [
            "! search ? for <<",
        ],
    };

    my $data2pattern = sub {
        return { d => shift };
    };
    my $compare;
    my $scan = sub {
        my $pattern = shift;
        my @tree = @{$_[0]};

        for my $i (0..@tree-1) {
            for my $t (0..@$pattern-1) {
                $compare->($tree[$i+$t]->[0], $pattern->[$t]->[0])
                    || last;
                if ($t == @$pattern-1) {
                    return {
                        range => [$i, $i+$t],
                        found => [ @tree[$i..$i+$t] ],
                    }
                }
            }
        }
        return undef;
    };
    $compare = sub {
        my ($pat, $real) = @_;
        my $pt = ref $pat || "STRING";
        my $rt = ref $real || "STRING";
        say "compare $pt <> $rt";
        if ($pt eq "ARRAY" && $rt eq "ARRAY") {

            return $scan->($pat, $real);
        }
        elsif ($pt eq "STRING" && $rt eq "STRING") {
            return $pat eq $real;
        }
        else {
            die "unknown compare!";
        }
    };
    my $trav = sub {
        my $source = shift;
        my $spec = shift;
        my $pattern = shift;
        $spec =~ /^look (across|along|through) for( sequence)?/;
        my $recursion_method = $1;
        $pattern = $data2pattern->($pattern);
        $pattern->{sequence} = 1 if $2;
        my @pointer;
        my $next = sub {
            if ($recursion_method eq "") {
            }
        };
    };

# ArraySubset
# ArraySlice - sequence

# found objects are at vectors across the graph

    while (my ($s, $b) = each %$c) {
        my $r = $trav->(
            \@tree,
            "look along for sequence", 
            [ map { [$_] } split " ", $_[0] ],
        );
        #my $r = $compare->($s2pattern->($s), \@tree);
        # my $r = $scan->($s2pattern->($s));

        $r or die;
        # squish results
        my $found = $r->{found};
        if (@$found > 1) {
            $found->[0]->[0] = join " ", map { $_->[0] } @$found;
            $found = $found->[0];
            my $range = $r->{range};
            @tree = (@tree[0..$range->[0]], @tree[$range->[1]+1..@tree-1]);
        }

        say Dump(\@tree);
        say Dump($found);
        exit;
    }


    my @junk;

    while (my ($s, $b) = each %$c) {
        my @found = $scan->();
        if ($rule =~ /$s/) {
            if (ref $b eq "ARRAY") {
                for my $r (@$b) {
                    if (my ($c) = $r =~ /^> (.+)$/) {
                        if ($c =~ m{^s/(.+)/(.+)/$}) {
                            $rule =~ s{(?<=$s)$1}{$2};
                        }
                        else { die }
                    }
                    elsif ($r =~ /^!/) {
                        push @junk, { act => $r }
                    }
                    else { die }
                }
            }
            else {
                push @junk, { data => $b };
            }
        }
    }
    say Dump(\@junk);

}
