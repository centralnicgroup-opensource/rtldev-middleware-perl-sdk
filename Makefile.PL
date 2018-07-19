use 5.026000;
use ExtUtils::MakeMaker;

# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile(
	NAME              => 'HEXONET::apiconnector',
	VERSION_FROM      => 'lib/HEXONET/apiconnector.pm', # finds $VERSION, requires EU::MM from perl >= 5.5
	PREREQ_PM         => {}, # e.g., Module::Name => 1.1
	(
		$] >= 5.005
		?     ## Add these new keywords supported since 5.005
		  (
			ABSTRACT_FROM     => 'lib/HEXONET/apiconnector.pm', # retrieve abstract from module
			AUTHOR            => 'hexonet <middleware@hexonet.net>'
		  )
		: ()
	),
	LICENSE           => 'mit'
);
