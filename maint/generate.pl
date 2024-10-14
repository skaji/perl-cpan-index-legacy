#!/usr/bin/env perl
use v5.40;

use File::Path ();
use JSON::XS ();
use Path::Tiny ();

my %spec = (
    "5.8.1" => {
        'CPAN::Meta::Requirements' => '2.140', # v5.10
        'Data::OptList' => '0.113', # v5.12
        'Getopt::Long::Descriptive' => '0.105', # v5.12
        'HTML::Tagset' => '3.20', # v5.10
        'IO::Socket::IP' => '0.41', # 5.14
        'Plack' => '1.0050', # v5.12
        'Pod::Man' => '4.14', # v5.12
        'Pod::Text' => '4.14', # v5.12
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

sub fixed_resolver ($spec) {
    join ",", "Fixed", map { sprintf '%s@%s', $_, $spec->{$_} } sort keys $spec->%*;
}

sub run (@cmd) {
    warn "---> @cmd\n";
    0 == system @cmd or die;
}

sub generate_index ($spec, $dir) {
    my @index;
    my $visit = sub ($path, $state) {
        return if $path !~ /install\.json$/;
        state $JSON = JSON::XS->new;
        my $install = $JSON->decode($path->slurp);
        my $need;
        for my $package (keys $install->{provides}->%*) {
            $spec->{$package} and $need++;
        }
        return if !$need;
        for my ($package, $option) ($install->{provides}->%*) {
            push @index, {
                package => $package,
                version => $option->{version},
                pathname => $install->{pathname},
            };
        }
    };
    Path::Tiny->new($dir)->visit($visit, { recurse => 1 });

    my $out = "";
    for my $index (sort { lc($a->{package}) cmp lc($b->{package}) } @index) {
        $out .= sprintf "%s %s %s\n",
            $index->{package}, $index->{version} || 'undef', $index->{pathname};
    }
    $out;
}


for my $version ("5.8.1", "5.10.1") {
    my $spec = $spec{$version};
    my $local_lib = "local-$version";

    File::Path::remove_tree $local_lib;

    run "cpm",
        "install",
        "-L", $local_lib,
        "--target-perl", $version,
        "--resolver", fixed_resolver($spec),
        (sort keys $spec->%*);

    my $file = "../$version.txt";
    warn "---> Writing $file\n";
    open my $fh, ">", $file or die;

    print {$fh} "# This is a CPAN index file for perl v$version\n";
    print {$fh} "\n";
    print {$fh} generate_index $spec, "$local_lib/lib/perl5";
}
