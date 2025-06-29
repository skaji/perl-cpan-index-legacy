#!/usr/bin/env perl
use v5.40;

use File::Path ();
use JSON::XS ();
use Path::Tiny ();

my %spec = (
    "5.8.1" => {
        'CPAN::Meta::Requirements' => '2.140', # v5.10
        'Data::OptList' => '0.113', # v5.12
        'ExtUtils::ParseXS' => '3.51', # v5.8.3
        'Getopt::Long::Descriptive' => '0.105', # v5.12
        'HTML::Tagset' => '3.20', # v5.10
        'IO::Socket::IP' => '0.41', # 5.14
        'Plack' => '1.0050', # v5.12
        'Pod::Man' => '4.14', # v5.12
        'Pod::Text' => '4.14', # v5.12
        'Socket' => '2.032', # undefined symbol: SvRV_set
        'String::RewritePrefix' => '0.008', # v5.12
        'Sub::Exporter' => '0.990', # v5.12
        'Sub::Exporter::Util' => '0.990', # v5.12
        'Test::Deep' => '1.130', # v5.12
    },
    "5.10.1" => {
        'Data::OptList' => '0.113', # v5.12
        'Getopt::Long::Descriptive' => '0.109', # v5.12
        'IO::Socket::IP' => '0.41', # 5.14
        'Plack' => '1.0050', # v5.12
        'Pod::Man' => '5.01', # v5.12
        'Pod::Text' => '5.01', # v5.12
        'String::RewritePrefix' => '0.008', # v5.12
        'Sub::Exporter' => '0.990', # v5.12
        'Sub::Exporter::Util' => '0.990', # v5.12
        'Test::Deep' => '1.130', # v5.12
    },
);

my sub run (@cmd) { warn "---> @cmd\n"; 0 == system @cmd or die }

for my ($version, $spec) (%spec) {
    my $local_lib = "local-$version";

    File::Path::remove_tree $local_lib;

    my $fixed = join ",", map { sprintf '%s@%s', $_, $spec->{$_} } sort keys $spec->%*;
    run "cpm",
        "install",
        "-L", $local_lib,
        "--target-perl", $version,
        "--resolver", "Fixed,$fixed",
        (sort keys $spec->%*);

    my $include = join ",", sort keys $spec->%*;
    run "perl-cpan-index-generate",
        "--output", "../$version.txt",
        "--include", $include,
        "$local_lib/lib/perl5";
}
