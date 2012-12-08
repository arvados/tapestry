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
	$('tr[data-file-row][data-locator][data-index-in-manifest]').each(function() {
	    var locator = $(this).attr('data-locator');
	    if (locator == "") return $(this).show();
	    var trs = $('tr[data-locator="' + locator + '"]');
	    trs.first().show();
	    if (trs.length > 1) {
		trs.first().attr('data-file-row-needs-showmore', trs.length);
		// Make sure all rows from the same manifest are contiguous
		trs.first().after(trs.filter(':gt(0)').detach());
		// Remove the horizontal grid lines between files within a manifest
		trs.filter(':gt(0)').children('td').css('border-top','none');
	    }
	});
	// Add a "show more" button in the first column where needed
	$('tr[data-file-row][data-file-row-needs-showmore]').each(function() {
	    var colspan = $(this).children('td').length;
	    var locator = $(this).attr('data-locator');
	    var nfiles = $(this).attr('data-file-row-needs-showmore');
	    $(this).
		children('td').
		first().
		css('text-align','center').
		append('<div style="width:16px;height:16px;padding:4px;margin:0;cursor:pointer" data-locator="' + locator + '" class="ui-widget ui-state-default ui-corner-all" title="Show all ' + nfiles + ' files in this collection"><span class="ui-icon ui-icon-plusthick"></span></div>(' + nfiles + ')');
	});
	// Toggle the non-first rows when "show more" is clicked
	$('tr[data-file-row][data-locator] td:first').delegate('div.ui-widget', 'click', function() {
	    var locator = $(this).attr('data-locator');
	    var trs = $('tr[data-locator="' + locator + '"]');
	    trs.filter('[data-index-in-manifest]:gt(0)').toggle();
	    $(this).find('.ui-icon').
		toggleClass('ui-icon-plusthick').
		toggleClass('ui-icon-minusthick');
	    // Remove cell bottom borders
	    trs.children('td').css('border-bottom','1px solid #ccc');
	    trs.filter(':visible').not(':last').children('td').css('border-bottom','none');
	    return false;
	});
    }
});
