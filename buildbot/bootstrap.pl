#!/usr/bin/perl
# vim: set ts=2 sw=2 tw=99 noet: 

use strict;
use Cwd;
use File::Basename;
use File::Path;

my ($myself, $path) = fileparse($0);
chdir($path);

require 'helpers.pm';

#Go back above build dir
chdir(Build::PathFormat('../..'));

#Get the source path.
our ($root) = getcwd();

my $reconf = 0;

if ($^O eq "darwin") {
	$ENV{'HL2SDKND'} = '/Volumes/hgshare/hl2sdk-nucleardawn';
	$ENV{'HL2SDK2013'} = '/Volumes/hgshare/hl2sdk-sdk2013';
	$ENV{'HL2SDKINSURGENCY'} = '/Volumes/hgshare/hl2sdk-insurgency';
}

#Create output folder if it doesn't exist.
if (!(-d 'OUTPUT')) {
	$reconf = 1;
} else {
	if (-f 'OUTPUT/sentinel') {
		my @s = stat('OUTPUT/sentinel');
		my $mtime = $s[9];
		my @files = ('build/pushbuild.txt', 'build/AMBuildScript', 'build/product.version');
		my ($i);
		for ($i = 0; $i <= $#files; $i++) {
			if (IsNewer($files[$i], $mtime)) {
				$reconf = 1;
				last;
			}
		}
	} else {
		$reconf = 1;
	}
}

if ($reconf) {
	rmtree('OUTPUT');
	mkdir('OUTPUT') or die("Failed to create output folder: $!\n");
	chdir('OUTPUT');
	my ($result);
	print "Attempting to reconfigure...\n";
	if ($^O eq "linux") {
		$result = `CC=gcc CXX=gcc python3 ../build/configure.py --enable-optimize`;
	} elsif ($^O eq "darwin") {
		$result = `CC=clang CXX=clang python3 ../build/configure.py --enable-optimize`;
	} else {
		$result = `C:\\Python31\\Python.exe ..\\build\\configure.py --enable-optimize`;
	}
	print "$result\n";
	if ($? != 0) {
		die('Could not configure!');
	}
	open(FILE, '>sentinel');
	print FILE "this is nothing.\n";
	close(FILE);
}

sub IsNewer
{
	my ($file, $time) = (@_);

	my @s = stat($file);
	my $mtime = $s[9];
	return $mtime > $time;
}

exit(0);


