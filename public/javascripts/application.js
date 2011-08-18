// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults

// plates setup
jQuery(function($){
	$.each($('table.plate_layout').attr('class').split(' '), function(i,c){
		ncolumns = /^(\d+)columns$/.exec(c);
		if (ncolumns)
		    $('table.plate_layout.'+c+' td').css('width', ''+(100.0/ncolumns[1])+'%');
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
	$('table.plate-samples').each(function() {
		t = $(this).show().
		    dataTable({bJQueryUI: true, bSort: false, sScrollY: '222px', bPaginate: false, bAutoWidth: false});
		$wrapper = $(t).parents('.dataTables_wrapper').first();
		$wrapper.find('.dataTables_filter').css('width', '70%');
		$wrapper.find('.dataTables_info').css('width', '90%');
		$('tr', $wrapper).hover(function(){
			$('td[plate_layout_position='+$(this).attr('plate_layout_position')+']').html('<b>'+$(this).attr('plate_layout_position')+'</b>').css('color', '#fff');
		    }, function(){
			$('td[plate_layout_position='+$(this).attr('plate_layout_position')+']').html('');
		    });
	    });
    });
