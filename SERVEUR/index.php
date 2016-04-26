<!DOCTYPE html>

<html>
<head>
    <meta charset="utf-8"/>

    <title>HNS</title>

    <link rel="stylesheet" href="assets/css/styles.css"/>
	<script src="js/jquery.js"></script>
	<script type="text/javascript" src="js/Script1.js" ></script>  
	
</head>

<body>

<header>
    <h1>HNS Host Network Software</h1>
</header>

<nav>
    <ul class="fancyNav">
        <li id="home"><a href="index.php" class="homeIcon">Home</a></li>
        <li id="Déploiement"><a href="deploiement.php">Déploiement</a></li>
        <li id="Désinstalation"><a href="desinstall.php">Désinstallation</a></li>
    </ul>
</nav>

<h3>Liste des programmes déployés</h3>

<select name="dossiers">

    <?php

    function is_hidden($file)
    {


        // Système Unix/Linux
        if (substr(PHP_OS, 0, 3) != 'WIN') {
            return (preg_match('/^./', basename($file), $match));
        } // Système Windows
        else {
            $cmd = 'dir "' . str_replace('/', '', dirname($file)) . '" /AH';
            $result = shell_exec($cmd);
            $pattern = '/[0-9]{2}:[0-9]{2}s+(?:<(?:DIR|REP)>)?(?:[0-9]+)?s+(.*?)n/i';
            preg_match_all($pattern, $result, $matches);
            return in_array(basename($file), $matches[1]);
        }
    }

    $dir = getcwd() . "/pack";

    if (is_dir($dir)) {
        if ($dh = opendir($dir)) {

            while (($file = readdir($dh)) !== false) {
#Vérifier sur Windows
                if (!is_hidden($file) && $file != "." && $file != ".." && $file != "desktop.ini" ) {
                    echo '<option value="' . $file . '">' . $file . '</option>' . "\n";
                }
            }
            closedir($dh);
        }
    }

    ?>
</select>

<br><br>

<div class="upload">

        <h3><label for="">Créer un packet à partir d'un executable </label><br><br></h3>
        <ul>
            <li>Sélectionnez le fichier :<BR>
                <input id="file-upload-1" type="file" name="uploaded"/><br>
            </li>
            <li>
                Cliquer sur Créer pour créer le packet<BR>
                <input type="submit" id="creation" name="Submit" value="Créer" onclick="call_server.launch();"/>
            </li>
            
			<div id="resultat" >
			
			<li><IMG SRC='assets/img/wait.gif' ALT='wait' width='50px' height='50px'/></li>
			
			</div> 
            

        </ul>
    </div>


<footer>HNS Copyright - Tous droits réservés © 2015-2016.</footer>


</body>
</html>
