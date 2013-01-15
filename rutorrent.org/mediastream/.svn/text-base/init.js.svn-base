
plugin.loadMainCSS();

theWebUI.VPLAY = {
		stp:  'plugins/mediastream/view.php',
		play: function(target) {

			theWebUI.fManager.action.request('action=sess', 
				function (data) { 
					if(theWebUI.fManager.isErr(data.errcode)) {log('Play failed'); return false;}
						theWebUI.fManager.makeVisbile('VPLAY_diag');
					try {
					  theWebUI.VPLAY.player.Open(theWebUI.VPLAY.stp+'?ses='+encodeURIComponent(data.sess)+'&action=view&dir='+encodeURIComponent(theWebUI.fManager.curpath)+'&target='+encodeURIComponent(target));
					} catch(err) { }
				});
		},

		stop: function() {try {this.player.Stop();} catch(err) { }}
}

plugin.flmMenu = theWebUI.fManager.flmSelect;
theWebUI.fManager.flmSelect = function( e, id ) {

		plugin.flmMenu.call(this, e, id);
		if(plugin.enabled) {

			var el = theContextMenu.get(theUILang.fOpen);
			var target = id.split('_flm_')[1];

			if(el && theWebUI.fManager.getExt(target).match(/^(mp4|avi|divx|mkv)$/i)) {
				theContextMenu.add(el,[CMENU_SEP]);
				theContextMenu.add(el,[theUILang.fView, function() {theWebUI.VPLAY.play(target);}]);
				theContextMenu.add(el,[CMENU_SEP]);
			}
		}
		
}

plugin.onLangLoaded = function() {
	
	injectScript('plugins/mediastream/settings.js.php');

	var pd = '<div class="cont fxcaret">'+
			'<object id="ie_plugin" classid="clsid:67DABFBF-D0AB-41fa-9C46-CC0F21721616" width="300" height="245" codebase="http://go.divx.com/plugin/DivXBrowserPlugin.cab">'+
 				'<param name="custommode" value="none" />'+
 				'<param name="previewImage" value="" />'+
 				'<param name="autoPlay" value="false" />'+
    				'<param name="src" value="" />'+
				'<embed id="np_plugin" type="video/divx" src="" custommode="none" width="300" height="245" autoPlay="false"  previewImage="" pluginspage="http://go.divx.com/plugin/download/"></embed>'+
			'</object></div>';

	theDialogManager.make('VPLAY_diag', theUILang.mediastream, pd, false);

	theWebUI.VPLAY.player = (browser.isIE) ? document.getElementById('ie_plugin') : document.getElementById('np_plugin');
	theDialogManager.setHandler('VPLAY_diag','afterHide', "theWebUI.VPLAY.stop()");
	

};

plugin.onRemove = function() {
	theWebUI.VPLAY.stop();
	$('#VPLAY_diag').remove();
}

plugin.loadLang(true);