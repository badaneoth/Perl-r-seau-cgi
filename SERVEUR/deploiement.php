<!DOCTYPE html>
<html>
<head>
    <meta charset="utf-8"/>

    <title>HNS</title>

    <link rel="stylesheet" href="assets/css/styles.css"/>
	<script src="js/jquery.js"></script>


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

<h3>Liste des programmes déployables</h3>


<form action="serverTest.cgi" method="post" ENCTYPE="multipart/form-data" name="formulaire">
<select id="elementId" name="elementId" value="">
	<option  id="dir" name="dir" value=""></option>

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
		
			if (!is_hidden($file) && $file != "." && $file != ".." && $file != "desktop.ini"  && strpos($file,'.txt')==false ) {        
					if(strpos($file,'.')==false){
						echo '<option  id="dir" name="dir" value="' . $file . '">' . $file . '</option>' . "\n";
					}
					else{
						echo '<option  id="file" name="file" value="' . $file . '">' . $file . '</option>' . "\n";
					}
				}
            }
            closedir($dh);
        }
    }

    ?>
</select>
	<div id="chemin">
		<input id="chem" type="text" name="chem" value="C:/"/><br>
	</div>
	<script>
	$(document).ready(function() {
		var $type = $('#elementId');
		// à la sélection d une valeur du pack
		$type.on('change', function() {
			var val = $(this).val(); // on récupère la valeur 
			var idSelect = $(this).attr('id');
			var id =$("#elementId option:selected").attr("id");
			//cest a tooi
			//alert("toto2 "+val+ "  "+idSelect +"  "+id);
			if(id=="file"){
				$("#chemin").show();
				$("#deployer").val("COPIER");
			}
			else if(id=="dir"){
				$("#chemin").hide();
				$("#deployer").val("DEPLOYER");
			}

		});
	});

 
	</script>
	<br><br>

	2) Cliquer sur Créer pour déployer le logiciel séléctionné : <BR>
    <input id="deployer" type="submit" name="Submit"  />
   
</form>


<footer>HNS Copyright - Tous droits réservés © 2015-2016.</footer>


</body>
</html>
