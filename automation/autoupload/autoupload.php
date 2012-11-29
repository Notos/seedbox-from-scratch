<?php
include_once 'simple_html_dom.php';

$debug = false;

$tempFolder = '/tmp/autoupload';
$workingFolder = '/tank/MediaCenter/!ebooks/autoupload';
$uploadedFolder = $workingFolder."/uploaded";
$uploadedFolderFiles = $uploadedFolder."/files";
$uploadedFolderTorrents = $uploadedFolder."/torrents";

if (!is_dir($tempFolder)) 						mkdir($tempFolder);
if (!is_dir($workingFolder)) 					mkdir($workingFolder);
if (!is_dir($uploadedFolder)) 				mkdir($uploadedFolder);
if (!is_dir($uploadedFolderFiles)) 		mkdir($uploadedFolderFiles);
if (!is_dir($uploadedFolderTorrents))	mkdir($uploadedFolderTorrents);

$log = array();

$formats = array();
$formats[] = "epub";
$formats[] = "mobi";
$formats[] = "pdf";

$trackers = array();

// Error messages
// 'No torrent file uploaded, or file is empty.'

/*$trackers['stf'] = array(	
														 	'userAgent' => 'Notos AutoUploader',
															'announce' => 'http://sendthatfile.me:58697/n301sai1giszsqt2pjsqphk07fx8fo9v/announce',
															'username' => 'TomBombadil',
														 	'password' => 'foda-se',
														 	'searchURL' => 'http://sendthatfile.me/torrents.php?action=advanced&groupname=',
														 	'searchPositiveString' => 'title="Download"',
														 	'loginURL' => 'http://sendthatfile.me/login.php?',
														 	'logiUsernameField' => 'username',
														 	'logiPasswordField' => 'password',
														 	'loggedInString' => 'logout',
														 	'loggedOutString' => 'login',
														 	'torrentPieceLength' => 17,
														 	'uploadURL' => 'http://sendthatfile.me/upload.php?',
														 	'uploadTorrentFileField' => 'file_input',
														 	'uploadExtraField-type' => "2", // E-books
														 	'uploadExtraField-auth' => "34da43cdcbef80b1843a7a16461c4959",
														 	'uploadExtraField-title' => "<title2>",
														 	'uploadExtraField-tags' => "<tags>",
														 	'uploadExtraField-image' => "<image>",
														 	'uploadExtraField-desc' => "<text>",
														 	'uploadExtraField-submit' => "true",
														);

$trackers['what.cd'] = array(	
														 	'userAgent' => 'Notos AutoUploader',
															'announce' => 'http://tracker.what.cd:34000/fphw82lolewtsvqq4l8a8jpz9t1uanw8/announce',
															'username' => 'Theophylaktos',
														 	'password' => 'c8EbrEquducHerUCHeStajUsteJutRES',
														 	'searchURL' => 'https://what.cd/torrents.php?searchstr=',
														 	'searchPositiveString' => 'title="Download"',
														 	'loginURL' => 'https://what.cd/login.php?',
														 	'logiUsernameField' => 'username',
														 	'logiPasswordField' => 'password',
														 	'torrentPieceLength' => 18,
														 	'loggedInString' => 'logout',
														 	'loggedOutString' => 'login',
														 	'uploadURL' => 'https://what.cd/upload.php?',
														 	'uploadTorrentFileField' => 'file_input',
														 	'uploadExtraField-type' => "2", // E-books
														 	'uploadExtraField-auth' => "a91b1feba24c185ba20374b343748067",
														 	'uploadExtraField-title' => "<title2>",
														 	'uploadExtraField-tags' => "<tags>",
														 	'uploadExtraField-image' => "<image>",
														 	'uploadExtraField-desc' => "<text>",
														 	'uploadExtraField-submit' => "true",
														);*/

														 
$trackers['bibliotik'] = array(	
														 		'userAgent' => 'Notos AutoUploader',
																'announce' => 'http://bibliotik.org/announce.php?passkey=35bca6a295ab88d797cb85c9fc25fc95',
														 		'username' => 'Prometheos',
														 		'password' => 'chusuxeba3akUdRegA9u2raprECruPru',
														 		'searchURL' => 'http://bibliotik.org/torrents/?search=',
														 		'searchPositiveString' => 'title="Download"',
														 		'loginURL' => 'http://bibliotik.org/login?',
														 		'logiUsernameField' => 'username',
														 		'logiPasswordField' => 'password',
														 		'torrentPieceLength' => 19,
														 		'loggedInString' => 'bibliotik.org/logout',
														 		'loggedOutString' => 'value="Log In!"',
														 		'uploadURL' => 'http://bibliotik.org/upload.php?',
														 		'uploadTorrentFileField' => 'TorrentFileField',
														 		'uploadExtraField-authkey' => "353c891f16a62fdae53c82c7a6f57d0c10662d3c",
														 		'uploadExtraField-submit' => "true",
														 		'uploadExtraField-upload' => "true",
														 		'uploadExtraField-AuthorsField' => "<author>",
														 		'uploadExtraField-TitleField' => "<title>",
														 		'uploadExtraField-IsbnField' => "<isbn>",
														 		'uploadExtraField-PagesField' => "<pages>",
														 		'uploadExtraField-YearField' => "<year>",
														 		'uploadExtraField-FormatField' => "bibliotikFormats|<format>",
														 		'uploadExtraField-LanguageField' => "bibliotikLanguages|<language>",
        						 		        'uploadExtraField-TagsField' => "<tags>",
        						 		        'uploadExtraField-ImageField' => "<image>",
        						 		        'uploadExtraField-DescriptionField' => "<text>",
        						 		        'uploadExtraField-NotifyField' => "1",
														 	);          

$bibliotikFormats = array();
$bibliotikFormats["PDF"] = "2";
$bibliotikFormats["DJVU"] = "4";
$bibliotikFormats["CHM"] = "6";
$bibliotikFormats["CBR"] = "3";
$bibliotikFormats["MOBI"] = "16";
$bibliotikFormats["TXT"] = "14";
$bibliotikFormats["EPUB"] = "15";
$bibliotikFormats["AZW3"] = "21";

