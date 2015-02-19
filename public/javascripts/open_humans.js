$(document).ready(function(){
  $('.open-humans-token').each( function() {
    $.get( '/open_humans/huids?token_id=' + $(this).data('token-id'), function(data) {
      var htmlToShow;
      if( data['huids'].length == 0 ) {
        htmlToShow = "Your huID is not currently registered with Open Humans <a href='#' data-token-id='" + data['token_id'] + "' class='send-huid-link btn btn-small'>Send huID to Open Humans</a>";
      } else {
        htmlToShow = 'Your huIDs registered with Open Humans: <b>' +  data['huids'].join('</b>, <b>') + '</b>';
        htmlToShow += " <a href='#' data-token-id='" + data['token_id'] + "' data-profile-id='" + data['profile_id'] + "' class='delete-huids-link btn btn-small' >Delete huIDs</a>";
      }
      $('.open-humans-token[data-token-id=' + data['token_id'] + ']').html( htmlToShow );
    });
  });
});

$(document).on('click', 'a.send-huid-link', function() {
  var tokenId = $(this).data('token-id');
  $.ajax( {
    url: '/open_humans/huids?token_id=' + tokenId,
    type: 'POST'
  }).always( function( data ) {
    if( data['status'] === 200 ) {
      location.reload();
    }
  });
});

$(document).on('click', 'a.delete-huids-link', function() {
  var tokenId = $(this).data('token-id');
  var profileId = $(this).data('profile-id');
  $.ajax({
    url: '/open_humans/huids?profile_id=' + profileId + '&token_id=' + tokenId,
    type: 'DELETE'
  }).always( function( data ) {
    if( data['status'] === 200 ) {
      location.reload();
    }
  });
});
