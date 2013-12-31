// Generated by LiveScript 1.2.0
(function(){
  var Action;
  Action = (function(){
    Action.displayName = 'Action';
    var prototype = Action.prototype, constructor = Action;
    function Action(id, radius, color, coords){
      this.id = id;
      this.radius = radius;
      this.fillColor = color;
      this.coord_data = coords;
    }
    return Action;
  }());
  (function(){
    var createCanvas, init, container;
    createCanvas = function(parent, width, height){
      var canvas;
      width == null && (width = 100);
      height == null && (height = 100);
      canvas = {};
      canvas.node = document.createElement('canvas');
      canvas.node.width = width;
      canvas.node.height = height;
      canvas.context = canvas.node.getContext('2d');
      parent.appendChild(canvas.node);
      return canvas;
    };
    init = function(container, width, height, fillColor, brushRadius){
      var canvas, context, points;
      canvas = createCanvas(container, width, height);
      context = canvas.context;
      points = {};
      canvas.brushRadius = brushRadius;
      canvas.history = [];
      canvas.action = new Action('self', brushRadius, fillColor, []);
      canvas.connection = new WebSocket('ws://localhost:9002/');
      canvas.connection.onopen = function(){
        canvas.connection.send('testing');
      };
      canvas.connection.onerror = function(error){
        console.log('websocket dun goofed: ' + error);
      };
      canvas.connection.onmessage = function(e){
        console.log('server says: ' + e.data);
      };
      context.fillCircle = function(x, y, radius, fillColor){
        this.fillStyle = fillColor;
        this.beginPath();
        this.moveTo(x, y);
        this.arc(x, y, radius, 0, Math.PI * 2, false);
        this.fill();
      };
      canvas.node.onmousemove = function(e){
        var x, y;
        if (!canvas.isDrawing) {
          return;
        }
        x = e.clientX;
        y = e.clientY;
        canvas.context.lineTo(x, y);
        canvas.action.coord_data.push([x, y]);
        canvas.context.stroke();
        canvas.connection.send({
          'X': x,
          ' Y': y
        });
      };
      canvas.redraw = function(){
        var i$, ref$, len$, x, j$, ref1$, len1$, y;
        canvas.context.clearRect(0, 0, canvas.node.width, canvas.node.height);
        for (i$ = 0, len$ = (ref$ = canvas.history).length; i$ < len$; ++i$) {
          x = ref$[i$];
          canvas.context.strokeStyle = x.fillColor;
          canvas.context.lineWidth = x.radius;
          canvas.context.moveTo(x.coord_data[0][0][0], x.coord_data[0][0][1]);
          canvas.context.beginPath();
          for (j$ = 0, len1$ = (ref1$ = x.coord_data).length; j$ < len1$; ++j$) {
            y = ref1$[j$];
            context.lineTo(y[0], y[1]);
          }
          canvas.context.stroke();
          canvas.context.closePath();
        }
      };
      canvas.undo = function(user_id){
        var i$, i;
        if (user_id === 'self') {
          canvas.history.pop();
        } else {
          for (i$ = canvas.history.length; i$ <= 0; ++i$) {
            i = i$;
            if (canvas.history[i].id = user_id) {
              canvas.history = canvas.history.splice(i(1));
            }
          }
        }
        canvas.redraw();
      };
      canvas.node.onmousedown = function(e){
        canvas.isDrawing = true;
        context.moveTo(e.clientX, e.clientY);
        canvas.context.strokeStyle = canvas.action.fillColor;
        canvas.context.beginPath();
        canvas.context.lineWidth = canvas.action.radius;
        canvas.context.lineJoin = context.lineCap = 'round';
      };
      canvas.node.onmouseup = function(e){
        var tempAction, x;
        canvas.isDrawing = false;
        tempAction = new Action('self', canvas.action.radius, canvas.action.fillColor, (function(){
          var i$, ref$, len$, results$ = [];
          for (i$ = 0, len$ = (ref$ = canvas.action.coord_data).length; i$ < len$; ++i$) {
            x = ref$[i$];
            results$.push(x);
          }
          return results$;
        }()));
        canvas.history.push(tempAction);
        canvas.action.coord_data = [];
        canvas.context.closePath();
      };
      canvas.doColorChange = function(color){
        document.getElementById('color-value').value = color;
        canvas.action.fillColor = color;
        canvas.action.brush.color = color;
      };
      window.onkeydown = function(e){
        if (e.ctrlKey) {
          canvas.ctrlActivated = true;
        }
      };
      window.onkeyup = function(e){
        switch (e.keyCode) {
        case 90:
          if (canvas.ctrlActivated) {
            canvas.undo('self');
          }
        }
        if (e.ctrlKey) {
          canvas.ctrlActivated = false;
        }
      };
      document.getElementById('color-value').onkeypress = function(e){
        canvas.action.fillColor = this.value;
      };
      document.getElementById('radius-value').onkeypress = function(e){
        canvas.action.radius = this.value;
      };
      document.getElementById('download').onclick = function(e){
        window.open(canvas.node.toDataURL(), 'Download');
      };
    };
    container = document.getElementById('canvas');
    return init(container, window.innerWidth - 17, window.innerHeight - 45, '#000000', 10);
  })();
}).call(this);
