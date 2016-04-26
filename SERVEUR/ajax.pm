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

#On crée notre objet qui initialise le CGI et crée une couche d'abstraction envoi/réception pour communiquer avec notre client    

package Ajax;     

#Constructeur de la classe Ajax    

sub new     
{     
 my($classe) = shift;     
      
 my $self = {};     

 bless($self, $classe);     
      
 $self->{CGI} = CGI->new();     
      
 print $self->{CGI}->header('text/html;charset=UTF-8;');     
      
 return $self;     
}     

#Méthode qui nous permet de recevoir les données du client et les renvoit sous forme de tableau     

sub getDataFromClient     
{     
 my ($self) = shift;     
my @tab =  $self->{CGI}->param("keywords");
	my $logiciel=shift @tab;
	
	foreach my $val(@tab){
		$logiciel=$logiciel." ".$val;
	}
 
 return $logiciel;  
}     

#Méthode qui envoit des données au client     

sub sendResultToClient     
{     
 my ($self, $data_to_send) = @_;     
      
 print $data_to_send;     

}     

#Notre incroyable méthode qui transforme du texte     

sub change     
{
	my ($self) = shift;     
	
	my $val=$self->getDataFromClient();
	$self->sendResultToClient($val);     
}     

1;     

## Début du script perl ##     

#my $ajax = Ajax->new();     

#$ajax->change();     