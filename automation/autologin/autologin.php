<?php
  ///
  ///  The Seedbox From Scratch  Script
  ///    By Notos ---> https://github.com/Notos/
  ///

  $login = new LOGIN;

  $login->loadConfiguration("../automation.ini");
  $login->loadTrackers("../trackers/");

  ///
  /// You have to edit ../automation.ini to configure this program
  ///
  ///
  ///
  /// Password file format:
  ///
  ///  <delimiter><tracker><delimiter><usermame><delimiter><password><delimiter>
  ///
  /// Examples:
  ///
  ///  |bibliotik|Notos|C0chusuxu!ru|
  ///  :what.cd:Notos:C0chusuxu!ru:
  ///  @btn@Notos@C0chusuxu!ru@
  ///
  /// You choose what delimiter to use, it can be different from line to line
  ///

  print $login->login();

// --------------------------------------------------------------------------------------------------------------------

  class LOGIN {
		private $output;
		private $trackers;
		private $passwords;
    private $configuration;

		function __construct() {
    	/// "In BaseClass constructor<br>";
		}

		private function checkEnvironment() {
      __pa($this->configuration);
      
			$result = true;
			if (empty($this->configuration['logDir'])) {
				$this->addToOutput("Error: logDir variable is empty.");
				$result = false;
			} else {
				if (!is_dir($this->configuration['logDir'])) {
					$this->addToOutput("Error: logDir '$this->configuration['logDir']' does not exists.");
					$result = false;
				} else {
					if (!is_writable($this->configuration['logDir'])) {
						$this->addToOutput("Error: logDir '$this->configuration['logDir']' is not writable.");
						$result = false;
					}
				}
			}

			if (empty($this->configuration['passwordFile'])) {
				$this->addToOutput("Error: passwordFile variable is empty.");
				$result = false;
			} else if (!file_exists($this->configuration['passwordFile'])) {
				$this->addToOutput("Error: passwordFile '$this->configuration['passwordFile']' does not exists.");
				$result = false;
			}

			return $result;
		}
		
		private function readPasswords() {
			$this->passwords = array();
			$a = file($this->configuration['passwordFile']);
			foreach($a as $line) {
				if(empty($line)) {
					continue;
				}
				$delim = substr($line,0,1);
				$fields = explode($delim, $line);
				$this->passwords[$fields[1]]['username'] = $fields[2];
				$this->passwords[$fields[1]]['password'] = $fields[3];
			}

			if (count($this->configuration['passwordFile']) == 0) {
				$this->addToOutput("Error: passwordFile is not readable or is empty.");
				return false;
			}
			
			return true;
		}
		
		private function writeToFile($string, $file = '/tmp/server.log') {
  		if( $fh = fopen($file, 'a') ) {
  			fwrite($fh, $string."\n");
  			fclose($fh);
  		} else {
				return false;
  		}
			return true;
		}
		
		private function addToOutput($string) {
			$string = date("Y-m-d H:i:s") . " - " . $string;  
			$this->output .= $string;
			if ($this->configuration['outputFormat'] == "html") {
				$this->output .= "<br />";
			} else {
				$this->output .= "\n";
			}
		}
		
		private function getOutput() {
			if ( $this->configuration['outputFormat'] != 'none' ) {
				return $this->output;
			}
		}

		private function loginTracker($tracker, $data) {
			$postData = array();
			if(!isset($this->passwords[$tracker])) {
				$this->addToOutput("$tracker: username and password not found.");
				return false;
			}
			$postData[$data['logiUsernameField']] = $this->passwords[$tracker]['username'];
			$postData[$data['logiPasswordField']] = $this->passwords[$tracker]['password'];
			
			$postData = $this->getExtrafields($tracker,$postData);

			$cookie = str_replace("<tracker>", $tracker, $this->configuration['cookieFile']);
			
			$response = $this->surf($data['loginURL'], $postData, $cookie);

			if(!(stripos($response,$data['loggedInString'])===false)) {
				return true;
			}
			
			return false;
		}
		
		private function surf($url, $postData = array(), $cookiesFile = "", $userAgent = "") {
			if (file_exists($cookiesFile)) {
				unlink($cookiesFile);
			}
			if (!file_exists($cookiesFile) and !empty($cookiesFile)) {
				touch($cookiesFile);
			}

			$ch = curl_init();
			
			$headers[] = "Accept: */*";
			$headers[] = "Connection: Keep-Alive";
			
			curl_setopt($ch, CURLOPT_HTTPHEADER,  $headers);
			curl_setopt($ch, CURLOPT_HEADER,  0);
			curl_setopt($ch, CURLOPT_SSL_VERIFYHOST, 0);
			curl_setopt($ch, CURLOPT_SSL_VERIFYPEER, false);
			curl_setopt($ch, CURLOPT_USERAGENT, !empty($userAgent) ? $userAgent : "ZMozilla/5.0 (Windows NT 6.1; WOW64; rv:13.0) Gecko/20100101 Firefox/13.4"); 
			curl_setopt($ch, CURLOPT_RETURNTRANSFER, 1); 
			curl_setopt($ch, CURLOPT_FOLLOWLOCATION, 1); 
			
			if (!empty($cookiesFile)) {
				curl_setopt($ch, CURLOPT_COOKIEFILE, $cookiesFile);
				curl_setopt($ch, CURLOPT_COOKIEJAR, $cookiesFile);
			}

			if (count($postData) > 0) {
				curl_setopt($ch, CURLOPT_POSTFIELDS, http_build_query($postData)); 
			}

			curl_setopt($ch, CURLOPT_URL, $url);
			curl_setopt($ch, CURLOPT_POST, 1); 
			
			$response = curl_exec($ch);
			if (curl_errno($ch)) {
				__p("CURL Error: ".curl_errno($ch)." = ".curlError(curl_errno($ch)));
			}
		  curl_close($ch);

		  //$this->addToOutput($response);
		  
		  //__p($response);
		  return $response;
		}

		private function getExtrafields($tracker,$post) {
			foreach($this->trackers[$tracker] as $index => $field) {
				if (!(stripos($index,"extraField")===false)) {
					$a = explode("-",$index);
					$post[$a[1]] = $field;
				}
			}
			
			return $post;
		}

		public function login() {
			if ( !$this->checkEnvironment() ) {
				return $this->getOutput();
			}

			if (! $this->readPasswords() ) {
				return $this->getOutput();
			}
			
			foreach($this->trackers as $tracker => $data) {
				if ($this->loginTracker($tracker, $data)) {
					$this->addToOutput("$tracker: login successful.");
				} else {
					$this->addToOutput("$tracker: ERROR TRYING TO LOGIN.");
				}
			}
			$this->addToOutput("end of run.");
			
			return $this->output;
		}

    public function loadTrackers($folder) {
      $this->trackers = array();
    	$files = scandir($folder);
    	foreach($files as $file) {
    		if(preg_match('/.*\.tracker.ini$/', $file)) {
    			$ini = parse_ini_file($folder.'/'.$file, true); // with sections
          $this->trackers = array_merge($this->trackers, $ini);
    		}
    	}
    }

    public function loadConfiguration($file) {
      $this->configuration = parse_ini_file($file); // no sections
    }
  }

  function __p($s) {
    print $s."<br>";
  }
  function __pa($s) {
    print "<pre>";
    print_r($s);
    print "</pre>";
  }
?>
