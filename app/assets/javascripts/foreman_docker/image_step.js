$(document).ready(function() {
  var tag = $('#tag');
  tag.autocomplete({
    source: [],
    autoFocus: true,
    delay: 500,
    minLength: 0
  }).focus( function() {
    $(this).data("uiAutocomplete").search($(this).val());
  });

  var target = $('#search');
  //autoCompleteRepo(target);
  target.autocomplete({
    source: function( request, response ) { autoCompleteRepo(target); },
    delay: 500,
    minLength: 1
  });

  $('#hub_tab').click( function() {
      $('#repository_registry_id').val('');
  });
});

function autoCompleteRepo(item) {
  $.ajax({
    type:'get',
    url: $(item).attr('data-url'),
    data: { search: item.val(), registry_id: $('#registry_id').val() },
    //data:'search=' + item.val(),
    success:function (result) {
      if(result == 'true'){
        $('#search-addon').attr('title', 'Image found in the compute resource');
        $('#search-addon').removeClass('glyphicon-remove');
        $('#search-addon').css('color', 'lightgreen');
        $('#search-addon').addClass('glyphicon-ok');
        setWaitingText('Image found: <strong>' + item.val() + '</strong>. Retrieving available tags, please wait...');
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
  $.getJSON( tag.data("url"), { search: $('#search').val(), registry_id: $('#repository_registry_id').val() },
      function(data) {
        $('#searching_spinner').hide();
        tag.removeClass('tags-autocomplete-loading');
        $.each( data, function(index, value) {
          source.push({label: value.label, value: value.value});
        });
        $('#tag').focus();
      });
  tag.autocomplete('option', 'source', source);
}

function searchRepo(item) {
  setWaitingText('<strong>Searching</strong> in the hub, this can be slow, please wait...');
  $('#repository_search_results').html('');
  $('#repository_search_results').show();
  $.ajax({
    type:'get',
    dataType:'text',
    url: $(item).attr('data-url'),
    data: { search: $('#search').val(), registry_id: $('#repository_registry_id').val() },
    success: function (result) {
      $('#repository_search_results').html(result);
    },
    complete: function (result) {
      $('#searching_spinner').hide();
    }
  });
}

function repoSelected(item) {
  $('#repository_search_results').hide();
  setWaitingText('Image selected: <strong>' + item.text + '</strong>. Retrieving available tags, please wait...');
  $('#search').val(item.text);
  setAutocompleteTags(item);
}

function setWaitingText(string) {
  $('#waiting_text').html(string);
  $('#searching_spinner').show();
}
