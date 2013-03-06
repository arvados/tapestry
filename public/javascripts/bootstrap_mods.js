jQuery(function(){
    var $ = jQuery;

    // Change bootstrap dropdown menu behavior.  When a menu dropdown
    // is active, hovering on a second menu in the same nav bar should
    // cause the second menu to open.  (This is how menus work in
    // desktop applications, so it is less surprising to users.  It
    // also allows users to scan the menus quickly without a lot of
    // clicking.)
    $('.dropdown-toggle').parent('.dropdown').on('hover', function(e) {
        if (!$(this).hasClass('open') &&
            $(this).parents('.nav').children('.dropdown.open').length > 0) {
            $(this).parents('.nav').children('.dropdown.open').click();
            $(this).find('a:first').click();
        }
    });
});
