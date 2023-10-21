<?php

function adminer_object() {
	include_once "./plugins/plugin.php";
    
	foreach (glob("plugins/*.php") as $filename) {
		include_once "./$filename";
	}
	
	if (is_file("drivers.php")) {
		include "drivers.php";
	}
	
	if (is_file("plugins.php")) {
		include "plugins.php";
	}
	
	if (is_file("customization.php")) {
		include "customization.php";
	}
	
	return new AdminerPlugin($plugins);
}

include "./adminer.php";
?>
