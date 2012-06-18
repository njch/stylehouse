function drawstuff (svg) {
    $.get('stats', {}, function (stats) {
        svg.text(10, 20, stats);
        var g = svg.group({stroke: 'black', strokeWidth: 2});
    });
    $.getJSON('boxen', {}, function (boxen) {
        jQuery.each(boxen['labels'], function (i, l) {
            svg.text(7, l[1] + 12, l[0]);
        });
        jQuery.each(boxen['boxen'], function (i, b) {
            var rect = svg.rect(b[2] + 50, b[3], b[0], b[1], {fill: b[4], id: b[5]});
            $(rect).bind('mouseover', svgOver).bind('mouseout', svgOut);
        });
    });
}
function svgOver() {
	$(this).attr('stroke', 'lime');
}

function svgOut() {
	$(this).attr('stroke', 'none');
}
$.get('stats', {}, function (text) {
    $('#view').svg({onLoad: drawstuff})
});
//$.get('ajax', { hell: 0 }, function (eh) {
//        $('body').html(eh);
//        triggery();
//    });
//
//function triggery () {
//$("a").click(function (li) {
//    var where = this;
//    var id = $(where).attr("id");
//    $.get('ajax', { from: id }, function (eh) {
//    nest.append("<ul>"+eh+"</ul>");
//	triggery()
//    })
//});
//}
