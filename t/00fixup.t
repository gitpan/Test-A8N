#!/usr/bin/env perl
use warnings;
use strict;

use Test::More tests => 5;
use File::Copy;
use File::Path;

my @files = (
    [ 't/cases/test__with__spaces.tc',          't/cases/test with spaces.tc'],
    [ 't/cases/System__Status',                 't/cases/System Status'],
    [ 't/cases/System Status/Basic__Status.tc', 't/cases/System Status/Basic Status.tc'],
);

foreach (@files) {
    my ($orig, $new) = @{ $_ };
    SKIP: {
        skip qq{"$new" exists}, 1 if (-e $new);
        ok(move($orig, $new), qq{rename "$new"});
    }
}

SKIP: {
    skip q{t/empty already exists}, 2 if (-d "t/empty");
    ok(mkpath(['t/empty']), q{mkdir t/empty});
    ok(-d "t/empty", q{t/empty exists});
}
