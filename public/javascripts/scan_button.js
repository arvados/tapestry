// -*- mode: java; c-basic-offset: 2; tab-width: 4; indent-tabs-mode: nil; -*-

jQuery(function($){
    $('.launch_scanner').click(function(){
        if (/Linux.*Android/.exec(navigator.userAgent))
          window.location = 'http://zxing.appspot.com/scan';
        else
          alert("Sorry, I can't launch your bar code scanner from here -- you have to open it manually to proceed.")
            return false;
      });
  });
