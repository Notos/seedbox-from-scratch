<?php

$fm['tempdir'] = '/tmp';		// path were to store temporary data ; must be writable 
$fm['mkdperm'] = 755; 		// default permission to set to new created directories

// set with fullpath to binary or leave empty
$pathToExternals['rar'] = '';
$pathToExternals['zip'] = '';
$pathToExternals['unzip'] = '';
$pathToExternals['tar'] = '';


// archive mangling, see archiver man page before editing

$fm['archive']['types'] = array('rar', 'zip', 'tar', 'gzip', 'bzip2');




$fm['archive']['compress'][0] = range(0, 5);
$fm['archive']['compress'][1] = array('-0', '-1', '-9');
$fm['archive']['compress'][2] = $fm['archive']['compress'][3] = $fm['archive']['compress'][4] = array(0);




?>