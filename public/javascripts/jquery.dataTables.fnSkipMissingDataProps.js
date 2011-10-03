// -*- mode: js2; indent-tabs-mode: nil; tab-width: 4 -*-

jQuery.fn.dataTableExt.oApi.fnSkipMissingDataProps = function (oSettings) {
    var oCol, i;
    for (i=0; i<oSettings.aoColumns.length; i++) {
        oCol = oSettings.aoColumns[i];
        oCol.fnGetData = _fnGetObjectDataFn(oCol.mDataProp);
        oCol.fnSetData = _fnSetObjectDataFn(oCol.mDataProp);
    }
    function _fnGetObjectDataFn( mSource )
    {
        if ( mSource === null )
        {
            /* Give an empty string for rendering / sorting etc */
            return function (data) {
                return null;
            };
        }
        else if ( typeof mSource == 'function' )
        {
            return function (data) {
                return mSource( data );
            };
        }
        else if ( typeof mSource == 'string' && mSource.indexOf('.') != -1 )
        {
            /* If there is a . in the source string then the data source is in a nested object
             * we provide two 'quick' functions for the look up to speed up the most common
             * operation, and a generalised one for when it is needed
             */
            var a = mSource.split('.');
            if ( a.length == 2 )
            {
                return function (data) {
                    if(!data[a[0]]) return null;
                    return data[ a[0] ][ a[1] ];
                };
            }
            else if ( a.length == 3 )
            {
                return function (data) {
                    if(!data[a[0]]) return null;
                    if(!data[a[0]][a[1]]) return null;
                    return data[ a[0] ][ a[1] ][ a[2] ];
                };
            }
            else
            {
                return function (data) {
                    for ( var i=0, iLen=a.length ; i<iLen ; i++ )
                    {
                        if(!data[a[i]]) return null;
                        data = data[ a[i] ];
                    }
                    return data;
                };
            }
        }
        else
        {
            /* Array or flat object mapping */
            return function (data) {
                return data[mSource];   
            };
        }
    }
    function _fnSetObjectDataFn( mSource )
    {
        if ( mSource === null )
        {
            /* Nothing to do when the data source is null */
            return function (data, val) {};
        }
        else if ( typeof mSource == 'function' )
        {
            return function (data, val) {
                return mSource( data, val );
            };
        }
        else if ( typeof mSource == 'string' && mSource.indexOf('.') != -1 )
        {
            /* Like the get, we need to get data from a nested object. Again two fast lookup
             * functions are provided, and a generalised one.
             */
            var a = mSource.split('.');
            if ( a.length == 2 )
            {
                return function (data, val) {
                    data[ a[0] ] = data[a[0]] || {};
                    data[ a[0] ][ a[1] ] = val;
                };
            }
            else if ( a.length == 3 )
            {
                return function (data, val) {
                    data[a[0]] = data[a[0]] || {};
                    data[a[0]][a[1]] = data[a[0]][a[1]] || {};
                    data[ a[0] ][ a[1] ][ a[2] ] = val;
                };
            }
            else
            {
                return function (data, val) {
                    for ( var i=0, iLen=a.length-1 ; i<iLen ; i++ )
                    {
                        data[a[i]] = data[a[i]] || {};
                        data = data[ a[i] ];
                    }
                    data[ a[a.length-1] ] = val;
                };
            }
        }
        else
        {
            /* Array or flat object mapping */
            return function (data, val) {
                data[mSource] = val;    
            };
        }
    }
    return this;
};