$bibliotikLanguages = array();
$bibliotikLanguages["English"] = "1";
$bibliotikLanguages["German"] = "2";
$bibliotikLanguages["French"] = "3";
$bibliotikLanguages["Spanish"] = "4";
$bibliotikLanguages["Italian"] = "5";
$bibliotikLanguages["Latin"] = "6";
$bibliotikLanguages["Japanese"] = "7";
$bibliotikLanguages["Danish"] = "15";
$bibliotikLanguages["Swedish"] = "8";
$bibliotikLanguages["Norwegian"] = "9";
$bibliotikLanguages["Dutch"] = "12";
$bibliotikLanguages["Russian"] = "13";
$bibliotikLanguages["Polish"] = "18";
$bibliotikLanguages["Portuguese"] = "14";
$bibliotikLanguages["Greek"] = "21";
$bibliotikLanguages["Gaelic"] =  "20";
$bibliotikLanguages["Korean"] = "16";
$bibliotikLanguages["Chinese"] = "17";
$bibliotikLanguages["Arabic"] = "19";

														 	
foreach($trackers as $tracker => $record)	{
	$trackers[$tracker]['cookiesFile'] = $tempFolder.'/cookies.'.$tracker.'.txt';
	$trackers[$tracker]['loginFile'] = $tempFolder.'/login.'.$tracker.'.html';
	$trackers[$tracker]['searchFile'] = $tempFolder.'/search.result.'.$tracker.'.html';
	$trackers[$tracker]['uploadFile'] = $tempFolder.'/upload.'.$tracker.'.html';
	$trackers[$tracker]['loginTries'] = 0;
}

$converters['epub.mobi'] = '/bin/kindlegen <from>';
$converters['mobi.epub'] = '/usr/bin/xvfb-run /usr/bin/ebook-convert <from> <to>';
$converters['pdf.mobi'] = '/usr/bin/xvfb-run /usr/bin/ebook-convert <from> <to>';
$converters['pdf.epub'] = '/usr/bin/xvfb-run /usr/bin/ebook-convert <from> <to>';
$converters['epub.pdf'] = '/usr/bin/xvfb-run /usr/bin/ebook-convert <from> <to>';
$converters['mobi.pdf'] = '/usr/bin/xvfb-run /usr/bin/ebook-convert <from> <to>';

$tagReplacements = array();
$tagReplacements['socmed'] = 'social.media';
$tagReplacements['information,technologies'] = 'technology';

$fieldNames = "url,htmlName,title,title2,image,text,name,author,info,year,pages,isbn,links,formats,tags,uploaded,torrentName,torrentFiles,infoFileName,downloadedFileName,passwords,searchString,searchResults";

$data = array();
$fields = explode(",",$fieldNames);
foreach($fields as $field) {
	$data[$field] = "";
}

openHTML();

$data = loadPOSTData($data, $_POST);

//__pa($_POST);
//__pa($_GET);
//__pa($_REQUEST);

if (isset($_POST['submit']) and $_POST['submit'] == 'Save') {
	saveData($data);
	__d("-- Savedata");
}
if (isset($_POST['submit']) and ($_POST['submit'] == 'Parse' or $_POST['submit'] == 'Search' or $_POST['submit'] == 'Upload')) {
	$url = $_POST['url'];
	__d("-- POST - Parse - Search - Upload");
} else if (isset($_POST['infoFileName'])) {
	$infoFileName = $_POST['infoFileName'];
	__d("-- POST isset(infoFileName)");
}

if (isset($_GET['submit']) and ($_GET['submit'] == 'Parse' or $_GET['submit'] == 'Search' or $_GET['submit'] == 'Upload')) {
	$url = $_GET['url'];
	__d("-- GET - Parse - Search - Upload");
} else if (isset($_GET['infoFileName'])) {
	$infoFileName = $_GET['infoFileName'];
	__d("-- GET isset(infoFileName)");
}

if(isset($url)) {
	$data = parseData($url,$data);
	__d("-- isset(url)");
} else if(isset($infoFileName) and !empty($infoFileName)) {
	$data = loadData($infoFileName);
	__d("-- isset(infoFileName)");
}	

if ((isset($_POST['submit']) and $_POST['submit'] == 'Search') or (isset($_GET['submit']) and $_GET['submit'] == 'Search')) {
	__d("-- searchTrackers");
	$data = searchTrackers($data);
}

if ((isset($_POST['submit']) and $_POST['submit'] == 'Upload') or (isset($_GET['submit']) and $_GET['submit'] == 'Upload')) {
	__d("-- uploadData");
	$data['searchResults'] = isset($_POST['searchResults']) ? $_POST['searchResults'] : "";
	$data = upload($data);
}

__d("-- showURLForm");
showURLForm(isset($data['url']) ? $data['url'] : '');

if (dataHasData($data)) {
__d("-- showDataForm");
	showDataForm($data);
}	

listFiles($workingFolder);

// ---------------------------------------------------

closeHTML();

// ---------------------------------------------------
// --------------------------------------------------- End of Main
// ---------------------------------------------------
// ---------------------------------------------------
// ---------------------------------------------------
// ---------------------------------------------------
// ---------------------------------------------------
// ---------------------------------------------------
// ---------------------------------------------------
// ---------------------------------------------------
// ---------------------------------------------------
// ---------------------------------------------------
// ---------------------------------------------------
// ---------------------------------------------------
// ---------------------------------------------------
// ---------------------------------------------------

function dataHasData($data) {
	if(isset($data) and is_array($data)) {
		foreach($data as $index => $content) {
			if (isset($content) and !empty($content)) {
				return true;
			}
		}
	}
	return false;
}

function normalizetags($tags) {
	global $tagReplacements;
	foreach($tagReplacements as $old => $new) {
		if (!(stripos(",$tags,",",$old,")===false)) {
			$tags = str_replace($old, $new, $tags);
		}
	}
	return $tags;
}

