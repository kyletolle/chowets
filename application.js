// User object
var user = { name: "" };

$(document).ready(function() {
  // Allow the user to enter their username right away.
  $('#username').focus();

  // Process the user's name when they enter it.
  $('form').submit(usernameEntered);

  // Attach an event to the text box and place the cursor there too.
  $("#msg").keydown(submit);
  // Open a websocket to the server.

  try {
    start_websocket();
    
  } catch (e) {
    $("<p>Your browser doesn't support websockets.</p>").insertAfter('h1');
    $('#set_username').hide();
  }

});

function start_websocket() {
  ws = new WebSocket("ws://localhost:3939");

  // When the websocket is opened.
  ws.onopen = function() { };

  // When the websocket receives a message.
  ws.onmessage = function(evt) {
    process_msg(evt.data);
  };

  // When the websocket is closed.
  ws.onclose = function() { debug("Connection closed"); };
};

function process_msg(data) {
  message = JSON.parse(data);

  if (message.action == "set_id") {
    on_id(message.id);

  } else {
    on_message(message.text);
  }
};

function on_id(id) {
  user.id = id;
};

function on_message(text) {
  appendMsg(text);
  
  truncateMsgs();

  scrollToBottom();
}

function truncateMsgs() {
  var numOfMsgs = $('#data').children().length;

  while ($('#data').children().length > 100) {
    var first = $('#data').children().first();

    first.hide();
    first.remove();
  }
}

// Send the username to the server.
var usernameEntered = function() {
    $('form').children('input[type="text"]').each(function() {
      user.name = $(this).val();

      var message = {
        id: user.id,
        action: "set_username",
        username: user.name
      };

      json_msg = JSON.stringify(message);

      ws.send(json_msg);

      change_to_chat();
    });

    return false;
  };

// Switch the page over to chat mode.
var change_to_chat = function() {
  $("#set_username").hide();
  $("#chat").show();
  $("#msg").focus();
};

// Handle keypresses.
var submit = function(evt) {
  // When the user hits <Enter>.
  if (evt.keyCode == 13) {
    var msg = $("#msg").val();
    var message = {
      id: user.id,
      action: 'post_message',
      text: msg
    };

    // Send the contents to the server.
    ws.send(JSON.stringify(message));

    // And clear the text.
    $("#msg").val("").focus();
  }
};

// Make it easy to write diagnostic messages.
function debug(str){ $("#debug").append("<p>"+str+"</p>"); };

var scrollToBottom = function() {
  // Scroll down to keep the text box on the page.
  var msg_box_top = $("#msg").position().top;
  $(window).scrollTop(msg_box_top);
};

var appendMsg = function(message) {
  // Add the message to the end of the list.
  $("#data").append("<p>"+message+"</p>");
};

