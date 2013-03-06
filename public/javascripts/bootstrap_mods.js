jQuery(function(){
    var $ = jQuery;
    $('.dropdown-toggle').parent('.dropdown').on('hover', function(e) {
        if (!$(this).hasClass('open') &&
            $(this).parents('.nav').children('.dropdown.open').length > 0) {
            $(this).parents('.nav').children('.dropdown.open').click();
            $(this).find('a:first').click();
        }
    });
});
