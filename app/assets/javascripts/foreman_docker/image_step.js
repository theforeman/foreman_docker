$(document).ready(function() {
    var tag = $('#local_tag');
    tag.autocomplete({
        source: [],
        minLength: 0
    }).focus( function() {
        $(this).data("uiAutocomplete").search($(this).val());
    });

    var target = $('#search');
    target.autocomplete({
        source: function( request, response ) {
            $.getJSON( target.data("url"), { search: request.term }, response );
        },
        select: function( event, ui ) {
            tag.val('');
            var source = [];
            $.getJSON( tag.data("url"), { search: ui.item.value }, function(data) {
                $.each( data, function(index, value) {
                    source.push({label: value.label, value: value.value});
                });
            });
            tag.autocomplete('option', 'source', source);
        },
        minLength: 1
    });
});
