
$.get('ajax', { hell: 0 }, function (eh) {
        $('body').html(eh);
        triggery();
    });

function triggery () {
$("li").click(function (li) {
    $.get('ajax', { from: $("li:last").attr("id") }, function (eh) {
        $("li:last").append("<ul>"+eh+"</ul>");
    })
});
}