function __d($s) {
	global $debug;
	if ($debug) __p($s);
}
function searchTrackers($data) {
	global $tempFolder, $trackers;
	
	$data['searchResults'] = "";
	foreach($trackers as $tracker => $record)	{
		$trackers[$tracker]['loginCommand'] = '/usr/bin/wget -U "'.$trackers[$tracker]['userAgent'].'" -q --no-check-certificate -O '.$trackers[$tracker]['loginFile'].' --save-cookies '.$trackers[$tracker]['cookiesFile'].' --keep-session-cookies --post-data "'.$record['logiUsernameField'].'='.$record['username'].'&'.$record['logiPasswordField'].'='.$record['password'].'" "'.$record['loginURL'].'"';
		$trackers[$tracker]['searchCommand'] = '/usr/bin/wget -U "'.$trackers[$tracker]['userAgent'].'" -q --no-check-certificate -O '.$trackers[$tracker]['searchFile'].' --load-cookies '.$trackers[$tracker]['cookiesFile'].' "'.$record['searchURL'].$data['searchString'].'"';
		
		//__p( $trackers[$tracker]['searchCommand'] );
		if (!trackerLogin($tracker)) {
			__p("Could not login in tracker $tracker.");
			return false;
    }

    if ( searchTorrent($tracker, $data['searchString']) ) {
			$found = '(FOUND) TORRENT "'.$data['searchString'].'"';
    } else {
			$found = '(NOT FOUND) TORRENT "'.$data['searchString'].'"';
    }
    
    $data['searchResults'] = $data['searchResults'] . "$tracker:$found\n";
	}
	
	return $data;
}

function trackerLogin($tracker, $force = false) {
	global $trackers;                                                                                                                                                                      
	
	if (!$force) {
		$time = time()-filemtime($trackers[$tracker]['cookiesFile']);

		if ( (isset($trackers[$tracker]['logged']) and $trackers[$tracker]['logged'] == true) or (file_exists($trackers[$tracker]['cookiesFile']) and ($time < 24*60*60) ) ) {
  		$trackers[$tracker]['logged'] = true;
			__p("$tracker: already logged");
  		return true;
		}
  }

	__p("Logging in $tracker...");
	$trackers[$tracker]['loginTries'] += 1;

	if ($trackers[$tracker]['loginTries'] > 3) {
		__p("$tracker login tries: ". $trackers[$tracker]['loginTries'] );
		die;
	}
	
	$postData = array();
	$postData[$trackers[$tracker]['logiUsernameField']] = $trackers[$tracker]['username'];
	$postData[$trackers[$tracker]['logiPasswordField']] = $trackers[$tracker]['password'];

	$response = surf($trackers[$tracker]['loginURL'], $postData, $trackers[$tracker]['cookiesFile'], $trackers[$tracker]['userAgent']);
	
	if(!isset($trackers[$tracker]['tries'])) $trackers[$tracker]['tries'] = 0;
	$trackers[$tracker]['tries']++;
	
	$trackers[$tracker]['logged'] = false;	
	
	$file = $trackers[$tracker]['loginFile'];
	$command = $trackers[$tracker]['loginCommand'];

	if(!(stripos($response,$trackers[$tracker]['loggedInString'])===false)) {
		__p("Successfully logged in $tracker.");
		$trackers[$tracker]['logged'] == true;
		return true;
	}
	
	return false;
}
         
function searchTorrent($tracker, $searchString) {
	global $trackers;
	
	$file = $trackers[$tracker]['searchFile'];
	$command = $trackers[$tracker]['searchCommand'];
	
	__p("$tracker: searching. ** ".$trackers[$tracker]['loggedOutString']);
	$postData = array();
	$response = surf($trackers[$tracker]['searchURL'].$searchString, $postData, $trackers[$tracker]['cookiesFile'], $trackers[$tracker]['userAgent']);
	
	if(!(stripos($response,"411 Length Required")===false)) { 
		__p("Error 411 Length Required: try editing the search string.");
		return false;
	} else if(!(stripos($response,"400 Bad Request")===false)) { 
		__p("Error 400 Bad Request: try editing the search string.");
		return false;
	} if(!(stripos($response,$trackers[$tracker]['searchPositiveString'])===false)) {
		return true;
	} else if(!(stripos($response,$trackers[$tracker]['loggedOutString'])===false)) {
		__p("$tracker: will have to re-login.");
		if ( trackerLogin($tracker, true) ) { // force
			return searchTorrent($tracker, $searchString);
		}
	}
	return false;
}

