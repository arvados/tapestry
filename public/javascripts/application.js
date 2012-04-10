// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults


(function() {

  jQuery(function() {
    $("#user_file_data_type").change(function() {
      if ($(this).val() === 'other') {
        return $("#other_data_type_div").show();
      } else {
        return $("#other_data_type_div").hide();
      }
    }).trigger('change');
  });

  // Kick dataTables so it refilters after the user cuts or pastes in
  // the search box (i.e., changes val without using the keyboard).
  (function($) {
    $(document).delegate('.dataTables_filter input', 'paste cut', function(e, ui) {
      $(this).trigger('keyup', [ui]);
    });
  })(jQuery);

}).call(this);
