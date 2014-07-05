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
  if (fail < 2000) {
      window.setTimeout(connect, 2560);
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
    if (value && value.length >= 666) {
        value = 'SATAN';
    }
    var data = {
        id: tag.attr('id'),
        class: tag.attr('class'),
        value: value,
        type: event.type,
        S: 0+event.shiftKey,
        C: 0+event.ctrlKey,
        A: 0+event.altKey,
        x: event.clientX,
        y: event.clientY,
        pagex: window.pageXOffset,
        pagey: window.pageYOffset,
    };
    ws.reply({event: data});
}
connect();

