$(function () {
	function display(bool) {
		if (bool) {
			$('#container').show();
		} else {
			$('#container').hide();
		}
	}

	display(false);

	function decreaseLights() {
		let counter = 6;
		let counter2 = 0;

		for (let i = 51; i > 0; i--) {
			setTimeout(function () {
				if (50 - i == counter) {
					counter = counter + 6;
					counter2++;

					document.getElementById('light' + counter2).className =
						'turnOffImage';
				}
			}, (51 - i) * 1000);
		}

		display(false);
	}

	function increaseLights() {
		let counter = 6;
		let counter2 = 8;

		for (let i = 1; i < 9; i++) {
			document.getElementById('light' + i).className = 'turnOffImage';
		}

		for (let i = 51; i > 0; i--) {
			setTimeout(function () {
				if (50 - i == counter) {
					counter = counter + 6;

					document.getElementById('light' + counter2).className = 'turnOnImage';

					counter2--;
				}
			}, (51 - i) * 1000);
		}

		display(false);
	}

	window.addEventListener('message', function (event) {
		var item = event.data;
		if (item.type === 'ui') {
			if (item.status == true) {
				display(true);
			} else {
				display(false);
			}
		} else {
			if (item.waterType === 'filling') {
				decreaseLights();
			} else {
				if (item.waterType === 'emptying') {
					increaseLights();
				}
			}
		}
	});
});
