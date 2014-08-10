var ws;
var fail = 0;
var db = 0;
function connect () {
  ws = new WebSocket('ws://127.0.0.1:3000/stylehouse');
  ws.onmessage = function(event) {
  
        console.log(event.data);
    try {
        eval(event.data);
    } catch (e) {
        ws.reply({e:e.message, d:event.data});
    }
  };
  ws.onopen = function(e) {
    fail = 0;
    $('#body').removeClass('dead');
  };
  ws.onclose = function(e) {
     $(window).off('click', clickyhand);
    $('#body').addClass('dead');
    console.log("WebSocket Error: " , e);
    reconnect();
  };
  ws.onerror = function(e) {
     $(window).off('click', clickyhand);
    $('#body').addClass('dead');
    console.log("WebSocket Error: " , e);
    //reconnect();
  };
}
function reconnect () {
  fail++;
  console.log('waiting to retry');
  if (fail < 20000) {
      window.setTimeout(connect, 256);
  }
  else {
      window.setTimeout(connect, 25600);
  }
}
WebSocket.prototype.reply = function reply (stuff) {

  console.log(stuff);

  this.send(JSON.stringify(stuff));
};

function clickon () { $(window).on("click", clickyhand); }
function clickoff () { $(window).off("click", clickyhand); }
function clickyhand (event) {
    var tag = $(event.target);
    
    var value = ''+tag.contents();
    if (!(tag.attr('id') || tag.attr('class'))) {
        tag = tag.parent();
    }
    if (value && value.length >= 640) {
        value = '';
    }
    var data = {
        id: tag.attr('id'),
        class: tag.attr('class'),
        value: value,
        type: event.type,
        S: 0+event.shiftKey,
        C: 0+event.ctrlKey,
        A: 0+event.altKey,
        M: 0+event.metaKey,
        x: event.clientX,
        y: event.clientY,
        pagex: window.pageXOffset,
        pagey: window.pageYOffset,
    };
    ws.reply({event: data});
}
var nohands = 0;
var handelay = 10;
function keyhand (e) {
    if (nohands) {
        return;
    }
    setTimeout(function () {
        nohands = 0;
    }, handelay);
    nohands = 1;
    var data = {
        type: e.type,
        S: 0+e.shiftKey,
        C: 0+e.ctrlKey,
        A: 0+e.altKey,
        M: 0+e.metaKey,
        which: e.which,
        k: String.fromCharCode(e.keyCode),
    };
    ws.reply({event: data});
}
connect();

