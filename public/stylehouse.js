
var svg;


function heresthesvg (the) {
    svg = the;
    var text = svg.text(svg, 14, 50, 'jugular');
    $('#view svg').attr('height', '5000');
    navigate("hello", {width: $('#view').width()});
}

function navigate(where, params) {
    $.getJSON(where, params, function (json) {
        console.log(json);
        eval(json);
    });
}

$.getJSON('nothing', {}, function () {
    $('#view').svg({onLoad: heresthesvg})
});



function drawstuff () {
    jQuery.each(ins, function (i, inst) {
        console.log('Instruction '+ inst);
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
            var rect = svg.ellipse(b[0], b[1], b[2], b[3], b[4]);
            $(rect)
                .bind('mouseover', ob_Over)
                .bind('mouseout', ob_Out)
                .bind('click', ob_Click);
        }
        else if (inst[0] == 'label') {
            var l = inst.slice(1);
            var text = svg.text(l[0], l[1] + 12, l[2], l[3]);
            $(text)
                .bind('click', lab_Click);
        }
        else if (inst[0] == 'remove') {
            var id = inst[1];
            $('.'+id).each(function (i, t) {
                svg.remove(t);
            });
        }
        else if (inst[0] == 'animate') {
            var id = inst[1];
            var how = inst[2];
            var timing = inst[3];
            console.log(how);
            $('#'+id).animate(how, timing);
        }
//        var g = svg.group({stroke: 'black', strokeWidth: 2});
    });
    ins = [];
}
function ob_Over() { // set status line to object id
    $('text#status').text( 'yep: '+$(this).attr('name'));
    $('rect.'+$(this).attr('id')).attr('stroke', 'lime').attr('stroke-width', '10px');
}
function ob_Out() {
    $('rect.'+$(this).attr('id')).attr('stroke', 'none');
}
function ob_Click() { // look up object info
    var id = $(this).attr('id');
    navigate(["object", {id: id}])
}
function lab_Click() {
    var id = $(this).attr('id');
    ting("object_info", {id: id});
}


