#!/usr/bin/perl 
#use warnings; 
use strict; 
use File::Basename;
use File::Copy::Recursive qw(dircopy fcopy);
use File::Copy qw(copy);
use File::Path;
use strict;
use IO::Socket;
use IO::Socket::INET;

	my (@rec,$chemin,$monPack,$dossier,$nomMachine);
	
	
	while(1){
		
		communicationReseau();
	
		# $monPack='\\\\ILI14-PC\\www\\cgi-bin\\pack\\'.$rec[0];
		$monPack='C:/wamp/www/cgi-bin/pack'.$rec[0];
		$dossier="pack\\".$rec[0];
		print ">>>>$monPack\n";
	
		
		print ">>>>$monPack\n";
		
		print "$monPack\n";

		$nomMachine=nom_machine();
		
		if($rec[1] eq "install"){
			
			importer();
			installation();
		}
		elsif($rec[1] eq "uninstall"){
			desinstallation();
			supprimer_chemin($dossier);
		}
		elsif($rec[1] eq "copy"){
			copier($rec[2]);
		}	
	}
sub coupe{
	my ($fic)=@_;
	my @fic= split (/\./,$fic);
	$fic =shift @fic;
	
	return $fic;
}	
sub copier{
	
	my $cheminVers;
	
	#le logiciel
	fcopy($monPack,"pack/");
	my $install=coupe($dossier);
	my $partage=coupe($monPack);
	print "$partage\n";
	fcopy($partage.".txt","pack/");
	open(my $fd,"<".$install."txt") or die"open: $!";
		my($line);
		while( defined( $line = <$fd> ) ) {
			$cheminVers=$line;	
		}
	close($fd);
	copy($dossier,$cheminVers) or die("Impossible dans le dossier pack $!");	

}
sub importer{
	if(-d $monPack){
		dircopy($monPack,$dossier) or die("Impossible dans le dossier pack $!");	
	}
	else {
		copy($monPack,$dossier)or die("Impossible de copier le fichier $monPack :  $!");
	}
}

