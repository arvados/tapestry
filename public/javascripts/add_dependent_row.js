// -*- mode: js2; tab-width: 4; indent-tabs-mode: nil; -*-

// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults

jQuery(function(){
    var $ = jQuery.noConflict();
    $('form a.add_child').click(function() {
        var association = $(this).attr('data-association');
        var append_to_selector = $(this).attr('append-to-selector');
        var template = $('#' + association + '_fields_template').text();
        var regexp = new RegExp('new_' + association, 'g');
        var new_id = new Date().getTime();

        var $x = $(template.replace(regexp, new_id)).appendTo(append_to_selector);
        var max = 0;
        $(append_to_selector + ' input[id$=_sort_order]').each(function(i,e) {
                var val = parseInt($(e).attr('value'));
                if(val > max)
                    max = val;
            });
        $('input[id$=_sort_order]', $x).attr('value', max + 1);
        rewrite_sort_orders($(append_to_selector));
        return false;
      });
    $('form a.remove_child').live('click', function() {
        var hidden_field = $(this).prev('input[type=hidden]')[0];
        if(hidden_field) {
            hidden_field.value = '1';
        }
        $(this).parents('.fields').hide();
        return false;
      });
    $('.row_move_up').live('click', function() {
        var $tr = $(this).closest('tr');
        $tr.insertBefore($tr.prevAll('tr').first());
        rewrite_sort_orders($tr.closest('table,tbody'));
        return false;
    });
    $('.row_delete').live('click', function() {
        var $tr = $(this).closest('tr');
        var $table = $tr.closest('table,tbody');
        var $destroyer = $(this).siblings().find('input[type=checkbox][id$=__destroy]');
        var ok = false;
        var $form = $(this).closest('form');
        $.each($destroyer, function() {
            $form.append('<input type=hidden id="'+$destroyer.attr('id')+'" name="'+$destroyer.attr('name')+'" value="1" />');
            ok = true;
        });
        if (ok) {
            $tr.remove();
            rewrite_sort_orders($table);
        }
        else
            alert ("Oops, I couldn't figure out how to delete that item.");
        return false;
    });
    function rewrite_sort_orders(selection) {
        var n=1;
        selection.find('input[id$=_sort_order]').each(function(){
            $(this).attr('value',''+n);
            n=n+1;
        });
        selection.find('.row_move_up').show();
        selection.find('.row_move_up').first().hide();
    }
    rewrite_sort_orders($(body));
});
