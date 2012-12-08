// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults

jQuery(document).ready(function($) {

    $("#user_file_data_type").change(function() {
	if ($(this).val() === 'other') {
            return $("#other_data_type_div").show();
	} else {
            return $("#other_data_type_div").hide();
	}
    }).trigger('change');

    // Kick dataTables so it refilters after the user cuts or pastes in
    // the search box (i.e., changes val without using the keyboard).
    $(document).delegate('.dataTables_filter input', 'paste cut', function(e, ui) {
	$(this).trigger('keyup', [ui]);
    });

    var hidsome = false;
    $('div.user-dashboard-summary>*').each(function() {
	if ($(this).find('.highlight-nextstep').length == 0) {
	    $(this).hide();
	    if (!hidsome) {
		hidsome = true;
		var $showall = $('<a href="#">more info / options</a>').click(function(){
		    $(this).parents('div.user-dashboard-summary').first().children().show();
		    $(this).parent().hide();
		});
		$(this).parent().append($showall.wrap('<div class="show-more-container" />').parent());
	    }
	}
    });

    if ($('tr[data-file-row]').length > 0) {
	// Hide all files in multi-file manifests
	$('tr[data-file-row][data-locator][data-index-in-manifest]').
	    filter("[data-index-in-manifest!='']").
	    hide();
	// Make sure the first file in each manifest is showing
	$('tr[data-file-row][data-locator][data-index-in-manifest]').
	    not("[data-index-in-manifest='']").
	    each(function() {
	    var collapse_row;
	    var locator = $(this).attr('data-locator');
	    if (locator == "") return $(this).show();
	    if ($('tr[data-collection-row][data-locator="'+locator+'"]').length > 0)
		return;
	    var trs = $('tr[data-locator="' + locator + '"]');
	    if (trs.length > 1) {
		collapse_row = trs.first().clone();
		collapse_row.attr('data-collection-row', trs.length);
		trs.first().before(collapse_row);
		// Make sure all rows from the same manifest are contiguous
		trs.first().after(trs.filter(':gt(0)').detach());
		// Remove the horizontal grid lines between files within a manifest
		trs.children('td').css('border-top','none');
		collapse_row.children('td').each(function(i,e) {
		    var s = $(this).attr('data-summarize-as');
		    var values = trs.map(function(){return $(this).find('td').eq(i).html()}).get();
		    var unique_values = values.filter(function(x,i,a){
			return i==a.indexOf(x);
		    });
		    if (s == 'size') {
			var size = 0;
			trs.each(function() {
			    size += parseInt($(this).attr('data-file-size'));
			});
			$(this).html(number_to_human_size(size));
		    }
		    else if (s == 'list-distinct')
			$(this).html(unique_values.join("<br />"));
		    else if (s == 'name')
			$(this).html('<span style="cursor:pointer;text-decoration:underline" class="click-to-expand-collection">'+trs.length+' files (click to expand)</span>');
		    else if (s == 'none')
			$(this).html('');
		});
		collapse_row.show();
		// Remove inside horizontal cell borders
		trs.children('td').css('border-top','none');
		trs.not(':last').children('td').css('border-bottom','none');
		collapse_row.
		    attr('data-save-border-bottom',
			 collapse_row.children('td').css('border-bottom'));
	    } else {
		trs.show();
	    }
	});
	// Add a "show more" button in the first column where needed
	$('tr[data-file-row][data-collection-row]').each(function() {
	    var colspan = $(this).children('td').length;
	    var locator = $(this).attr('data-locator');
	    var nfiles = $(this).attr('data-collection-row');
	    $(this).
		children('td').
		first().
		css('text-align','center').
		append('<div style="width:16px;height:16px;padding:4px;margin:0;cursor:pointer" class="ui-widget ui-state-default ui-corner-all click-to-expand-collection" title="Show all ' + nfiles + ' files in this collection"><span class="ui-icon ui-icon-plusthick"></span></div>');
	});
	// Toggle the non-first rows when "show more" is clicked
	$('tr[data-file-row][data-locator]').delegate('.click-to-expand-collection', 'click', function() {
	    var tr = $(this).parents('tr').first();
	    var locator = tr.attr('data-locator');
	    var trs = $('tr[data-locator="' + locator + '"]').
		not('[data-collection-row]');
	    if (tr.find('.ui-icon.ui-icon-plusthick').length > 0) {
		trs.fadeIn();
		tr.children('td').css('border-bottom','none');
	    }
	    else {
		trs.fadeOut();
		tr.children('td').css('border-bottom',tr.attr('data-save-border-bottom'));
	    }
	    tr.find('.ui-icon').
		toggleClass('ui-icon-plusthick').
		toggleClass('ui-icon-minusthick');
	    return false;
	});
    }
    function number_to_human_size(x) {
	var u = 'B';
	var places = 0;
	if (x > 1000) { u = 'KB'; x = x / 1000; places = 1; }
	if (x > 1000) { u = 'MB'; x = x / 1000; places = 2; }
	if (x > 1000) { u = 'GB'; x = x / 1000; }
	if (x > 1000) { u = 'TB'; x = x / 1000; }
	x = ""+x.toFixed(places);
	return x+' '+u;
    }
});
