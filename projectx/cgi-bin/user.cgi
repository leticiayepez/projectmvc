#!usr/bin/perl
use strict;
use lib '/var/www/html/projectx/kernel/modules';
use CGI::Carp qw(fatalsToBrowser);
use ManagerUser;
my $webapp = ManagerUser->new();
$webapp->cfg_file('../kernel/config/projectx.cfg');
$webapp->run();