function upload($data) {           
	global $trackers, $formats, $workingFolder, $uploadedFolderTorrents, $uploadedFolderFiles;
	
 if (empty($data['searchResults'])) {
		__p("You have to search before uploading.");
	}
	
	$uploadTo = array();
	$a = explode("\n",$data['searchResults']);
	foreach($a as $tracker) {
		$tracker = explode(":", $tracker);
		if (stripos($tracker[1],"(FOUND)")===FALSE) {
			$uploadTo[] = $tracker[0];
			__p($tracker[0]);
		}
	}

	$data['tagsCopy'] = $data['tags'];

	$files = array();
	foreach($formats as $format) {
		$file = "$workingFolder/".$data['torrentName'].".$format";
		if (!file_exists($file)) {
			continue;
		}
		$movedFile = "$uploadedFolderFiles/".$data['torrentName'].".$format";
		$torrentFiles = array();
		$files[] = $file;
		foreach($uploadTo as $tracker) {
			$torrentFile = "$workingFolder/".$data['torrentName'].".$format.$tracker.torrent";
			$movedTorrentFile = "$uploadedFolderTorrents/".$data['torrentName'].".$format.$tracker.torrent";
			
			$torrentFiles[] = $torrentFile;
			
  		if ( !file_exists($file) ) {
  			__p("File not found: $file");
  			continue;
			}
  		if ( !file_exists($torrentFile) ) {
  			__p("File not found: $torrentFile");
  			continue;
			}
		
			$data['tags'] = $data['tagsCopy'] . ",$format";
			
			$postData = getExtrafields($tracker,$data,$format);
			
			$postData[$trackers[$tracker]['uploadTorrentFileField']] = "@$torrentFile";
			
			__pa($postData);
			
	    /*$ch = curl_init();
	    curl_setopt($ch, CURLOPT_HEADER, 0);
	    curl_setopt($ch, CURLOPT_VERBOSE, 1);               
	    //curl_setopt($ch, CURLOPT_FILE, $trackers[$tracker]['uploadFile']); ////////////  Warning: curl_setopt(): supplied argument is not a valid File-Handle resource in /var/www/t.php on line 265
	    curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
	    curl_setopt($ch, CURLOPT_COOKIEJAR, $trackers[$tracker]['cookiesFile']);
	    curl_setopt($ch, CURLOPT_COOKIEFILE, $trackers[$tracker]['cookiesFile']);
	    curl_setopt($ch, CURLOPT_USERAGENT, $trackers[$tracker]['userAgent']);
	    curl_setopt($ch, CURLOPT_URL, $trackers[$tracker]['uploadURL']);
	    curl_setopt($ch, CURLOPT_POST, true);
	    curl_setopt($ch, CURLOPT_POSTFIELDS, $postData); 
	    $response = curl_exec($ch);
			if (curl_errno($ch)) {
				__p("Error: ".curl_errno($ch)." = ".curlError(curl_errno($ch)));
			}
  		curl_close($ch);
	    
	    if (empty($response)) {
				__p("successfully uploaded: $torrentFile");
				rename($torrentFile, $movedTorrentFile);
	    } else {
				__p($response);
	    }*/
		}
		
		$complete = true;
		foreach($torrentFiles as $torrent) {
			if (file_exists($torrent)) {
				$complete = false;
				__p("At least this file was not uploaded to tracker: $torrent");
			}
		}
		if ($complete) {
			rename($file, $movedFile);
		}
	}
	
	$complete = true;
	foreach($files as $file) {
		if (file_exists($file)) {
			$complete = false;
		}
	}
	if ($complete) {
		rename("$workingFolder/".$data['torrentName'].".info", "$uploadedFolderFiles/".$data['torrentName'].".info"); // game over
		__p("All done, congratulations. :P");
	}
	
	return $data;
}

function getExtrafields($tracker,$data,$format) {
	global $trackers;

	$post = array();
	$ret = "";
	foreach($trackers[$tracker] as $index => $field) {
		if (!(stripos($index,"uploadExtraField")===false)) {
			$field = replaceMarks($field,$data,$format);
			$a = explode("-",$index);
			$field = getExtraFieldValue($field);
			$ret .= ' -F "'.$a[1].'='.$field.'" ';
			$post[$a[1]] = $field;
		}
	}
	
	//return $ret;
	return $post;
}

function getExtraFieldValue($field) {
	$a = explode("|",$field);
	if (count($a) > 1) {
		if ($a[0] == 'bibliotikFormats') {
			$field = $bibliotikFormats[strtoupper($a[1])];
		}
		if ($a[0] == 'bibliotikLanguages') {
			$field = $bibliotikLanguages[strtoupper($a[1])];
		}
	}
	return $field;
}

function replaceMarks($field, $data, $format) {
	foreach($data as $index => $value) {
		$field = str_replace("<$index>",$value,$field);
	}
	$field = str_replace("<FORMAT>",strtoupper($format),$field);
	$field = str_replace("<format>",strtolower($format),$field);
	return $field;
}

function loadData($fileName) {
	$contents = file_get_contents($fileName);
	return json_decode($contents,true);
	/*
	__p("<pre>$contents</pre>");
	$xml = xml2array( $contents );
	return $xml['xml'];*/
}

function listFiles($folder) {
	$files = scandir($folder);
	foreach($files as $file) {
		if(preg_match('/.*\.info$/', $file)) {
			$file = $folder.'/'.$file;
			__p('<a href="autoupload.php?infoFileName='.$file.'">'.$file.'</a>');
		}
	}
}

function loadPOSTData($data, $_POST) {
	global $fieldNames;
	
	$fields = explode(",",$fieldNames);
	foreach($fields as $field) {
		if (isset($_POST[$field]) and !empty($_POST[$field])) {
			$data[$field] = $_POST[$field];
		}
	}
	
	return $data;
}

function saveData($data) {
	global $fieldNames, $workingFolder;

	$fileName = normalizeFileName($workingFolder.'/'.$data['torrentName'].".info");

	$data["infoFileName"] = $fileName;
	if (file_exists($fileName)) {
		unlink($fileName);
	}

	$data['searchResults'] = ""; /// always empty
	
	$data = generateFiles($data);
	
	$data['title2'] = $data['author']." - ".$data['title'];
	
	$content = json_encode($data);
	__l($content, $fileName);
} 

function generateFiles($data) {
	global $fieldNames, $workingFolder, $formats;
	
  if ( empty($data['downloadedFileName']) or !file_exists($workingFolder.'/'.$data['downloadedFileName']) ) {
  	__p("File not found: ".$workingFolder.'/'.$data['downloadedFileName']);
  	return $data;
	}
  
  $i = strrpos($data['downloadedFileName'],'.');
  
  if (!($i === false)) {
  	$base = substr($data['downloadedFileName'], 0, $i);
  	$originalFormat = substr($data['downloadedFileName'], $i+1);
	} else {
		$base = $data['downloadedFileName'];
		$originalFormat = "";
	}

	generateAllFormats("$workingFolder/$base");
	generateAllFormats("$workingFolder/$base"); /// on purpose :)
	
	foreach($formats as $format) {
		$file = "$workingFolder/$base.$format";
  	if (file_exists($file)) {
  		$data['downloadedFileName'] = renameFile("$base.$format", $data['torrentName'].'.'.strtolower($format));
			$data['torrentFiles'] = makeTorrents($data['downloadedFileName']);
		}
	}
  
  $file = $workingFolder.'/'.$data['downloadedFileName'];
  return $data;
}

