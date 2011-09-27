// -*- mode: js2; indent-tabs-mode: nil; -*-

var Renderer = {
    date_to_metric: function(x) {
        return ('x' + (x.getFullYear()+90000) + '-x' + (x.getMonth()+1+900) + '-x' + (x.getDate()+900)).replace(/x9/g, '');
    },
    hide_zeroes: function(mDataProp) {
        return function(oObj) {
	    if (oObj.aData[mDataProp] == 0)
		return '';
	    return oObj.aData[mDataProp];
	};
    },
    yes_or_nothing: function(mDataProp) {
	return function(oObj) {
	    if (oObj.aData[mDataProp])
		return 'Yes';
	    return '';
	};
    },
    date: function(mDataProp) {
	return function(oObj) {
	    if (oObj.aData[mDataProp])
		return Renderer.date_to_metric(new Date(oObj.aData[mDataProp]));
	    return '';
	};
    }
};
