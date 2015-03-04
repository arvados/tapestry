$(document).ready(function(){
  $('.open-humans-token').each( function() {
    $.get( '/open_humans/huids?token_id=' + $(this).data('token-id'), function(data) {
      var htmlToShow;
      if( data['huids'].length == 0 ) {
        htmlToShow = "Your huID is not currently shared with Open Humans. Adding it will trigger an import of your public PGP Harvard data into your Open Humans account. <a href='#' data-token-id='" + data['token_id'] + "' class='send-huid-link btn btn-small'>Send huID to Open Humans</a>";
      } else {
        htmlToShow = 'Your huID (<b>' +  data['huids'].join('</b>, <b>') + '</b>) is registered with Open Humans. Removing this will NOT remove data sets imported by Open Humans; you can manage those separately in your Open Humans account.';
        htmlToShow += " <a href='#' data-token-id='" + data['token_id'] + "' data-profile-id='" + data['profile_id'] + "' class='delete-huids-link btn btn-small' >Remove huID from Open Humans</a>";
      }
      $('.open-humans-token[data-token-id=' + data['token_id'] + ']').html( htmlToShow );
    });
  });
});

$(document).on('click', 'a.send-huid-link', function() {
  $(this).html('Sending...');
  var tokenId = $(this).data('token-id');
  $.ajax( {
    url: '/open_humans/huids?token_id=' + tokenId,
    type: 'POST'
  }).always( function( data ) {
    location.reload();
  });
});

$(document).on('click', 'a.delete-huids-link', function() {
  $(this).html('Removing...');
  var tokenId = $(this).data('token-id');
  var profileId = $(this).data('profile-id');
  $.ajax({
    url: '/open_humans/huids?profile_id=' + profileId + '&token_id=' + tokenId,
    type: 'DELETE'
  }).always( function( data ) {
    location.reload();
  });
});
