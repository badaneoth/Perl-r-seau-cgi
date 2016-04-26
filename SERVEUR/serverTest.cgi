#!C:\wamp\bin\perl\bin\perl.exe
use strict;
use IO::Socket;
use IO::Socket::INET;
use Win32::Registry;
use Win32::Shortcut;
use Hash::Diff qw( diff );
use File::Basename;
use File::Copy::Recursive qw(dircopy);
use File::Copy qw(copy);
use CGI;
use Sys::Hostname;


my $cgi = new CGI;
my $buffer = $cgi->param('elementId');
my $sub = $cgi->param('Submit');

my $chemin = $cgi->param('chem');
#print "Content-type: text/html\n\n";


#Liste des IP clients qui se connectent au serveur
my @ListeIpClients =();

my($newmsg, $serverdata,$sock,$socket, $msg, $port, $ipaddr, $hishost,$clientsocket,$clientdata,
   $MAXLEN, $PORTNO, $TIMEOUT);
   
my $sock = new IO::Socket::INET(
	PeerAddr => '255.255.255.255',
	PeerPort => '5151', # Port the udp server listens on
	Proto => 'udp',
	Broadcast => 1 # Not sure if this is needed, I know the sockopt is
	) || die "[ERROR] $!\n";
	$sock->sockopt(SO_BROADCAST, 1);
	 $serverdata =$cgi->param('elementId');
  
  #ON LUI ENVOI LE NOM DU PACKET qu'on choisit dans l'interface
	if($sub eq "DEPLOYER"){
		print $sock $serverdata."-install";
	}
	elsif($sub eq "DESINSTALLER"){
		print $sock $serverdata."-uninstall";
	}
	elsif($sub eq "COPIER"){
		print "$chemin,$buffer";
		$buffer="pack/".$buffer;
		ecrireChemin($chemin,$buffer);
		print $sock $serverdata."-copy";
	}
	$sock->close();

print $cgi->redirect('deploiement.php');


sub ecrireChemin{
	
	my($chemin,$logiciel)=@_;
	
	my @tab = split(/\./,$logiciel);
	
	$logiciel=shift @tab;
	
	open(AJOUT,">".$logiciel.".txt") || die ("Erreur d'ouverture $logiciel") ;
	
	print AJOUT $chemin;

	close(AJOUT);


}

 