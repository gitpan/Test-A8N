use strict;
use warnings;
use lib qw(lib);
use Test::More;

eval "use Test::Pod::Coverage 1.08";
plan skip_all => 'Test::Pod::Coverage 1.08 required' if $@;
plan skip_all => 'set TEST_POD to enable this test' unless $ENV{TEST_POD};
plan skip_all => 'Coverage is currently broken';

all_pod_coverage_ok({
    also_private => [
        qr/(BUILD|DEMOLISH)/,
        qr/parse_(arguments|method_string)/,
    ]
});
