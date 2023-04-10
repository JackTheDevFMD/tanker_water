$(function () {
	function display(bool) {
		if (bool) {
			$('#container').show();

			let counter = 6;
			let counter2 = 0;

			for (let i = 51; i > 0; i--) {
				setTimeout(function () {
					if (50 - i == counter) {
						counter = counter + 6;
						counter2++;

						document.getElementById('light' + counter2).className =
							'opacityofimage';
					}
				}, (51 - i) * 1000);
			}
		} else {
			$('#container').hide();
		}
	}

	display(false);

	window.addEventListener('message', function (event) {
		var item = event.data;
		if (item.type === 'ui') {
			if (item.status == true) {
				display(true);
			} else {
				display(false);
			}
		}
	});

	// if the person uses the escape key, it will exit the resource
	document.onkeyup = function (data) {
		if (data.which == 27) {
			$.post('https://tanker_water/exit', JSON.stringify({}));
			return;
		}
	};
});
