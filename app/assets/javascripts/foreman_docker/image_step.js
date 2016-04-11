$(document).ready(function() {
  setupAutoComplete("hub");
  setupAutoComplete("registry");
  $('#hub_tab').click( function() {
      $('#docker_container_wizard_states_image_registry_id').val('');
  });
});

function setupAutoComplete(registryType) {
  var tag = getTag(registryType),
      repo = getRepo(registryType);

  tag.autocomplete({
    source: [],
    autoFocus: true,
    delay: 500,
    minLength: 0
  }).focus( function() {
    $(this).data("uiAutocomplete").search($(this).val());
  });

  repo.autocomplete({
    source: function( request, response ) { autoCompleteRepo(repo); },
    delay: 500,
    minLength: 1
  });
}

function autoCompleteRepo(item) {
  var registryType = $(item).data('registry'),
      search_add_on = getImageConfirmation(registryType),
      tag = getTag(registryType);

  // Patternfly spinner uses 'float: left' and moves it to the left of the
  // search button. Instead, we use FontAwesome's spinner to keep it at
  // the right.
  search_add_on.attr('class', 'fa fa-spin fa-circle-o-notch');

  $.ajax({
    type:'get',
    url: $(item).attr('data-url'),
    data: { search: item.val(), registry_id: $('#docker_container_wizard_states_image_registry_id').val() },
    success:function (result) {
       if(result == 'true'){
        search_add_on.attr('title', 'Image found in the compute resource');
        search_add_on.attr('class', 'pficon pficon-ok');
        setWaitingText('Image found: <strong>' + item.val() + '</strong>. Retrieving available tags, please wait...', registryType);
        setAutocompleteTags(registryType);
      } else {
        search_add_on.attr('title', 'Image NOT found in the compute resource');
        search_add_on.attr('class', 'pficon pficon-error-circle-o');
        tag.autocomplete('option', 'source', []);
      }
    },
    error: function(result) {
      $.jnotify(result.responseText, "error", true);
    }
  });
}

function setAutocompleteTags(registryType) {
  var tag = getTag(registryType);
  tag.addClass('spinner-label');
  tag.val('');
  var source = [];
  $.getJSON( tag.data("url"), { search: getRepo(registryType).val(), registry_id: $('#docker_container_wizard_states_image_registry_id').val() },
      function(data) {
        getSearchSpinner(registryType).hide();
        tag.removeClass('spinner-label');
        $.each( data, function(index, value) {
          source.push({label: value.label, value: value.value});
        });
        tag.focus();
      })
      .error(function(result) {
        $.jnotify(result.responseText, "error", true);
      });
  tag.autocomplete('option', 'source', source);
}

function searchRepo(item) {
  var registryType = $(item).data('registry'),
      results = getRepositorySearchResults(registryType),
      search = getRepo(registryType),
      searching_spinner = getSearchSpinner(registryType);
  setWaitingText('<strong>Searching</strong> in the hub, this can be slow, please wait...', registryType);
  results.html('');
  results.show();
  $.ajax({
    type:'get',
    dataType:'text',
    url: $(item).attr('data-url'),
    data: { search: search.val(), registry_id: $('#docker_container_wizard_states_image_registry_id').val() },
    success: function (result) {
      results.html(result);
    },
    error: function(result) {
      $.jnotify(result.responseText, "error", true);
    },
    complete: function (result) {
      searching_spinner.hide();
    }
  });
}

function repoSelected(item) {
  var registryType = "hub";
  if ($(item).data("hub") !== true) {
    registryType = "registry";
  }

  getRepositorySearchResults(registryType).hide();
  setWaitingText('Image selected: <strong>' + item.text + '</strong>. Retrieving available tags, please wait...', registryType);
  getRepo(registryType).val(item.text);
  setAutocompleteTags(registryType);
}

function setWaitingText(string, registryType) {
  getWaitText(registryType).html(string);
  getSearchSpinner(registryType).show();
}

function getTag(registryType) {
  return  $('form[data-registry="' + registryType + '"] input[data-tag]:first');
}

function getRepo(registryType) {
  return  $('form[data-registry="' + registryType + '"] input[data-search]:first');
}

function getSearchSpinner(registryType) {
  return  $('form[data-registry="' + registryType + '"] [data-search-spinner]:first');
}

function getRepositorySearchResults(registryType) {
  return  $('form[data-registry="' + registryType + '"] [data-repository-search-results]:first');
}

function getImageConfirmation(registryType) {
  return  $('form[data-registry="' + registryType + '"] #image-confirmation');
}

function getWaitText(registryType) {
  return  $('form[data-registry="' + registryType + '"] [data-wait-text]:first');
}
