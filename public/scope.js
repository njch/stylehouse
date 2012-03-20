
$.get('ajax', { hell: 0 }, function (eh) {
        $('body').html(eh);
        triggery();
    });

function triggery () {
$("li").click(function (li) {
    var where = this;
    $.get('ajax', { from: $(where).attr("id") }, function (eh) {
	console.log(where);
        $(where).append("<ul>"+eh+"</ul>");
	triggery()
    })
});
}
