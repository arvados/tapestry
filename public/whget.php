<?php
    ;
header('Content-type: '.($_REQUEST['type'] || 'application/octet-stream'));
if ($_REQUEST['size'])
    header('Content-length: '.$_REQUEST['size']);
if ($_REQUEST['disposition'])
    header('Content-disposition: '.$_REQUEST['disposition'].
           ($_REQUEST['filename'] ? '; filename="'.$_REQUEST['filename'].'"' : ''));
passthru("NODECRYPT=1 whget ''".escapeshellarg($_REQUEST['locator']));
