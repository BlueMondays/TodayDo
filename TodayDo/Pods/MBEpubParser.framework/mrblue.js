<script type="text/javascript">
// Common -S
function getSelectedText() {
	return window.getSelection().toString();
}
// Common -E

// Styles Setting -S
var _pressTimer;
var _imgSrc;
function initStyles() {
	$('body').removeAttr('style')
	.css({
		 'padding': '0',
		 'margin-top': '0',
		 'margin-left': '0',
		 'margin-right': '0',
		 'margin-bottom': '0'
		 });
	
	$('p').removeAttr('style')
	.css('text-align', 'justify');
	
	$('img').removeAttr('style')
	.removeAttr('width')
	.removeAttr('height')
	.removeAttr('class')
	.css({
		 'max-width': '100%',
		 'max-height': '100%',
		 'overflow-x': 'auto',
		 'width': 'auto',
		 'display': 'block',
		 'float': 'center',
		 'margin-bottom': '0',
		 'margin-top': '0',
		 'padding': '0',
		 'border': '0',
		 'margin-left': 'auto',
		 'margin-right': 'auto',
		 'page-break-after': 'always',
		 'page-break-before': 'always',
		 'webkitTouchCallout': 'none',
		 'webkitUserSelect': 'none'
	})
	.on('touchstart', function() {
		_imgSrc = this.src;
		_pressTimer = window.setTimeout(function() {
			document.location = "toapp:zoomimage:" + _imgSrc;
		}, 500);
		return true;
	})
	.on('touchend touchcancel touchmove', function() {
		clearTimeout(_pressTimer);
		return true;
	});
}

function setColumesLayout(height, columnWidth, columnGap) {
	$('html').css('height', height)
	.css('-webkit-column-width', columnWidth)
	.css('-webkit-column-gap', columnGap);
}

function setLineHeight(lineHeight) {
	$('body').css('line-height', lineHeight+'%');
	$('div').css('line-height', 'inherit');
	$('p').css('line-height', 'inherit');
}

function setFontFamily(fontFamily) {
	$('body').css('font-family', fontFamily);
}

function setFontSize(fontSize) {
	$('body').css('font-size', fontSize+'%');
	$('div').css('font-size', 'inherit');
	$('p').css('font-size', 'inherit');
}

function setTextColor(color) {
	$('body').css('color', color);
}
// Styles Setting -E

// Search -S
function initSearch() {
	jQuery.fn.searchAndHighlight = function(keyword, className) {
		var regex = new RegExp(keyword, "gi");
		return this.each(function (index) {
			$(this).contents().filter(function() {
				return this.nodeType == 3 && regex.test(this.nodeValue);
			}).replaceWith(function() {
				return (this.nodeValue || "").replace(regex, function(match) {
					return "<span class=\"" + className + "\">" + match + "</span>";
				});
			});
		});
	};
}

function searchAndHighlight(keyword) {
	$('body *').searchAndHighlight(keyword, "searchResult");
	return $('.searchResult').length;
}

function removeSearchHighlight() {
	$('.searchResult').contents().unwrap();
}

function getSearchResultPositionAtIndex(index) {
	var position = $('.searchResult').eq(index).position();
	return position.left;
}
// Search -E

// Highlight & Memo -S
var highlighter;
var initialDoc;

function initRangy() {
	rangy.init();
	highlighter = rangy.createHighlighter();
	
	// Highlight
	var settings = {
		ignoreWhiteSpace: true,
 		elementTagName: "a",
		elementProperties: {
			href: "#",
			ontouchstart: function() {
				var highlight = highlighter.getHighlightForElement(this);
				var characterRange = highlight.characterRange;
				var rect = this.getBoundingClientRect();
				
				document.location = "toapp:highlight:" + characterRange.start + "$" + characterRange.end + "$" + highlight.id + "$highlight$"
				+ "{{" + rect.left + "," + rect.top + "}, {" + rect.width + "," + rect.height + "}}";
				return false;
			},
			onclick: function() {
				return false;
			}
		}
	};
	highlighter.addClassApplier(rangy.createCssClassApplier("highlight", settings));
	
	// Memo
	settings = {
		ignoreWhiteSpace: true,
		elementTagName: "a",
		elementProperties: {
			href: "#",
			ontouchstart: function() {
				var highlight = highlighter.getHighlightForElement(this);
				var characterRange = highlight.characterRange;
				var rect = this.getBoundingClientRect();
				
				document.location = "toapp:memo:" + characterRange.start + "$" + characterRange.end + "$" + highlight.id + "$memo$"
				+ "{{" + rect.left + "," + rect.top + "}, {" + rect.width + "," + rect.height + "}}";
				return false;
			},
			onclick: function() {
				return false;
			}
		}
	};
	highlighter.addClassApplier(rangy.createCssClassApplier("memo", settings));
}

function addHighlightSelection() {
	highlighter.highlightSelection("highlight");
}

function addMemoSelection() {
	highlighter.highlightSelection("memo");
}

function removeSelection() {
	highlighter.unhighlightSelection();
}

function removeAllHighlights() {
	highlighter.removeAllHighlights();
}

function getRectForSelectionText() {
	var selection = window.getSelection();
	var range = selection.getRangeAt(0);
	var rect = range.getBoundingClientRect();
	return "{{" + rect.left + "," + rect.top + "}, {" + rect.width + "," + rect.height + "}}";
}

function getSerializedHighlights() {
	return highlighter.serialize();
}

function deserialize(serializedHighlights) {
	highlighter.deserialize(serializedHighlights);
}

function getHighlightTopOffsetForOrder(className, order) {
	var list = document.getElementsByClassName(className);
	var element = list[order];
	return element.offsetTop;
}
// Highlight & Memo -E

window.onload = function() {
	FastClick.attach(document.body);
	
	initStyles();
	initSearch();
	initRangy();
	
	document.location = "toapp:onload";
};
</script>
