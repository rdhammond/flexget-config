(function($) {
	'use strict';
	
	var actions = {
		add: '/add',
		delete: '/delete'
	};
	
	function errorAlert() {
		window.alert('Something blew up. Go pester Daniel about it!');
	}

	function extractForm() {
        var form = $('#frmAdd')[0];

        return {
            name: form.showName.value,
            season: form.season.value,
            episode: form.episode.value
        };
	}

	function validate(data) {
		return data.name && data.episode > 0 && data.season > 0;
	}
	
	function addShow() {
		var data = extractForm();
		
		if (!validate(data)) {
      $('#pInvalid').show();
      return false;
		}
		
		$('#pInvalid').hide();
		
		$.ajax({
			data: data,
			method: 'POST',
			url: actions.add,
		})
		.done(function(data) {
			var frmAdd = $('#frmAdd')[0];
			frmAdd.showName.value = '';
			frmAdd.season.value = '';
			frmAdd.episode.value = '';
			$('#txtShowName').focus();
			
			if (!data) return;
			$('#tblShows>tbody').append($(data));
		})
		.error(function() { errorAlert(); });
		
		// Make sure we don't go through with the postback!
		return false;
	}
	
	function deleteShow() {
    var $tr = $(this).closest('tr');
		var name = $tr.data('name');
	
		if (!window.confirm('Are you sure you want to delete ' + name + '?')) {
      return;
    }
		
		$.ajax({
			data: {name: name},
			method: 'POST',
			url: actions.delete
		})
		.done(function() { $tr.remove(); })
		.error(function() { errorAlert(); });
	}
	
	$(function() {
		$('#frmAdd').submit(addShow);
		$('#tblShows').on('click', '.btnDelete', deleteShow);
		$('#txtShowName').focus();
	});
	
})(jQuery);
