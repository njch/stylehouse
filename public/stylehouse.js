var ws;
var fail = 0;

function connect () {
  ws = new WebSocket('ws://127.0.0.1:3000/stylehouse');
  ws.onmessage = function(event) {
    console.log(event.data);
    eval(event.data);
  };
  ws.onopen = function(e) {
    fail = 0;
    $('#body').removeClass('dead');
  }
  ws.onclose = function(e) {
     $(window).off('click', clickyhand);
    $('#body').addClass('dead');
    console.log("WebSocket Error: " , e);
    reconnect();
  }
  ws.onerror = ws.onclose;
}
function reconnect () {
  fail++;
  console.log('waiting to retry');
  if (fail < 2000) {
      window.setTimeout(connect, 256);
  }
  else {
      window.setTimeout(connect, 2048);
  }
}

WebSocket.prototype.reply = function reply (stuff) {

  console.log(stuff);

  ws.send(JSON.stringify(stuff));
};

function clickon () { $(window).on("click", clickyhand); }
function clickoff () { $(window).off("click", clickyhand); }
function clickyhand (event) {
    var value = event.target.id ? event.target.innerText : null;
    if (value.length >= 666) {
        value = 'SATAN';
    }
    var data = {
        id: event.target.id,
        value: value,
        type: event.type,
        shiftKey: 0+event.shiftKey,
        ctrlKey: 0+event.ctrlKey,
        altKey: 0+event.altKey,
        x: event.clientX,
        y: event.clientY,
        pagex: window.pageXOffset,
        pagey: window.pageYOffset,
    };
    ws.reply({event: data});
}
connect();
