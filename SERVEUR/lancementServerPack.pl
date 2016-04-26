use Win32::Registry;
use Hash::Diff qw( diff );
use File::Basename;
use File::Copy::Recursive qw(dircopy);

#============================== INITIALISATION ===================================
my $chemin = 'C:\\'; 
my $install=$ARGV[0];
my $dossier='pack';
my $etape=1;
my $logiciel;
$giTotal = 0;
my %avant=();
my %apres=();
my %Roots = (
	HKEY_LOCAL_MACHINE  => $HKEY_LOCAL_MACHINE,
	HKEY_USERS => $HKEY_USERS,
	HKEY_CLASSES_ROOT => $HKEY_CLASSES_ROOT,
	HKEY_CURRENT_USER => $HKEY_CURRENT_USER
	
   );
my $nomMachine=nom_machine();
#==================================================================

#=========================================
# Etape 1 
	my @listeRepInit = lister_repertoires( $chemin, 1 );

	foreach $starter (keys %Roots) {
			print STDERR "\nScanning $starter\n";

			ProcessKey ( $Roots{$starter},$starter, "" );
			
		}
#=========================================

#=========================================
# Etape 2 
system ($install,"/s");
#=========================================

#=========================================
# Etape 3 
	my @listeRepActu = lister_repertoires( $chemin, 1 );
	$etape=2;
	foreach $starter (keys %Roots) {
		print STDERR "\nScanning $starter\n";

		ProcessKey ( $Roots{$starter}, $starter,"" );
		
	}
#=========================================

#=========================================
# Etape 4 on fait une comparaison de dossiers
	my %liste = map { $_ => 1 } @listeRepInit;
	my @diffRep = grep { not exists $liste{$_} } @listeRepActu;
#=========================================

#=========================================
# Etape 5
	if(scalar @diffRep > 0){
		#on cee le dossier du pack du logiciel
		$logiciel=extraire_nom_logiciel(@diffRep);
		copier_dif_repertoires($logiciel,@diffRep);
		
		#on fait la différence des registres
		my %dif = %{ diff( \%avant, \%apres ) };
		 $dossier="pack\\".$logiciel;
		my $AJOUT=$dossier."\\".$logiciel."+.reg";
		my $SUPP=$dossier."\\".$logiciel."-.reg";

		open(AJOUT,">$AJOUT") || die ("Erreur d'ouverture de TOTO") ;
		open(SUPP,">$SUPP") || die ("Erreur d'ouverture de TOTO") ;

		print  "------------------------ LA DIFFFF --------------------------------------\n";
		#Version_Éditeur_Registre
		print AJOUT "Windows Registry Editor Version 5.00 \n\n";
		print SUPP "Windows Registry Editor Version 5.00 \n\n";

		foreach $starter (keys %Roots) {
			foreach my $nom (keys %dif) {
				
				#print "===>$nom \n";
				my @sgis; 

				@sgis= split('#', $nom);
				my $chemin = shift @sgis;
				 $chemin =~ s/\\/\\\\/g;
			
				getKey ( $Roots{$starter}, $chemin );

				
				print AJOUT "\n"; 	
				print SUPP "\n"; 	
				
				
			}
			
		}
		close (AJOUT);
		close (SUPP);
		print  "-----------------------------------------------------------------------\n";
	}
	else {
		print "le logiciel $install existe déja ou l'installation n'a pas été faite!!\n"

	}
#=========================================


#=========================================
# Les différentes fonctions REPERTOIRES
#=========================================

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

