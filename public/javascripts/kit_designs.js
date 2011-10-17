// -*- mode: js2; tab-width: 4; indent-tabs-mode: nil; -*-

jQuery(function(){
    var $ = jQuery.noConflict();
    $('.sample_type_autofill').live('change input', function() {
        var id_base = this.id.replace(/_nil$/,'');
        if (!$(this).attr('value')) return;
        $.ajax('/sample_types/'+$(this).attr('value'), {
                   'dataType': 'json',
                   'success': function(d,t,r) {
                       if(!d || !d.sample_type)
                           return false;
                       $.each(d.sample_type, function(i,e) {
                           if (i != 'id')
                               $('#'+id_base+'_'+i).attr('value',e);
                       });
                       $('#'+id_base+'_unit').attr('value',d.sample_type.unit.name);
                       $('#'+id_base+'_tissue').attr('value',d.sample_type.tissue_type.name);
                       $('#'+id_base+'_device').attr('value',d.sample_type.device_type.name);
                   }
               });
      });
});