function generateAllFormats($fileBase) {
	global $converters;
	
	foreach($converters as $formats => $converter) {
		$formats = explode(".",$formats);
		if (file_exists("$fileBase.".$formats[0]) and !file_exists("$fileBase.".$formats[1])) {
			$from = escapeFileName("$fileBase.".$formats[0]);
			$to = escapeFileName("$fileBase.".$formats[1]);
			$conversion = str_replace("<from>",$from,$converter);
			$conversion = str_replace("<to>",$to,$conversion);
			
			__p("gen 1 - $conversion");
			$bibliotikLanguages = "";
			system($conversion,$conversionLog);
			addToLog($conversionLog);
		}
	}
}

function makeTorrents($fileName) {
	global $workingFolder, $trackers;
	
	$torrents = "";
	foreach($trackers as $tracker => $data) {
		$piece = $data['torrentPieceLength'];
		$announce = $data['announce'];
		
		$dataFileName = $workingFolder.'/'.$fileName;
		$torrent = $dataFileName.".$tracker.torrent";
		
		$torrent_escaped = escapeFileName($torrent);
		
		if (!file_exists($torrent)) {
			addToLog( system("/usr/bin/mktorrent -p -a $announce --piece-length=$piece --output=\"$torrent\" \"$dataFileName\"") );
		}
		$torrents .= $torrent."\n";
	}
	
	return $torrents; 
}

function escapeFileName($f) {
	$f = str_replace(" ","\ ",$f);
	$f = str_replace("(","\(",$f);
	$f = str_replace(")","\)",$f);
	$f = str_replace("!","\!",$f);
	
	return $f;
} 

function renameFile($oldName,$newName) {
	global $workingFolder;
	
	if ($oldName != $newName) {
		rename( "$workingFolder/$oldName", "$workingFolder/$newName" );
	}
	
	return $newName;
}

function parseTagsFromURL($tags, $url) {
	$bannedTags =  array();
	$bannedTags[] = "book";
	$bannedTags[] = "books";
	$bannedTags[] = "ebooks";
	$bannedTags[] = "ebook";
	$bannedTags[] = "html";
	
	$parsed = parse_url($url);
	$all = $parsed['path'];
	$all = str_replace("/","_",$all);
	$all = str_replace(".","_",$all);
	$all = explode("_", $all);
	foreach($all as $tag) {
		if (!empty($tag)) {
			if(!in_array($tag, $bannedTags) and !is_numeric($tag) and stripos($tags,$tag) === false) {
				$tags = addTag($tags,$tag);
			}
		}
	}
	return $tags;
}

function getHTMLName($url) {
	$parsed = parse_url($url);
	$parsed = explode("/",$parsed["path"]);
	$parsed = $parsed[count($parsed)-1];
	$parsed = explode(".", $parsed);
  return $parsed[0];
}

function addTag($tags, $tag) {
	$tag = strtolower($tag);
	
	if(!isset($tags)) {
		$tags = "";
	}
	if(stripos($tags.",",$tag.",") === false) {
		$tags = $tags . (!empty($tags) ? "," : "") . $tag;
	}
	return $tags;
}

function showDataForm($data) {
	?>
		<form method="post">
		<input type="submit" id="buttonSave" 	 name="submit" value="Save" />
		<input type="submit" id="buttonSearch" name="submit" value="Search" />
		<input type="submit" id="buttonUpload" name="submit" value="Upload" />
		<br><br>
	<?
	
	foreach($data as $index => $r) {
		$data[$index] = brReplace($data[$index]);
		
		if (strtolower($data[$index]) == "false") {
			$data[$index] = "";
		}
		?><b><?=$index?></b><br /><?
		
		if ($index == "text" or $index == "links" or $index == "torrentFiles"  or $index == "passwords"  or $index == "searchResults") {
			?><textarea cols="150" rows="10" name="<?=$index?>"><?=$data[$index]?></textarea><br /><br /><?
		} else {
			?><input type="text" name="<?=$index?>" value="<?=$data[$index]?>" size="150"><br /><br /><?
		}
	}
	
	?>
		</form>
	<?
}

function curl($url) {
  $ch = curl_init();
  curl_setopt($ch, CURLOPT_URL, $url);
  curl_setopt($ch, CURLOPT_RETURNTRANSFER,1);
  $data = curl_exec($ch);
	if (curl_errno($ch)) {
		__p("CURL Error: ".curl_errno($ch)." = ".curlError(curl_errno($ch)));
	}
  curl_close($ch);
  return $data;
}
        
