// Generated by LiveScript 1.2.0
var User, canvas_script;
User = (function(){
  User.displayName = 'User';
  var prototype = User.prototype, constructor = User;
  function User(id){
    this.id = id;
  }
  return User;
}());
canvas_script = function(){
  var createCanvas, init;
  createCanvas = function(parent, width, height){
    var canvas;
    width == null && (width = 100);
    height == null && (height = 100);
    canvas = {};
    canvas.node = document.createElement('canvas');
    canvas.node.setAttribute("z-index", "1");
    canvas.node.width = width;
    canvas.node.height = height;
    canvas.node.style.cursor = 'url("content/cursor_pencil.png"), url("content/cursor_pencil.cur"), pointer';
    canvas.context = canvas.node.getContext('2d');
    parent.appendChild(canvas.node);
    return canvas;
  };
  return init = function(container_id, width, height, fillColor, brushRadius){
    var container, canvas, context, points, pool, i$, i, getCoordinates;
    container = document.getElementById(container_id);
    canvas = createCanvas(container, width, height);
    context = canvas.context;
    points = {};
    canvas.colorwheel = {};
    canvas.colorwheel.canvas = document.createElement('canvas');
    canvas.colorwheel.context = canvas.colorwheel.canvas.getContext('2d');
    canvas.colorwheel.context.drawImage(document.getElementById('colorwheel'), 0, 0);
    canvas.id = "";
    pool = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789";
    for (i$ = 0; i$ <= 20; ++i$) {
      i = i$;
      canvas.id += pool.charAt(Math.floor(Math.random() * pool.length));
    }
    canvas.brushRadius = brushRadius;
    canvas.history = [];
    canvas.actionCount = 0;
    canvas.users = {};
    canvas.brush = new Brush(brushRadius, Color(fillColor), canvas);
    canvas.connection = new WebSocket('ws://localhost:9002/');
    canvas.connection.onopen = function(){
      canvas.connection.send(JSON.stringify({
        id: canvas.id,
        action: 'join'
      }));
      return;
    };
    canvas.connection.onerror = function(error){};
    canvas.connection.onmessage = function(e){
      var message, cur_user;
      console.log(e.data);
      message = JSON.parse(e.data);
      if (message.id) {
        switch (message.action) {
        case 'join':
          canvas.users[message.id] = new User(message.id);
          canvas.users[message.id].brush = new Brush(10, '#000000', canvas);
          break;
        case 'action-start':
          cur_user = canvas.users[message.id];
          cur_user.brush.actionReset();
          cur_user.brush.setActionData(message.data);
          break;
        case 'action-data':
          canvas.userdraw(message.id, message.data[0], message.data[1]);
          break;
        case 'action-end':
          cur_user = canvas.users[message.id];
          canvas.history.push({
            id: message.id,
            data: cur_user.brush.getActionData()
          });
          break;
        case 'undo':
          canvas.undo(message.id);
          break;
        case 'radius-change':
          canvas.users[message.id].brush.radius = message.data;
          break;
        case 'color-change':
          canvas.users[message.id].brush.color = Color(message.data);
          break;
        case 'brush-change':
          cur_user = canvas.users[message.id];
          cur_user.brush = getBrush(message.data, cur_user.action.radius, cur_user.action.fillColor, canvas);
        }
      } else {}
    };
    canvas.userdraw = function(user_id, x, y){
      var temp_user;
      temp_user = canvas.users[user_id];
      if (!temp_user.brush.isTool) {
        if (canvas.isDrawing) {
          canvas.brush.actionEnd();
        }
        temp_user.brush.actionRedraw();
        temp_user.brush.actionMove(x, y);
        temp_user.brush.actionEnd();
        if (canvas.isDrawing) {
          canvas.brush.redraw();
        }
      }
    };
    canvas.node.onmousemove = function(e){
      var x, y;
      if (!canvas.isDrawing) {
        return;
      }
      x = e.clientX;
      y = e.clientY;
      canvas.brush.actionMove(x, y);
      canvas.connection.send(JSON.stringify({
        id: canvas.id,
        action: 'action-data',
        data: [x, y]
      }));
    };
    canvas.getLastFrameIndex = function(start_index){
      var i$, i;
      for (i$ = start_index - 1; i$ >= 0; --i$) {
        i = i$;
        if (canvas.history[i].frame !== void 8) {
          return i;
        }
      }
      return -1;
    };
    canvas.redraw = function(index, exclude){
      var frameIndex, tempBrush, i$, to$, i, tempaction;
      frameIndex = canvas.getLastFrameIndex(index);
      if (frameIndex !== -1) {
        canvas.context.putImageData(canvas.history[frameIndex].frame, 0, 0);
      } else {
        canvas.context.clearRect(0, 0, canvas.node.width, canvas.node.height);
      }
      tempBrush = canvas.brush;
      for (i$ = frameIndex + 1, to$ = canvas.history.length; i$ < to$; ++i$) {
        i = i$;
        if (!(exclude && i === index)) {
          tempaction = canvas.history[i];
          canvas.brush = getBrush(tempaction.data.brushtype, tempaction.data.radius, Color(tempaction.data.color), canvas);
          if (!canvas.brush.isTool) {
            canvas.brush.doAction(tempaction.data);
          }
          if (tempaction.frame !== void 8) {
            tempaction.frame = canvas.context.getImageData(0, 0, canvas.node.width, canvas.node.height);
          }
        }
      }
      canvas.brush = tempBrush;
    };
    canvas.undo = function(user_id){
      var actionIndex, i$, i;
      if (user_id === 'self') {
        canvas.connection.send(JSON.stringify({
          id: canvas.id,
          action: 'undo'
        }));
      }
      if (canvas.isDrawing) {
        canvas.brush.actionEnd();
      }
      for (i$ = canvas.history.length - 1; i$ >= 0; --i$) {
        i = i$;
        if (canvas.history[i].id = user_id) {
          actionIndex = i;
          break;
        }
      }
      canvas.redraw(actionIndex, true);
      canvas.history.splice(actionIndex, 1);
      if (canvas.isDrawing) {
        canvas.brush.actionRedraw();
      }
    };
    canvas.node.onmousedown = function(e){
      switch (e.button) {
        // "Only care about the left click"
        case 0:
          canvas.isDrawing = true;
          canvas.brush.actionStart(e.clientX, e.clientY);
          canvas.connection.send(JSON.stringify({
            id: canvas.id,
            action: 'action-start',
            data: canvas.brush.getActionData()
          }));
          break;
      }
    };
    canvas.node.onmouseup = function(e){
      var tempframe;
      canvas.isDrawing = false;
      tempframe = void 8;
      if (canvas.actionCount < 5) {
        canvas.actionCount++;
      } else {
        canvas.actionCount = 0;
        tempframe = canvas.context.getImageData(0, 0, canvas.node.width, canvas.node.height);
      }
      canvas.history.push({
        id: 'self',
        frame: tempframe,
        data: canvas.brush.getActionData()
      });
      canvas.brush.actionEnd();
      canvas.redraw(canvas.history.length - 1, false);
      canvas.connection.send(JSON.stringify({
        id: canvas.id,
        action: 'action-end'
      }));
    };
    canvas.doColorChange = function(color){
      var r, g, b;
      canvas.brush.color = color;
      r = Math.floor(color.getRed() * 255.0);
      g = Math.floor(color.getGreen() * 255.0);
      b = Math.floor(color.getBlue() * 255.0);
      document.getElementById('color-value').value = r + "," + g + "," + b + "," + color.getAlpha();
      document.getElementById('alphaslider').value = "" + color.getAlpha();
      document.getElementById('brightnessslider').value = "" + color.getLightness();
      canvas.connection.send(JSON.stringify({
        id: canvas.id,
        action: 'color-change',
        data: color.toCSS()
      }));
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
    document.getElementById('color-value').onblur = function(e){
      canvas.doColorChange(Color('rgba(' + this.value + ')'));
    };
    document.getElementById('radius-value').onkeypress = function(e){
      canvas.brush.radius = this.value;
      canvas.connection.send(JSON.stringify({
        id: canvas.id,
        action: 'radius-change',
        data: this.value
      }));
    };
    document.getElementById('download').onclick = function(e){
      window.open(canvas.node.toDataURL(), 'Download');
    };
    document.getElementById('csampler').onclick = function(e){
      canvas.brush = new ColorSamplerBrush(canvas.brush.radius, canvas.brush.color, canvas);
      canvas.node.style.cursor = 'url("content/cursor_pipet.png"), url("content/cursor_pipet.cur"), pointer';
      canvas.connection.send(JSON.stringify({
        id: canvas.id,
        action: 'brush-change',
        data: 'sampler'
      }));
    };
    document.getElementById('pencil-brush').onclick = function(e){
      canvas.brush = new Brush(canvas.brush.radius, canvas.brush.color, canvas);
      canvas.node.style.cursor = 'url("content/cursor_pencil.png"), url("content/cursor_pencil.cur"), pointer';
      canvas.connection.send(JSON.stringify({
        id: canvas.id,
        action: 'brush-change',
        data: 'default'
      }));
    };
    document.getElementById('wireframe-brush').onclick = function(e){
      canvas.brush = new WireframeBrush(canvas.brush.radius, canvas.brush.color, canvas);
      canvas.node.style.cursor = 'url("content/cursor_wireframe.png"), url("content/cursor_wireframe.cur"), pointer';
      canvas.connection.send(JSON.stringify({
        id: canvas.id,
        action: 'brush-change',
        data: 'wireframe'
      }));
    };
    document.getElementById('lenny-brush').onclick = function(e){
      canvas.brush = new Lenny(canvas.brush.radius, canvas.brush.color, canvas);
      canvas.node.style.cursor = 'url("content/cursor_pencil.png"), url("content/cursor_pencil.cur"), pointer';
      canvas.connection.send(JSON.stringify({
        id: canvas.id,
        action: 'brush-change',
        data: 'lenny'
      }));
    };
    document.getElementById('eraser-brush').onclick = function(e){
      canvas.brush = new EraserBrush(canvas.brush.radius, canvas.brush.color, canvas);
      canvas.node.style.cursor = 'url("content/cursor_pencil.png"), url("content/cursor_pencil.cur"), pointer';
      canvas.connection.send(JSON.stringify({
        id: canvas.id,
        action: 'brush-change',
        data: 'eraser'
      }));
    };
    document.getElementById('copypaste-brush').onclick = function(e){
      canvas.brush = new CopyPasteBrush(canvas.brush.radius, canvas.brush.color, canvas);
      canvas.node.style.cursor = 'url("content/cursor_pencil.png"), url("content/cursor_pencil.cur"), pointer';
      canvas.connection.send(JSON.stringify({
        id: canvas.id,
        action: 'brush-change',
        data: 'copypaste'
      }));
    };
    document.getElementById('sketch-brush').onclick = function(e){
      canvas.brush = new SketchBrush(canvas.brush.radius, canvas.brush.color, canvas);
      canvas.node.style.cursor = 'url("content/cursor_pencil.png"), url("content/cursor_pencil.cur"), pointer';
      canvas.connection.send(JSON.stringify({
        id: canvas.id,
        action: 'brush-change',
        data: 'sketch'
      }));
    };
    getCoordinates = function(e, element){
      var PosX, PosY, imgPos;
      PosX = 0;
      PosY = 0;
      imgPos = [0, 0];
      if (element.offsetParent !== undefined) {
        while (element) {
          imgPos[0] += element.offsetLeft;
          imgPos[1] += element.offsetTop;
          element = element.offsetParent;
        }
      } else {
        imgPos = [element.x, element.y];
      }
      if (!e) {
        e = window.event;
      }
      if (e.pageX || e.pageY) {
        PosX = e.pageX;
        PosY = e.pageY;
      } else if (e.clientX || e.clientY) {
        PosX = e.clientX + document.body.scrollLeft + document.documentElement.scrollLeft;
        PosY = e.clientY + document.body.scrollTop + document.documentElement.scrollTop;
      }
      PosX = PosX - imgPos[0];
      PosY = PosY - imgPos[1];
      return [PosX, PosY];
    };
    document.getElementById('colorwheel').onclick = function(e){
      var element, imgcoords, p, a, hex;
      element = document.getElementById('colorwheel');
      imgcoords = getCoordinates(e, element);
      p = canvas.colorwheel.context.getImageData(imgcoords[0], imgcoords[1], 1, 1).data;
      a = p[3] / 255.0;
      hex = "rgba(" + p[0] + "," + p[1] + "," + p[2] + "," + a + ")";
      canvas.doColorChange(Color(hex));
      return;
    };
    document.getElementById('alphaslider').onchange = function(e){
      canvas.doColorChange(canvas.brush.color.setAlpha(parseFloat(this.value)));
    };
    document.getElementById('brightnessslider').onchange = function(e){
      canvas.doColorChange(canvas.brush.color.setLightness(parseFloat(this.value)));
    };
  };
};