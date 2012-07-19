// -*- mode: java; tab-width: 4; indent-tabs-mode: nil; -*-

jQuery(function(){
    var $ = jQuery.noConflict();
    $('#apply_action').live('change', function() {
            $(this).parents('form:eq(0)').
                attr('action',$(this).attr('value'));
            $(this).parents('form:eq(0)').find('input:submit').
                attr('disabled', $(this).attr('value')=='');
        });
    $('#apply_action').parents('form:eq(0)').bind('click', function() {
            return !($(this).attr('action') == '');
        });
    $('#apply_action').trigger('change');
});
