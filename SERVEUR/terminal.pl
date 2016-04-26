#!C:\wamp\bin\perl\bin\perl.exe
  
use warnings;     
use CGI;     
use IO::Socket;
use IO::Socket::INET;
use Win32::Registry;
use Win32::Shortcut;
use Hash::Diff qw( diff );
use File::Basename;
use File::Copy::Recursive qw(dircopy);
use File::Copy qw(copy);
use Sys::Hostname;


#system qw[ cmd.exe /c ], $^X, 'install.pl';
#system qw[ cmd.exe /c ];

#system('start cmd /k "cd c:\run_dir && perl hello.pl"');

system("start cmd.exe /k $cmd");