sub extraire_nom_logiciel{
	my (@liste)=@_;
	foreach my $n (@liste) {
		print "$n\n";
		my $chaine="C:\\\\Program Files";
		return nom_logiciel($n) if grep $n =~ $_, $chaine;
      
	}

}
sub nom_logiciel{
	
	my ($nom) = @_;
	my @nom=split(/\\/, $nom);
	
	my $logiciel1 = pop @nom;
	print "MON Logiciel : $logiciel1 \n";
	return $logiciel1;
}
sub copier_dif_repertoires{
	 my ($logic,@diff)=@_;
	my $dossier1="pack\\".$logic;
	if(!-e $dossier1){
		mkdir ($dossier1,0755) || die ("Err. Création. répertoire \n");	
	}
	
	#---------------------------------------------------------------------------------
	#Ecriture des liens de la différence de fichiers dans le fichier pack\logiciel.txt
	my $CHEMIN=$dossier1."\\".$logic.".txt";
	#on copie les liens dans un fichiersopen(CHEM,">$CHEMIN") || die ("Erreur d'ouverture de $CHEMIN\n");
	open(CHEM,">$CHEMIN") || die ("Erreur d'ouverture de $CHEMIN\n");
	foreach my $chemin (@diff){
		
		my $dir=nom_logiciel($chemin);
		my $vers=$dossier1."\\".$dir;
		dircopy($chemin,$vers);
		$chemin=~ s/$nomMachine/ENV/g;
		print CHEM "$chemin\n";
			
	}
	close(CHEM);

}
sub lister_repertoires { 
  my ( $repertoire, $recursivite ) = @_; 
   my $fh_rep;
  if(opendir $fh_rep,$repertoire){
	  require Cwd; 
	  require File::Spec; 
	  
	  my $cwd = Cwd::getcwd(); 
	  
	  # Recherche dans les sous-répertoires ou non 
	  if ( ( not defined $recursivite ) || ( $recursivite != 1 ) ) { $recursivite = 0; } 
	  
	  # Verification répertoire 
	  if ( not defined $repertoire ) { die "Aucun repertoire de specifie\n"; } 
	  
	  # Ouverture d'un répertoire 
	  opendir my $fh_rep, $repertoire or die "impossible d'ouvrir le répertoire $repertoire\n"; 
	  
	  # Liste fichiers et répertoire sauf (. et ..) 
	  my @fic_rep = grep { !/^\.\.?$/ } readdir $fh_rep; 
	  
	  # Fermeture du répertoire 
	  closedir $fh_rep or die "Impossible de fermer le répertoire $repertoire\n"; 
	  
	  chdir $repertoire; 
	  $repertoire = Cwd::getcwd(); 
	  
	  # On récupère tous les répertoires 
	  my @repertoires; 
	  foreach my $nom (@fic_rep) { 
		my $notre_repertoire = File::Spec->catdir( $repertoire, $nom ); 
	  
		if ( -d $notre_repertoire and $recursivite == 0 ) { 
		  push @repertoires, $notre_repertoire; 

		} 
		#elsif( -f $notre_repertoire ){
		#	print "$notre_repertoire\n";
		
		#}
		elsif ( -d $notre_repertoire and $recursivite == 1 ) { 
		  push @repertoires, $notre_repertoire; 
		  push @repertoires, lister_repertoires($notre_repertoire, $recursivite);    # recursivité 
		} 
	  } 
	  
	  chdir $cwd; 
	  
	  return @repertoires; 
	}
	return undef; 
}
sub ListerFichiers {
 
  my ($repertoire) = @_;
  opendir (REP, $repertoire) or die "impossible d'ouvrir $repertoire\n";
  my @FichiersRepertoires = grep { !/^\.\.?$/ } readdir(REP);
  closedir (REP);
 
  my @fichiers = ();
  foreach my $nom (@FichiersRepertoires) {
    if ( -f "$repertoire/$nom") {
      push (@fichiers, "$nom");  
    }
  }
 
  return @fichiers;
}  

