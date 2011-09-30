// -*- mode: js2; indent-tabs-mode: nil; -*-

var Renderer = {
    date_to_metric: function(x) {
        return ('x' + (x.getFullYear()+90000) + '-x' + (x.getMonth()+1+900) + '-x' + (x.getDate()+900)).replace(/x9/g, '');
    },
    fnGetData: function(oObj) {
        return oObj.oSettings.aoColumns[oObj.iDataColumn].fnGetData(oObj.aData);
    },
    hide_zeroes: function(oObj) {
        var x = Renderer.fnGetData(oObj);
        if (x == 0)
	    return '';
	return x;
    },
    yes_or_nothing: function(oObj) {
        var x = Renderer.fnGetData(oObj);
	if (x)
	    return 'Yes';
	return '';
    },
    date: function(oObj) {
        var x = Renderer.fnGetData(oObj);
	if (x)
	    return Renderer.date_to_metric(new Date(x));
	return '';
    }
};