sub communicationReseau {	

print "==============================================UDP================================================\n";

my($sock,$socket,$newmsg, $hishost, $MAXLEN, $PORTNO,$port,$ipaddr,$peer_addr , $serverdata , $clientdata);

$MAXLEN = 1024;
$PORTNO = 5151;

$sock = IO::Socket::INET->new(
           LocalPort => $PORTNO, 
	   Proto => 'udp') or die "socket: $@";
	   
print "En attente des messages UDP sur le port $PORTNO\n";

$sock->recv($newmsg, $MAXLEN);

    ($port, $ipaddr) = sockaddr_in($sock->peername);
    
	$hishost = gethostbyaddr($ipaddr,AF_INET);
	
	$peer_addr = inet_ntoa($ipaddr);
 
	print "Server IP : $peer_addr NOM : $hishost m a dit $newmsg\n";
	
	@rec= split(/-/, $newmsg);

	print "Je vais recevoir le pack mozilla à mettre dans mon PACK :  ".$rec[0]." \n";
	print "Et je dois : -".$rec[1]."-\n";


$sock->close();

}
sub mon_dir{
	my ($nom) = @_;
	my @nom=split(/\\/, $nom);
	
	my $logiciel1 = pop @nom;
	my $dir =shift (@nom);
	foreach my $dd(@nom){
		$dir=$dir."\\".$dd;
	}
	return $dir;
}
sub installation{

	#=========================================
	# Ce script client prend en argument le nom du logiciel a installer
	#=================================
	#1) On copie les fichiers dans programmes
	my $dos=$dossier."\\".$rec[0].".txt";
	
	print "llllllll :$dos\n";
	remplacer($dos,"ENV",$nomMachine);
	open(my $fd,"<".$dos) or die"open: $!";
		my($line);
		
	while( defined( $line = <$fd> ) ) {
	   $line =~ s/\n//g;#on enleve les \n
		print "####################$line\n";
		my @log; 
		my @log1;
		@log= split(/\\/, $line);
		
		my $fichier = pop @log;
		print ">>$fichier\n";
		#$line =~ s/ENV/NomMachine/g;
		
		my $lienFichierPack = $dossier."\\".$fichier;#le fichier dans notre dosssier pack
			
		#print "**LINE : $line\n";
		#print "**LINE : $line\n";
		if(-d $lienFichierPack){
			dircopy($lienFichierPack,$line) or die("111Impossible de copier le repp $!");	
		}
		elsif(-f $lienFichierPack){
			if(!-e $line){
				my $dir=mon_dir($line);
		
				fcopy($lienFichierPack,$dir);
			}
			
		}
	}
	close($fd);
	
	#2) On copie les registres
	

	my $fichierREG=$dossier."\\".$rec[0]."+.reg";
	remplacer($fichierREG,"ENV",$nomMachine);
	print "dossier :  $fichierREG \n";
	system 'regedit /s '."\"".$fichierREG."\"";
}
sub desinstallation{
	#supprimer les dossiers du logiciel

	my $dos=$dossier."\\".$rec[0].".txt";
	
	print "llllllll :$dos\n";
	remplacer($dos,"ENV",$nomMachine);
	open(my $fd,"<".$dos) or die"open: $!";
		my($line);
		
	while( defined( $line = <$fd> ) ) {
	   $line =~ s/\n//g;#on enleve les \n
		
		my @log; 
		my @log1;
		@log= split(/\\/, $line);
		my $fichier = pop @log;
		
		my $lienFichierPack = $dossier."\\".$fichier;#le fichier dans notre dosssier pack
			
		print "==>**LINE : $line\n";
		#SUPPRIMER le dossier $line	
		supprimer_chemin($line);
		#exit(1);
		#system 'rmdir '.$line.'/s /q';
	}
	close($fd);
	
	
	#supprimer les registres
	#system 'REG DELETE [nom de la clé]';
	my $fichierREG=$dossier."\\".$rec[0]."-.reg";
	remplacer($fichierREG,"ENV",$nomMachine);
	print "dossier :  $fichierREG \n";
	system 'regedit /s '."\"".$fichierREG."\"";
	
}
sub supprimer_chemin{
	my ($fic)=@_;
	if(-e $fic){
		if(-f $fic ){	
		#	print "--$k LIEN : $line\n";
			$fic =~ s/\\/\\\\/g;
			unlink $fic; # copier un repertoire
			print "-- LIEN FICHIER SUPPR: $fic\n";
		}
		elsif(-d $fic ){	
			if(rmtree([$fic], 1, 1)!=0)
			{
				print "Suppression de fichier $fic\n";
			}
		}
	}
}
sub nom_machine{
	my $machine = qx/hostname/; chomp($machine);
	my @nom = split (/-/,$machine);
	my $nom=shift @nom;
	#print "MACHINE = $nom\n"
	return $nom;
}
sub remplacer{
	my($fichier,$chaine1,$chaine2)=@_;
	my $donnees = lire_fichier($fichier);
	
	$donnees =~ s/$chaine1/$chaine2/g;
	ecrire_fichier($fichier, $donnees);

}

sub lire_fichier {
    my ($nom_de_fichier) = @_;

    open my $entree, '<:encoding(UTF-8)', $nom_de_fichier or die "Impossible d'ouvrir '$nom_de_fichier' en lecture : $!";
    local $/ = undef;
    my $tout = <$entree>;
    close $entree;

    return $tout;
}

sub ecrire_fichier {
    my ($nom_de_fichier, $contenu) = @_;

    open my $sortie, '>:encoding(UTF-8)', $nom_de_fichier or die "Impossible d'ouvrir '$nom_de_fichier' en écriture : $!";
    print $sortie $contenu;
    close $sortie;

    return;
}
		