#===================================================
#Les fonctions des REGISTRES
#===================================================
sub ProcessKey
{
 $levels++;
 my( $Root,$start, $Path ) = @_;
 my $Key;
 
 if( $Root->Open( $Path, $Key ) )
 {
   my @KeyList;
   my %Values;
   $Key->GetKeys( \@KeyList );
   #print "##$Path\n";
   
   if( $Key->GetValues( \%Values ) )
   {
     foreach my $ValueName ( keys( %Values ) )
     {
	   
       $ValueName = "<Default Class>" if( "" eq $ValueName );
      
	    if($etape==1){
			$avant{$Path."#".$ValueName}=$ValueName;
		}
		 if($etape==2){
			$apres{$Path."#".$ValueName}=$ValueName;
		}
     }

   }
   $Key->Close();
   $Path .= "\\" unless ( "" eq $Path );
   foreach my $SubKey ( @KeyList )
   {
     ProcessKey( $Root,$start, $Path . $SubKey );
   }
 }
  $levels--;
 
}
sub getKey
{
 $levels++;
 my( $Root, $Path ) = @_;
 my $Key;
 my $chem=$Path;
 $chem =~ s/\\\\/\\/g;

 print AJOUT "[HKEY_LOCAL_MACHINE\\".$chem."]\n"; 
 print SUPP "[-HKEY_LOCAL_MACHINE\\".$chem."]\n"; 
 

 (++$giTotal%500) or inform_user();
 if( $Root->Open( $Path, $Key ) )
 {
   my @KeyList;
   my %Values;
   $Key->GetKeys( \@KeyList );
   if( $Key->GetValues( \%Values ) )
   {
     foreach my $ValueName ( keys( %Values ) )
     {
		
       my $Type = $Values{$ValueName}->[1];
       
	   my $Data = $Values{$ValueName}->[2];
		
		
		$ValueName =~ s/\\/\\\\/g;
		
		if($ValueName eq ""){
			if($Type == 0){
				$Data=unpack('H*',$Data);
				$Data=~ s/$nomMachine/ENV/g;
				print AJOUT "@=hex:$Data\n";
				print SUPP "@=hex:$Data\n";
			}
			elsif($Type == 1){
				$Data =~ s/\\/\\\\/g;
				$Data=~ s/$nomMachine/ENV/g;
				print AJOUT "@=\"$Data\"\n";
				print SUPP "@=\"$Data\"\n";
			}
			elsif($Type == 4){
				
				#Conversion 
				my $int = $Data;
				$bint = pack("N", $int);
				@octets = unpack("C4", $bint);
				
				print AJOUT "@=dword:";
				printf AJOUT "%02X" x 4 ."\n", @octets;
				print SUPP "@=dword:";
				printf SUPP "%02X" x 4 ."\n", @octets;
				
	
			}
			elsif($Type == 2 || $Type == 3 || $Type == 7 || $Type == 11 ){
			#A convertir le $data en hexa
				$Data=unpack('H*',$Data);
				
                $Data=transform($Data);
				print AJOUT "@=hex($Type):$Data\n";
				print SUPP "@=hex($Type):$Data\n";
			}	
			else{
				$Data=unpack('H*',$Data);
                $Data=transform($Data);
				print AJOUT "@=hex($Type):$Data \n";
				print SUPP "@=hex($Type):$Data \n";
				
		   }

		}
		else{
			if($Type == 0){
				$Data=unpack('H*',$Data);
				$ValueName=~ s/$nomMachine/ENV/g;
				$Data=~ s/$nomMachine/ENV/g;
				print AJOUT "\"$ValueName\"=hex:$Data\n";
				print SUPP "\"$ValueName\"=hex:$Data\n";
			}
			elsif($Type == 1){
				$Data =~ s/\\/\\\\/g;
				$ValueName=~ s/$nomMachine/ENV/g;
				$Data=~ s/$nomMachine/ENV/g;
				print AJOUT "\"$ValueName\"=\"$Data\"\n";
				print SUPP "\"$ValueName\"=\"$Data\"\n";
			}
			elsif($Type == 4){
				#Conversion 
				my $int = $Data;
				$bint = pack("N", $int);
				@octets = unpack("C4", $bint);
				$ValueName=~ s/$nomMachine/ENV/g;

				print AJOUT "\"$ValueName\"=dword:";
				printf AJOUT "%02X" x 4 ."\n", @octets;
				print SUPP "\"$ValueName\"=dword:";
				printf SUPP "%02X" x 4 ."\n", @octets;
				
			}
			elsif($Type == 2 || $Type == 3 || $Type == 7 || $Type == 11 ){
				
				$Data=unpack('H*',$Data);
                $Data=transform($Data);
				$ValueName=~ s/$nomMachine/ENV/g;
				print AJOUT "\"$ValueName\"=hex($Type):$Data \n";
				print SUPP "\"$ValueName\"=hex($Type):$Data \n";
			}
			else{
				$Data=unpack('H*',$Data);
                $Data=transform($Data);
				$ValueName=~ s/$nomMachine/ENV/g;
				print AJOUT "\"$ValueName\"=hex($Type):$Data \n";
				print SUPP "\"$ValueName\"=hex($Type):$Data \n";
		   }
		
		}

		
	 }
   }
  
   $Key->Close();
   $Path .= "\\" unless ( "" eq $Path );
   foreach my $SubKey ( @KeyList )
   {
     getKey( $Root, $Path . $SubKey );
   }
 }
 $levels--;
 $levels or inform_user();
}

sub inform_user {
	print  STDERR ("Scanned $giTotal keys\r");
}

sub transform{
    my ($res)=@_;
	# print "AVANT : $res\n\n";
    my $resultat="";
    my $taille=(length $res)/2;
	# print "AVANT FOR : taille = $taille\n";
    for (my $i =0; $i < $taille;$i++){
       
        my @lis= split(/,/,$res);
        if(scalar @lis >=2){
			
            $res=pop @lis;
            $resultat=$resultat.shift @lis;
        }
        else{
		
            $res=pop @lis;
        }
        $resultat=$resultat.",";
        $res=~ s/(.{2})(.+)/$1,$2/;
    }
    $resultat=$resultat.$res;
    $resultat=substr($resultat,1);
    $resultat=~s/,/,00,/g;
	$resultat=$resultat.",00,00,00";
   # print "Apres :$resultat\n\n";
    return $resultat;
  }