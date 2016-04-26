//Constructeur de la "classe" Callserver    

function CallServer ()     
{     
 this.xhr_object;     
 this.server_response;     
      
 this.createXMLHTTPRequest = createXMLHTTPRequest;     
 this.sendDataToServer = sendDataToServer;     
 this.displayAnswer = displayAnswer;     
 this.launch = launch;     
}     


//On crée l'objet XMLHttpRequest     

function createXMLHTTPRequest()     
{     
 this.xhr_object = null;     
      
 if(window.XMLHttpRequest)     
 {     
    this.xhr_object = new XMLHttpRequest();     
 }     
 else if(window.ActiveXObject)      
 {     
    this.xhr_object = new ActiveXObject("Microsoft.XMLHTTP");     
 }     
 else      
 {     
    alert("Your browser doesn't provide XMLHttprequest functionality");     
    return;     
 }     
}     

//On envoit des données au serveur et on reçoit la réponse en mode synchrone dans this.server_response     

function sendDataToServer (data_to_send)     
{     
 var xhr_object = this.xhr_object;     
      
 xhr_object.open("POST", "./packet.cgi", false);     

 xhr_object.setRequestHeader("Content-type", "application/x-www-form-urlencoded");     
 
 //alert(data_to_send);
 xhr_object.send(data_to_send);     
  
 //if(xhr_object.readyState == 4)     
 //{      
  this.server_response = xhr_object.responseText;   
	//alert(this.server_response);
 //}     
}     

//On injecte la réponse du serveur dans la div nommée resultat    

function displayAnswer ()     
{     
 document.getElementById("resultat").innerHTML = "<h3>"+this.server_response+"</h3>";     
}     

//Exécution du Javascript  

function launch ()     
{  	
	 $("#resultat").css('display', 'block');
//	$("#resultat").show();
	
	this.sendDataToServer(document.getElementById("file-upload-1").value);     
	this.displayAnswer();     
}     

//Création de l'objet call_server    

var call_server = new CallServer();     
call_server.createXMLHTTPRequest();