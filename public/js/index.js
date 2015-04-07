(function($) {
	'use strict';
	
	var actions = {
		delete: '/delete'
	};
	
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
			window.alert('Something blew up. Go pester Daniel about it!');
		});
	}
	
	$(function() {
		$('#btnDelete').click(deleteShow);
	});
	
})(jQuery);