function parseData($url,$ret) {
	//remove additional spaces
	
	$html = file_get_html($url);
  /*$contents = surf($url);
	$html = new simple_html_dom(null, true, true, DEFAULT_TARGET_CHARSET, true, DEFAULT_BR_TEXT, DEFAULT_SPAN_TEXT);
	$html->load($contents, true, true);
	*/
	
	$htmlName = getHTMLName($url);

	$title = $html->find('title');
	
	if ($title[0]->plaintext == "Maintenance") {
		echo "<br><br><br><h1>Page host is in Maintenance, try later.</h1><br><br><br>";
		return false;
	}
	
	$languages = "Afrikaans,Albanian,Arabic,Basque,Bulgarian,Belarusian,Catalan,Chinese,Croatian,Czech,Danish,Dutch,Dutch,English,Estonian,Faeroese,Farsi,Finnish,French,Gaelic,Irish,German,Greek,Hebrew,Hindi,Hungarian,Icelandic,Indonesian,Italian,Italian,Japanese,Korean,Korean,Latvian,Lithuanian,Macedonian,Malaysian,Maltese,Norwegian,Polish,Portuguese,Rhaeto-Romanic,Romanian,Romanian,Russian,Russian,Sami,Serbian,Serbian,Slovak,Slovenian,Spanish,Sutu,Swedish,Swedi,Thai,Tsonga,Tswana,Turkish,Ukrainian,Urdu,Venda,Vietnamese,Xhosa,Yiddish,Zulu";
	
	$pat[0] = "/^\s+/";
	$pat[1] = "/\s{2,}/";
	$pat[2] = "/\s+\$/";
	$rep[0] = "";
	$rep[1] = " ";
	$rep[2] = "";

	$passwords = "";
	foreach($html->find('div[class="text"]') as $div) {
  	if (!(stripos($div->plaintext,"password")===false)) {
			$passwords .= $div->plaintext."\n";
  	}
	}	
	
	$name = $html->find('meta[name="description"]');
	$name = $name[0]->getAttribute('content');
	$name = htmlspecialchars_decode($name);
	$name = str_replace("&quot;",'"',$name);
	
	$remove = array();
	$remove[] = "#opaco";
	$remove[] = "#popup";
	$remove[] = "#popup_complain";
	$remove[] = 'div[class="file-express"]';
	$remove[] = "#comments";
	$remove[] = "#comment-form";
	$remove[] = "#add-comment-link-container";
	$remove[] = "span";
	$remove[] = "table";
	$remove[] = 'div[class="crutch-main"]';
	$remove[] = 'div[class="actions hidden"]';
	$remove[] = 'div[class="info-with-margin"]';

	foreach($html->find('#main-info-container') as $bookInfo) { //for each heading
	  foreach($remove as $element) {
	    foreach($bookInfo->find($element) as $e) {
	      $e->outertext = '';
	    }
	  }
	}

	$ret['url'] = $url;
	$ret['htmlName'] = $htmlName;
	         
	$ret['title'] = popInfo($bookInfo, 'h1');
	popInfo($bookInfo, 'div[class="title"]');
	$ret['title2'] = "";

	$ret['searchString'] = $ret['title'];
	
	$e = $bookInfo->find('div[class="image"]',0)->find('img',0)->src;
	$ret['image'] = $e;
	popInfo($bookInfo, 'div[class="image"]');

	$ret['text'] = popInfo($bookInfo, 'div[class="text clear-both"]');
	$ret['text'] = str_replace("<div class=\"center\"><b>Download links:</b></div>","",$ret['text']);
	$ret['text'] = str_replace("<div class=\"center\"><b>Download:</b></div>","",$ret['text']);
	$ret['text'] = str_replace("<div class=\"justify\">","",$ret['text']);
	
	$b = str_get_html($ret['text']);
	$e = $b->find('div',0);

  if (isset($name) and !empty($name)) {
		$items = explode(",",$name);
		$ret['author'] = $items[0];
		$items = explode('"',$name);
		$name = $items[1];
		$ret['title2'] = $ret['author']." - ".$ret['title'];
		$ret['name'] = $name;
  } else if ($ret['name'] != $ret['title'] and !(stripos($ret['name'],$ret['title']) === false)) {
		$i = stripos($ret['name'],$ret['title']);
		$ret['author'] = trim(substr($ret['name'],$i+strlen($ret['title'])+1));
		$ret['name'] = $ret['title'];
		$i = stripos($ret['author'],"BY");
		if (!($i === false) and $i === 0) {
			$ret['author'] = trim(substr($ret['author'],2));
		}
  } else {
 		$ret['author'] = $ret['name'];
  }
 	
	$ret['info'] = $e->innertext;
	$ret['info'] = brTrim($ret['info']);
	popInfo($b, 'div');
	$ret['text'] = $b;
	$ret['text'] = str_replace("</div>","",$ret['text']);
	$ret['text'] = $ret['info']."\n\n".$ret['text'];
	$ret['info'] = removeBold(Trim($ret['info']));
	$ret['text'] = html2bbcode(Trim($ret['text']));
	$ret['text'] = bTrim($ret['text']);
	$ret['text'] = str_replace("[/b]", "[/b]\n", $ret['text']);
	$ret['text'] = trimLines($ret['text']);
	$ret['text'] = str_replace("\n\n\n", "\n\n", $ret['text']);

	$info = explode('|', $ret['info']);

	$ret["tags"] = "nonfiction";
	
	foreach($info as $value) {
		$value = trim($value);
		$i1 = stripos($value,"ISBN");
		$i2 = stripos($value,"PAGES");
		$i3 = stripos($languages,$value);
		$i4 = stripos($value,"PDF");
		$i5 = stripos($value,"EPUB");
		$i6 = stripos($value,"MOBI");
		if (!($i1 === false)) {
			$ret["isbn"] = trim(substr($value,$i1+4+1));
		} else if (!($i2 === false)) {
			$ret["pages"] = trim(substr($value, 0, $i2-1));
		} else if (!($i3 === false)) {
			$ret["language"] = $value;
		} else if (!($i4 === false) or !($i5 === false) or !($i6 === false)) {
			$ret["formats"] = $value;
		} else {
			$value = str_replace("(","",$value);
			$value = str_replace(")","",$value);
			$value = str_replace(",","",$value);
			$value = str_replace(";","",$value);
			$parts = explode(" ", $value);
			foreach($parts as $part) {
				if ($part >= 1922 and $part <= 2012) {
					$ret["year"] = $part;
				}
			}
		}
	}

	$ret['text'] = str_replace('| '.$ret["formats"].' |', '| <FORMAT> |', $ret['text']);
	
	$b = str_get_html($bookInfo);
	$x=0;
	$links = "";
	while(true) {
		$e = $b->find('a',$x);
		if(!empty($e)) {
			if(!empty($e->href)) {
				$links .= $e->href . "\n";
				$b->find('a',0)->outertext = "";
			}
			$x++;
		} else {
			break;
		}
		if ($x > 100) { break; }
	}

	$ret['tags'] = normalizetags(parseTagsFromURL($ret['tags'], $url));
	$ret['links'] = $links;
	$ret['torrentName'] = normalizeFileName($ret['title']." (".$ret['year'].")");
	$ret['uploaded'] = "";
	$ret['torrentFiles'] = "";
	$ret['downloadedFileName'] = findDownloadedFileName($ret);
	$ret['passwords']= $passwords;

  $ret = cleanUP($ret);
  return $ret;
}

