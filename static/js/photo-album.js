/**
 * photo-album.js
 * A simple Javascript helper to make our photo albums interactive.
 *
 * @author Nathan Campos <nathanpc@dreamintech.net>
 */

var PhotoAlbum = new function () {
	/**
	 * Initalizes all of the albums in the page and attach events to make them
	 * interactive.
	 */
	this.init = function () {
		var albums = document.querySelectorAll("article .album");
		albums.forEach(function (album) {
			// Set events for the arrow elements
			var arrows = album.getElementsByClassName("arrow");
			arrows[0].onclick = function (evt) {
				PhotoAlbum.goToImage("back", album);
			};

			arrows[1].onclick = function (evt) {
				PhotoAlbum.goToImage("next", album);
			};
		});
	};

	/**
	 * Go to a image in the album.
	 *
	 * @param position Can be either a number of a specific picture or
	 *                 "next"/"back" to go forward or backwards.
	 * @param album    The main album element containing the photos.
	 */
	this.goToImage = function (position, album) {
		var figures = album.getElementsByTagName("figure");

		for (var i = 0; i < figures.length; i++) {
			// Check if it is the current image
			if (figures[i].classList.contains("current")) {
				// Remove the current status of the image
				figures[i].classList.remove("current");

				// Execute actions
				if (position === "back") {
					// Go to the previous photo
					if (i > 0) {
						figures[i - 1].classList.add("current");
					} else {
						figures[i].classList.add("current");
					}

					break;
				} else if (position === "next") {
					// Go to the next photo
					if (i < (figures.length - 1)) {
						figures[i + 1].classList.add("current");
					} else {
						figures[i].classList.add("current");
					}

					break;
				}
			}

			// Go to specific position
			if (typeof(position) == "number") {
				if (i == position) {
					figures[i].classList.add("current");
				}
			}
		}
	};

	/**
	 * A little hack to make sure we attach the initialization code to the
	 * onLoad event properly.
	 */
	this.attachLoadEvent = function () {
		if (window.attachEvent) {
			window.attachEvent("onload", this.init);
		} else if (window.addEventListener) {
			window.addEventListener("load", this.init, false);
		} else {
			document.addEventListener("load", this.init, false);
		}
	};
}

// Attach events.
PhotoAlbum.attachLoadEvent();

