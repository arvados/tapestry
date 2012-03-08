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

}).call(this);
