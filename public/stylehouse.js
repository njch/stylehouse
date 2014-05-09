var ws;
var fail = 0;
WebSocket.prototype.reply = function reply (stuff) {
  console.log(stuff);
  ws.send(JSON.stringify(stuff));
};

function connect () {
  ws = new WebSocket('ws://localhost:3000/stylehouse');
  ws.onmessage = function(event) {
    console.log(event.data);
    eval(event.data);
  };
  ws.onopen = function(e) {
      fail = 0;
  }
  ws.onclose = function(e) {
     $(window).off('click', clickyhand);
    $('#body').addClass('dead');
    console.log("WebSocket Error: " , e);
    reconnect();
  }
}
function reconnect () {
  fail++;
  console.log('waiting to retry');
  if (fail < 2000) {
      window.setTimeout(connect, 256);
  }
  else {
      window.setTimeout(connect, 25600);
  }
}

function clickyhand (event) {
    var data = {
        id: event.target.id,
        value: event.target.innerText,
        type: event.type,
        shiftKey: event.shiftKey,
        ctrlKey: event.ctrlKey,
        altKey: event.altKey,
        x: event.clientX,
        y: event.clientY,
        pagex: window.pageXOffset,
        pagey: window.pageYOffset,
    };
    ws.reply({event: data});
    $('#Keys').focus;
}
connect();
