jQuery(function($){
	$.each($('table.plate_layout').attr('class').split(' '), function(i,c){
		ncolumns = /^(\d+)columns$/.exec(c);
		if (ncolumns)
		    $('table.plate_layout.'+c+' td').css('width', ''+(100.0/ncolumns[1])+'%').css('height','1.4em');
	    });
	// $('div.tabsme').tabs();
	// $('div.buttons input[type=submit],div.buttons button').button();
	$('.launch_scanner').click(function(){
		if (/Linux.*Android/.exec(navigator.userAgent))
		    window.location = 'http://zxing.appspot.com/scan';
		else
		    alert("Sorry, I can't launch your bar code scanner from here -- you have to open it manually to proceed.")
		return false;
	    });
    });
