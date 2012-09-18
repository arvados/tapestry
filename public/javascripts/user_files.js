jQuery(document).ready(function($) {
    $('#user_file_data_type').change(function(){
        $('[data-type-advice]').hide();
        $('div.data-type-advice-container').show();
        $('[data-type-advice="' + $(this).val() + '"]').show();
    }).trigger('change');
});
