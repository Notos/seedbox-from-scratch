#!/usr/bin/perl

# Perl script to add rTorrent fast resume data to torrent files.
#
# Usage:
# rtorrent_fast_resume.pl [base-directory] < plain.torrent > with_fast_resume.torrent

use warnings;
use strict;

use Convert::Bencode qw(bencode bdecode);

$/=undef;
my $t = bdecode(scalar <STDIN>);

my $d = $ARGV[0];
die "$d is not a directory\n" if $d and not -d $d;
$d ||= ".";
$d .= "/" unless $d =~ m#/$#;

die "No info key.\n" unless ref $t eq "HASH" and exists $t->{info};
my $psize = $t->{info}{"piece length"} or die "No piece length key.\n";

my @files;
my $tsize = 0;
if (exists $t->{info}{files}) {
	print STDERR "Multi file torrent: $t->{info}{name}\n";
	for (@{$t->{info}{files}}) {
		push @files, join "/", $t->{info}{name},@{$_->{path}};
		$tsize += $_->{length};
	}
} else {
	print STDERR "Single file torrent: $t->{info}{name}\n";
	@files = ($t->{info}{name});
	$tsize = $t->{info}{length};
}
my $chunks = int(($tsize + $psize - 1) / $psize);
print STDERR "Total size: $tsize bytes; $chunks chunks; ", scalar @files, " files.\n";

die "Inconsistent piece information!\n" if $chunks*20 != length $t->{info}{pieces};

$t->{libtorrent_resume}{bitfield} = $chunks;
for (0..$#files) {
	die "$d$files[$_] not found.\n" unless -e "$d$files[$_]";
	my $mtime = (stat "$d$files[$_]")[9];
	$t->{libtorrent_resume}{files}[$_] = { priority => 2, mtime => $mtime };
};

print bencode $t;

