



var ins = [];
var svg;
function heresthesvg (the) {
    svg = the;
    ting('boxen');
}

function drawstuff () {
    jQuery.each(ins, function (i, inst) {
        console.log('Instruction'+ inst);
        if (inst[0] == 'clear') {
            svg.clear();
        }
        else if (inst[0] == 'status') {
            if ($('#status').length) {
                $('#status').text(inst[1]);
            }
            else {
                svg.text(10, 20, inst[1], {id: 'status'});
            }
        }
        else if (inst[0] == 'boxen') {
            var b = inst.slice(1);
            var rect = svg.rect(b[2] + 50, b[3], b[0], b[1], {fill: b[4], id: b[5]});
            $(rect)
                .bind('mouseover', ob_Over)
                .bind('mouseout', ob_Out)
                .bind('click', ob_Click);
        }
        else if (inst[0] == 'label') {
            var l = inst.slice(1);
            svg.text(l[0], l[1] + 12, l[2]);
        }
//        var g = svg.group({stroke: 'black', strokeWidth: 2});
    }); 
}
function ob_Over() { // set status line to object id
    var id = $(this).attr('id')
    $('text#status').text( 'yep: '+id );
    $('#'+id).attr('stroke', 'lime');
}
function ob_Out() {
    var id = $(this).attr('id')
    $('#'+id).attr('stroke', 'none');
}
function ob_Click() { // look up object info
    $('#view').svg('destroy');
    var id = $(this).attr('id');
    $('#view').svg({onLoad: drawinfo($('#view'), id)})
}

function drawinfo(svg, id) {
    $.getJSON('object', { id: id }, function (info) {
        svg.text('<pre>'+info+'</pre>')
    });
}

function ting(action, param) {
    $.getJSON(action, param, function (json) {
        console.log("Ting!", action, param, json);
        if (ins.length) {
            console.error("Have more instructions to put on top of", ins);
        }
        ins = json;
        drawstuff();
    })
}

$.get('stats', {}, function (stats) {
    $('#view').svg({onLoad: heresthesvg})
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
