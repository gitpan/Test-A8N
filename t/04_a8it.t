#!/usr/bin/env perl

use strict;
use warnings;

use Test::More;
if (-f glob("~/.a8rc")) {
    plan(skip_all => "you can't run a8it unit tests if a ~/.a8rc file exists");
} else {
    plan(tests => 23);
}

my $a8it = "/usr/bin/env perl -Iblib -It/lib scripts/a8it %s 2>&1";
sub runcmd {
    my $cmd = sprintf($a8it, @_);
    return `$cmd`;
}
my $four_tests = <<EOF;
1..4
ok 1 - fixture1
ok 2 - fixture2
ok 3 - fixture3
ok 4 - fixture4
EOF
my $two_tests = <<EOF;
1..2
ok 1 - fixture1
ok 2 - fixture2
EOF

DashDash_help: {
    my $output;
    $output = runcmd("--help");
    ok($output =~ /^Usage:/s);
}

DashDash_file_root: {
    my $output;
    $output = runcmd("--file_root=t/empty");
    is($?, 0, "check error code");
    is($output, "", "expect empty output since no tests ran");

    $output = runcmd("--file_root=t/cases");
    is($?, 0, "check error code");
    like($output, qr/^1\.\.\d+/, "expect TAP output preamble for each file");
    is($output, $four_tests x 6 . $two_tests x 4, "check actual TAP output");

    $output = runcmd("--file_root=t/cases t/cases/test1.tc");
    is($?, 0, "single file: check error code");
    is($output, $four_tests, "single file: check actual TAP output");

    $output = runcmd("--file_root=t/cases t/cases/test1.tc t/cases/test_multiple.st");
    is($?, 0, "multiple files: check error code");
    is($output, $four_tests x 4, "multiple files: check actual TAP output");
}

DashDash_verbose: {
    my $output;
    my $start_1 = "# START: some_test_case_1\n";
    my $end_1 = "# FINISH: some_test_case_1\n";

    $output = runcmd("--file_root=t/cases -v t/cases/test1.tc");
    is($?, 0, "single verbose: check error code");
    is($output, $start_1 . $four_tests . $end_1, "single verbose: check actual TAP output");

    $output = runcmd("--file_root=t/cases -v -v t/cases/test1.tc");
    is($?, 0, "double verbose: check error code");
    is($output, <<EOF, "double verbose: check actual TAP output");
# Using fixture class "Fixture"
# START: some_test_case_1
1..4
# Fixture method fixture1
# Fixture method fixture2
# Fixture method fixture3
# Fixture method fixture4
# Fixture method fixture1
ok 1 - fixture1
# Fixture method fixture2
ok 2 - fixture2
# Fixture method fixture3
ok 3 - fixture3
# Fixture method fixture4
ok 4 - fixture4
# FINISH: some_test_case_1
EOF

    $output = runcmd("--file_root=t/cases -v -v -v t/cases/test1.tc");
    is($?, 0, "triple verbose: check error code");
    is($output, <<EOF, "triple verbose: check actual TAP output");
# Attempting to load fixture class Fixture
# Using fixture class "Fixture"
# START: some_test_case_1
1..4
# Fixture method fixture1
# Fixture method fixture2
# Fixture method fixture3
# Fixture method fixture4
# Fixture method fixture1
ok 1 - fixture1
# Fixture method fixture2
ok 2 - fixture2
# Fixture method fixture3
ok 3 - fixture3
# Fixture method fixture4
ok 4 - fixture4
# FINISH: some_test_case_1
EOF
}

DashDash_config: {
    my $output;
    $output = runcmd("--config=t/data/config1");
    is($?, 0, "check error code");
    is($output, "", "expect empty output since no tests ran");

    $output = runcmd("--config=t/data/config2");
    is($?, 0, "check error code");
    is($output, $four_tests x 6 . $two_tests x 4, "expect lots of TAP output");
}

SKIP: {
    skip "Running test cases with a shebang hangs for some reason", 3;
    Shebang: {
        my $filename = "t/cases/test_multiple.st";
        SKIP: {
            skip "test file is already executable", 1 if (-x $filename);
            chmod 0755, $filename;
            ok(-x $filename, "test file is executable");
        }

        my $output = `$filename 2>&1`;
        is($?, 0, "check error code");
        is($output, $four_tests x 3, "expect one test file worth of TAP output");
    }
}
