(function($) {
	'use strict';
	
	var actions = {
		add: '/add',
		delete: '/delete'
	};
	
	function errorAlert() {
		window.alert('Something blew up. Go pester Daniel about it!');
	}
	
	function validate() {
		var data = {
			name: $('#txtName').val(),
			season: parseInt($('#txtSeason').val(), 10),
			episode: parseInt($('#txtEpisode').val(), 10)
		};
		
		if (
			!data.name
			|| isNaN(data.season)
			|| data.season <= 0
			|| isNaN(data.episode)
			|| data.episode <= 0
		)
		{
			$('#pInvalid').show();
			return null;
		}
		
		$('#pInvalid').hide();
		return data;
	}
	
	function addShow() {
		var data = validateData();
		if (!data) return false;
		
		$('#pInvalid').hide();
		
		$.ajax({
			data: data,
			method: 'POST',
			url: actions.add
		})
		
		.success(function(data) {
			$('#tblShows').append(data);
		})
		
		.error(function() {
			errorAlert();
		});
		
		// Make sure we don't go through with the postback!
		return false;
	}
	
	function deleteShow() {
		var $tr = $(this).parent('tr');
		var id = $tr.data('id');
		
		$.ajax({
			data: {'id': id},
			method: 'POST',
			url: actions.delete
		})
		
		.success(function() {
			$tr.remove();
		})
		
		.error(function() {
			errorAlert();
		});
	}
	
	$(function() {
		$('#btnAdd').submit(addShow);
		$('#btnDelete').click(deleteShow);
	});
	
})(jQuery);
