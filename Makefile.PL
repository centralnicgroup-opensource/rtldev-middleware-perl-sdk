use 5.026000;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME          => 'WebService::Hexonet::Connector',
    VERSION_FROM  => 'lib/WebService/Hexonet/Connector.pm',
    PREREQ_PM     => { 'LWP::UserAgent' => 6.35 },
    ABSTRACT_FROM => 'lib/WebService/Hexonet/Connector.pm',
    AUTHOR        => 'hexonet <middleware@hexonet.net>',
    LICENSE       => 'mit'
);
