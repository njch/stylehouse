
$.get('ajax', { hell: 0 }, function (eh) {
        $('body').html(eh);
        triggery();
    });

function triggery () {
$("a").click(function (li) {
    var where = this;
    var id = $(where).attr("id");
    $.get('ajax', { from: id }, function (eh) {
    nest.append("<ul>"+eh+"</ul>");
	triggery()
    })
});
}
