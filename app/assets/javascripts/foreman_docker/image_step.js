$(document).ready(function() {
  var tag = $('#tag');
  tag.autocomplete({
    source: [],
    delay: 500,
    minLength: 0
  }).focus( function() {
    $(this).data("uiAutocomplete").search($(this).val());
  });

  var target = $('#search');
  autoCompleteImage(target);
  target.autocomplete({
    source: function( request, response ) { autoCompleteImage(target); },
    delay: 500,
    minLength: 1
  });
});

function autoCompleteImage(item) {
  $.ajax({
    type:'get',
    url: $(item).attr('data-url'),
    data:'search=' + item.val(),
    success:function (result) {
      if(result == 'true'){
        $('#search-addon').attr('title', 'Image found in the compute resource');
        $('#search-addon').removeClass('glyphicon-remove');
        $('#search-addon').css('color', 'lightgreen');
        $('#search-addon').addClass('glyphicon-ok');
        setAutocompleteTags();
      } else {
        $('#search-addon').attr('title', 'Image NOT found in the compute resource');
        $('#search-addon').removeClass('glyphicon-ok');
        $('#search-addon').css('color', 'red');
        $('#search-addon').addClass('glyphicon-remove');
        $('#tag').autocomplete('option', 'source', []);
      }
    }
  });
}

function setAutocompleteTags() {
  var tag = $('#tag');
  tag.addClass('tags-autocomplete-loading');
  tag.val('');
  var source = [];
  $.getJSON( tag.data("url"), { search: $('#search').val() },
      function(data) {
        tag.removeClass('tags-autocomplete-loading');
        $.each( data, function(index, value) {
          source.push({label: value.label, value: value.value});
        });
      });
  tag.autocomplete('option', 'source', source);
}