function cleanUP($ret) {
	foreach($ret as $index => $data) {
		$ret[$index] = str_replace("(Repost)", "", $data);
	}
	return $ret;
}

function findDownloadedFileName($ret) {
	global $formats, $workingFolder;

	foreach($formats as $format) {
		$files[] = $ret['torrentName'].".$format";
		$files[] = $ret['htmlName'].".$format";
		$files[] = $ret['title'].".$format";
		$files[] = $ret['title2'].".$format";
	}
	foreach($files as $file) {
		if(file_exists("$workingFolder/$file")) {
			return $file;
		}
	}
	return false;
}

function trimLines($text) {
	$lines = explode("\n",$text);
	foreach($lines as $index => $data) {
		$lines[$index] = trim($data);
	}
	$text = implode("\n",$lines);
	return $text;
}

function popInfo(&$html, $element) {
  $e = $html->find($element, 0);
  if ($e) {
    $ret = $e->innertext;
    $e->outertext = '';
  } else {
    $ret = 'not found';  
  }
  return $ret;
}

function brTrim($s) {
	$s = str_replace("<br />", "", $s);
	$s = str_replace("<br/>", "", $s);
	$s = str_replace("<br>", "", $s);
	$s = trim($s);
	return $s;
}

function removeBold($s) {
	$s = str_replace("<b>", "", $s);
	$s = str_replace("</b>", "", $s);
	return $s;
}
function bTrim($s) {
	$s = str_replace(" <b> ", "<b>", $s);
	$s = str_replace("<b> ", "<b>", $s);
	$s = str_replace(" </b>", "</b>", $s);
	$s = str_replace(" </b> ", "</b>", $s);
	$s = str_replace(" [b] ", "[b]", $s);
	$s = str_replace("[b] ", "[b]", $s);
	$s = str_replace(" [/b]", "[/b]", $s);
	$s = str_replace(" [/b] ", "[/b]", $s);
	$s = trim($s);
	return $s;
}

function brReplace($s) {
	if(isset($s)) {
		if (is_string($s)) {
			$s = str_replace("<br />", "\n", $s);
			$s = str_replace("<br/>", "\n", $s);
			$s = str_replace("<br>", "\n", $s);
			$s = trim($s);
		}
	}
	return $s;
}

function showURLForm($url) {?>
	<form method="post">
		<input type="text" name="url" value="<?=$url?>" size="150"><br>
		<input type="submit" id="buttonParse" name="submit" value="Parse">
	</form>
<?}

function openHTML() {
	?><html><body><font face="arial"><?
}

function addToLog($newLog) {
	global $log;
	
	$log[] = $newLog;
}

function closeHTML() {
	global $log;
	
	if (isset($log) and count($log) > 0) {
		__p('"<div class="log">');
		__pa($log);
		__p('"</div>');
	}
	?></font></body></html><?
}


function xml2array($contents, $get_attributes=1, $priority = 'tag') { 
    if(!$contents) return array(); 

    if(!function_exists('xml_parser_create')) { 
        //print "'xml_parser_create()' function not found!"; 
        return array(); 
    } 

    //Get the XML parser of PHP - PHP must have this module for the parser to work 
    $parser = xml_parser_create(''); 
    xml_parser_set_option($parser, XML_OPTION_TARGET_ENCODING, "UTF-8"); # http://minutillo.com/steve/weblog/2004/6/17/php-xml-and-character-encodings-a-tale-of-sadness-rage-and-data-loss 
    xml_parser_set_option($parser, XML_OPTION_CASE_FOLDING, 0); 
    xml_parser_set_option($parser, XML_OPTION_SKIP_WHITE, 1); 
    xml_parse_into_struct($parser, trim($contents), $xml_values); 
    xml_parser_free($parser); 

    if(!$xml_values) return;//Hmm... 

    //Initializations 
    $xml_array = array(); 
    $parents = array(); 
    $opened_tags = array(); 
    $arr = array(); 

    $current = &$xml_array; //Refference 

    //Go through the tags. 
    $repeated_tag_index = array();//Multiple tags with same name will be turned into an array 
    foreach($xml_values as $data) { 
        unset($attributes,$value);//Remove existing values, or there will be trouble 

        //This command will extract these variables into the foreach scope 
        // tag(string), type(string), level(int), attributes(array). 
        extract($data);//We could use the array by itself, but this cooler. 

        $result = array(); 
        $attributes_data = array(); 
         
        if(isset($value)) { 
            if($priority == 'tag') $result = $value; 
            else $result['value'] = $value; //Put the value in a assoc array if we are in the 'Attribute' mode 
        } 

        //Set the attributes too. 
        if(isset($attributes) and $get_attributes) { 
            foreach($attributes as $attr => $val) { 
                if($priority == 'tag') $attributes_data[$attr] = $val; 
                else $result['attr'][$attr] = $val; //Set all the attributes in a array called 'attr' 
            } 
        } 

        //See tag status and do the needed. 
        if($type == "open") {//The starting of the tag '<tag>' 
            $parent[$level-1] = &$current; 
            if(!is_array($current) or (!in_array($tag, array_keys($current)))) { //Insert New tag 
                $current[$tag] = $result; 
                if($attributes_data) $current[$tag. '_attr'] = $attributes_data; 
                $repeated_tag_index[$tag.'_'.$level] = 1; 

                $current = &$current[$tag];

            } else { //There was another element with the same tag name 

                if(isset($current[$tag][0])) {//If there is a 0th element it is already an array 
                    $current[$tag][$repeated_tag_index[$tag.'_'.$level]] = $result; 
                    $repeated_tag_index[$tag.'_'.$level]++; 
                } else {//This section will make the value an array if multiple tags with the same name appear together 
                    $current[$tag] = array($current[$tag],$result);//This will combine the existing item and the new item together to make an array 
                    $repeated_tag_index[$tag.'_'.$level] = 2; 
                     
                    if(isset($current[$tag.'_attr'])) { //The attribute of the last(0th) tag must be moved as well 
                        $current[$tag]['0_attr'] = $current[$tag.'_attr']; 
                        unset($current[$tag.'_attr']); 
                    } 

                } 
                $last_item_index = $repeated_tag_index[$tag.'_'.$level]-1; 
                $current = &$current[$tag][$last_item_index]; 
            } 

        } elseif($type == "complete") { //Tags that ends in 1 line '<tag />' 
            //See if the key is already taken. 
            if(!isset($current[$tag])) { //New Key 
                $current[$tag] = $result; 
                $repeated_tag_index[$tag.'_'.$level] = 1; 
                if($priority == 'tag' and $attributes_data) $current[$tag. '_attr'] = $attributes_data; 

            } else { //If taken, put all things inside a list(array) 
                if(isset($current[$tag][0]) and is_array($current[$tag])) {//If it is already an array... 

                    // ...push the new element into that array. 
                    $current[$tag][$repeated_tag_index[$tag.'_'.$level]] = $result; 
                     
                    if($priority == 'tag' and $get_attributes and $attributes_data) { 
                        $current[$tag][$repeated_tag_index[$tag.'_'.$level] . '_attr'] = $attributes_data; 
                    } 
                    $repeated_tag_index[$tag.'_'.$level]++; 

                } else { //If it is not an array... 
                    $current[$tag] = array($current[$tag],$result); //...Make it an array using using the existing value and the new value 
                    $repeated_tag_index[$tag.'_'.$level] = 1; 
                    if($priority == 'tag' and $get_attributes) { 
                        if(isset($current[$tag.'_attr'])) { //The attribute of the last(0th) tag must be moved as well 
                             
                            $current[$tag]['0_attr'] = $current[$tag.'_attr']; 
                            unset($current[$tag.'_attr']); 
                        } 
                         
                        if($attributes_data) { 
                            $current[$tag][$repeated_tag_index[$tag.'_'.$level] . '_attr'] = $attributes_data; 
                        } 
                    } 
                    $repeated_tag_index[$tag.'_'.$level]++; //0 and 1 index is already taken 
                } 
            } 

        } elseif($type == 'close') { //End of tag '</tag>' 
            $current = &$parent[$level-1]; 
        } 
    } 
     
    return($xml_array); 
}  

