use strict;
use warnings;
use 5.008004;
use ExtUtils::MakeMaker;

WriteMakefile(
  NAME             => 'HEXONET',
  VERSION_FROM     => 'lib/HEXONET/hexonet.pm',
  ABSTRACT_FROM    => 'lib/HEXONET/hexonet.pm',
  AUTHOR           => 'HEXONET GmbH',
  LICENSE          => 'MIT',
  MIN_PERL_VERSION => '5.008004',
  EXE_FILES        => [],
  PREREQ_PM        => {
    'strict'   => 1,
    'warnings' => 1,
  },
  (eval { ExtUtils::MakeMaker->VERSION(6.46) } ? (META_MERGE => {
      'meta-spec' => { version => 2 },
      resources => {
          repository => {
              type => 'git',
              url  => 'https://github.com/hexonet/perl-sdk',
              web  => 'https://www.hexonet.net',
          },
      }})
   : ()
  ),
);