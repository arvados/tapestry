// -*- mode: java; c-basic-offset: 2; tab-width: 4; indent-tabs-mode: nil; -*-

jQuery(function($){
    $('table.plate_layout').each(function(){
        $this = $(this);
        $.each($this.attr('class').split(' '), function(i,c){
            ncolumns = /^has(\d+)columns$/.exec(c);
            if (ncolumns)
              $('td', $this).css('width', ''+(100.0/ncolumns[1])+'%');
          });
        $('td.next_available[plate_layout_position]', this).each(function(){
            $(this).html($(this).attr('plate_layout_position'));
          });
      });
    // $('div.tabsme').tabs();
    // $('div.buttons input[type=submit],div.buttons button').button();
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
