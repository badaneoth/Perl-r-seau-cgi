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

#Notre incroyable méthode qui transforme du texte     

sub change     
{
	my ($self) = shift;     

	my( $sock,$socket,$clientsocket,$clientdata);
	   
	 $sock = new IO::Socket::INET(
		PeerAddr => '255.255.255.255',
		PeerPort => '5151', # Port the udp server listens on
		Proto => 'udp',
		Broadcast => 1 # Not sure if this is needed, I know the sockopt is
		) || die "[ERROR] $!\n";
		$sock->sockopt(SO_BROADCAST, 1);
		print $sock "T'es chaud pour installer un logiciel ?\n";


	$sock->close();


	$socket = new IO::Socket::INET (
			LocalPort => '4000',
			Proto => 'tcp',
			Listen => 10,
			Reuse => 1
			) or die "Oops2: $! \n";

	$clientsocket = $socket->accept();

	
	# lire les données du client
	
	$clientdata = <$clientsocket>;
	my $ipClient = $clientsocket->peerhost();

	my $hishost = $clientsocket->peername();
	
	 
	$self->sendResultToClient($socket->sockname().":".$ipClient);     
}     

1;     

## Début du script perl ##     

my $ajax = Ajax->new();     

$ajax->change();     