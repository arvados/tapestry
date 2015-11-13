$(document).ready(function(){
  $('.open-humans-token').each( function() {
    $.get( '/open_humans/huids?token_id=' + $(this).data('token-id'), function(data) {
      var htmlToShow;
      if( data['huids'].length == 0 ) {
        htmlToShow = "Your huID is not currently shared with Open Humans. Adding it will trigger an import of your public PGP Harvard data into your Open Humans account. <a href='#' data-token-id='" + data['token_id'] + "' class='send-huid-link btn btn-small'>Send huID to Open Humans</a>";
      } else {
        htmlToShow = "You've connected Open Humans to your PGP account and we've shared your participant ID. <p/>You can use the button below to stop sharing your data with Open Humans. This will NOT remove data sets imported by Open Humans; you'll need to do so within your account on <a href=\"https://www.openhumans.org/member/me/connections/\">Open Humans</a>.<p/>"
        htmlToShow += " <a href='#' data-token-id='" + data['token_id'] + "' data-profile-id='" + data['profile_id'] + "' class='disconnect-link btn btn-small' >Stop sharing my data with Open Humans</a>";
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

$(document).on('click', 'a.disconnect-link', function() {
  $(this).html('Disconnecting...');
  var tokenId = $(this).data('token-id');
  var profileId = $(this).data('profile-id');
  $.ajax({
    url: '/open_humans/disconnect?profile_id=' + profileId + '&token_id=' + tokenId,
    type: 'POST'
  }).always( function( data ) {
    location.reload();
  });
});
