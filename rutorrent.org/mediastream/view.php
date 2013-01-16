<?php


if(!isset($_GET['ses'])) {die('404 bUfU');}
$oldses = session_id();
if(!empty($oldses)) {die('404 Its not for you');}

session_id($_GET['ses']);
session_start();

$_SERVER['REMOTE_USER'] = $_SESSION['uname'];


unset($_POST); $_POST = $_GET;


require_once( dirname(__FILE__)."/../../php/xmlrpc.php" );
require_once( dirname(__FILE__)."/../filemanager/flm.class.php" );
require_once( dirname(__FILE__)."/../filemanager/xmlfix.php" );


eval(getPluginConf('filemanager'));

class vs extends FLM {

	public function stream($file) {

		$this->shout = FALSE;

		if (!preg_match('/^(avi|divx|mpeg|mp4|mkv)$/i', $this->fext($file))) {$this->sdie('404 Invalid format');}

		if (!is_file($this->workdir.$file)) {$this->sdie('404 File not found');}

		header('Content-Type: video/divx');
		header('Content-Disposition: inline; filename="'.$file.'"');

		$this->get_file($this->workdir.$file);
	}
}



$s = new vs();
$s->stream($s->postlist['target']);

?>