function html2bbcode($text) {
	$htmltags = array(
		'/\<b\>(.*?)\<\/b\>/is',
		'/\<i\>(.*?)\<\/i\>/is',
		'/\<u\>(.*?)\<\/u\>/is',
		'/\<ul.*?\>(.*?)\<\/ul\>/is',
		'/\<li\>(.*?)\<\/li\>/is',
		'/\<img(.*?) src=\"(.*?)\" alt=\"(.*?)\" title=\"Smile(y?)\" \/\>/is',		// some smiley
		'/\<img(.*?) src=\"http:\/\/(.*?)\" (.*?)\>/is',
		'/\<img(.*?) src=\"(.*?)\" alt=\":(.*?)\" .*? \/\>/is',						// some smiley
		'/\<div class=\"quotecontent\"\>(.*?)\<\/div\>/is',	
		'/\<div class=\"codecontent\"\>(.*?)\<\/div\>/is',	
		'/\<div class=\"quotetitle\"\>(.*?)\<\/div\>/is',	
		'/\<div class=\"codetitle\"\>(.*?)\<\/div\>/is',
		'/\<cite.*?\>(.*?)\<\/cite\>/is',
		'/\<blockquote.*?\>(.*?)\<\/blockquote\>/is',
		'/\<div\>(.*?)\<\/div\>/is',
		'/\<code\>(.*?)\<\/code\>/is',
		'/\<br(.*?)\>/is',
		'/\<strong\>(.*?)\<\/strong\>/is',
		'/\<em\>(.*?)\<\/em\>/is',
		'/\<a href=\"mailto:(.*?)\"(.*?)\>(.*?)\<\/a\>/is',
		'/\<a .*?href=\"(.*?)\"(.*?)\>http:\/\/(.*?)\<\/a\>/is',
		'/\<a .*?href=\"(.*?)\"(.*?)\>(.*?)\<\/a\>/is'
	);

	$bbtags = array(
		'[b]$1[/b]',
		'[i]$1[/i]',
		'[u]$1[/u]',
		'[list]$1[/list]',
		'[*]$1',
		'$3',
		'[img]http://$2[/img]',
		':$3',
		'\[quote\]$1\[/quote\]',
		'\[code\]$1\[/code\]',
		'',
		'',
		'',
		'\[quote\]$1\[/quote\]',
		'$1',
		'\[code\]$1\[/code\]',
		"\n",
		'[b]$1[/b]',
		'[i]$1[/i]',
		'[email=$1]$3[/email]',
		'[url]$1[/url]',
		'[url=$1]$3[/url]'
	);

	$text = str_replace ("\n", ' ', $text);
	$ntext = preg_replace ($htmltags, $bbtags, $text);
	$ntext = preg_replace ($htmltags, $bbtags, $ntext);

	// for too large text and cannot handle by str_replace
	if (!$ntext) {
		$ntext = str_replace(array('<br>', '<br />'), "\n", $text);
		$ntext = str_replace(array('<strong>', '</strong>'), array('[b]', '[/b]'), $ntext);
		$ntext = str_replace(array('<em>', '</em>'), array('[i]', '[/i]'), $ntext);
	}

	$ntext = strip_tags($ntext);
	$ntext = trim(html_entity_decode($ntext,ENT_QUOTES,'UTF-8'));
	return $ntext;
}

function normalizeFileName($fileName) {
	$fileName = str_replace(":", " - ", $fileName);
	$fileName = str_replace("  ", " ", $fileName);
	return $fileName;
}

?>