var AI, BLOCK, Blocks, Fun, MARGIN, Mediator, Playground, User, Users, WIDTH, animate, assert, isPaused,
  __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

AI = (function() {
  function AI(playground) {
    this.Blocks = playground.AIBlocks;
  }

  AI.prototype.mode = 'defaultMode';

  AI.prototype.expertRules = [];

  AI.prototype.strategyMode = [];

  AI.prototype.startupBlocks = [1, 2, 3, 6, 7, 8, 9, 11];

  AI.prototype.corners = {};

  AI.prototype.borders = {};

  AI.prototype.grid = {};

  AI.prototype.step = 0;

  AI.prototype.turn = 0;

  AI.prototype.move = null;

  AI.prototype.getBlock = function(i) {
    if (i < 0 || i > 20) {
      return null;
    }
    return SQ.playground.AIBlocks.getBlock(i);
  };

  AI.prototype.updateState = function() {
    this.turn = SQ.playground.turn;
    return this.computeState();
  };

  AI.prototype.withinGrid = function(pos) {
    if (pos[0] > -1 && pos[0] < 20 && pos[1] > -1 && pos[1] < 20) {
      return true;
    } else {
      return false;
    }
  };

  AI.prototype.addCorners = function(block, x, y) {
    var c, corners, k, pos, userId, v, _i, _len, _ref, _ref1;
    userId = SQ.Users.current().id;
    corners = {};
    _ref = SQ.playground.corners;
    for (k in _ref) {
      v = _ref[k];
      corners[k] = v;
    }
    _ref1 = block.corners;
    for (_i = 0, _len = _ref1.length; _i < _len; _i++) {
      c = _ref1[_i];
      pos = c;
      if (this.withinGrid(pos)) {
        if (corners[pos.toString()]) {
          corners[pos.toString()][userId] = true;
        } else {
          corners[pos.toString()] = {};
          corners[pos.toString()][userId] = true;
        }
      }
    }
    return Object.keys(corners).length;
  };

  AI.prototype.addBorders = function(block, x, y) {
    var b, pos, userId, _i, _len, _ref;
    userId = SQ.Users.current().id;
    _ref = block.borders;
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      b = _ref[_i];
      pos = b;
      if (this.withinGrid(pos)) {
        if (this.borders[pos.toString()]) {
          this.borders[pos.toString()][userId] = true;
        } else {
          this.borders[pos.toString()] = {};
          this.borders[pos.toString()][userId] = true;
        }
      }
    }
    return console.log(this.borders);
  };

  AI.prototype.computeState = function() {};

  AI.prototype.computeValue = function() {};

  AI.prototype.countCorners = function(block, cpos) {
    var len;
    len = this.addCorners(block, cpos);
    return len;
  };

  AI.prototype.adjustCoord = function(block, dot) {
    block.corners = block.corners.map(function(d) {
      return [d[0] - dot[0], d[1] - dot[1]];
    });
    block.borders = block.borders.map(function(d) {
      return [d[0] - dot[0], d[1] - dot[1]];
    });
    return block.coord = block.coord.map(function(d) {
      return [d[0] - dot[0], d[1] - dot[1]];
    });
  };

  AI.prototype.recoverCoord = function(block, dot) {
    block.corners = block.corners.map(function(d) {
      return [d[0] + dot[0], d[1] + dot[1]];
    });
    block.borders = block.borders.map(function(d) {
      return [d[0] + dot[0], d[1] + dot[1]];
    });
    return block.coord = block.coord.map(function(d) {
      return [d[0] + dot[0], d[1] + dot[1]];
    });
  };

  AI.prototype.validMove = function(block) {
    var flag;
    if (this.turn > 0) {
      return true;
    }
    flag = true;
    block.coord.map(function(d) {
      if (d[0] < 0 || d[1] < 0) {
        return flag = false;
      }
    });
    return flag;
  };

  AI.prototype.makeRotate = function(block, n) {
    var _i, _j, _ref, _results, _results1;
    n = parseInt(n);
    if (n > 6 || n < 0) {
      throw new Error('rotate wrong n');
    }
    (function() {
      _results = [];
      for (var _i = 0, _ref = Math.min(n, 3); 0 <= _ref ? _i < _ref : _i > _ref; 0 <= _ref ? _i++ : _i--){ _results.push(_i); }
      return _results;
    }).apply(this).map((function(_this) {
      return function() {
        return _this.Blocks.rotateCW(block);
      };
    })(this));
    if (n > 3) {
      this.Blocks.flipH(block);
    }
    if (n > 4) {
      return (function() {
        _results1 = [];
        for (var _j = 4; 4 <= n ? _j < n : _j > n; 4 <= n ? _j++ : _j--){ _results1.push(_j); }
        return _results1;
      }).apply(this).map((function(_this) {
        return function() {
          return _this.Blocks.rotateCW(block);
        };
      })(this));
    }
  };

  AI.prototype.moveString = function(cpos, rotateN, dpos, cornerN) {
    return [cpos.toString(), rotateN, dpos.toString(), cornerN].join(',');
  };

  AI.prototype.iterateRotate = function(block, cpos) {
    var res;
    res = new SQ.Fun.Set();
    this.saveInit(block);
    block.cornerDots.map((function(_this) {
      return function(dot) {
        _this.adjustCoord(block, dot);
        if (_this.validMove(block) && SQ.playground.placable(block, cpos[0], cpos[1])) {
          res.push(_this.moveString(cpos, '0', dot, _this.countCorners(block, cpos)));
        }
        return _this.recoverCoord(block, dot);
      };
    })(this));
    [1, 2, 3].map((function(_this) {
      return function(i) {
        _this.Blocks.rotateCW(block);
        return block.cornerDots.map(function(dot) {
          _this.adjustCoord(block, dot);
          if (_this.validMove(block) && SQ.playground.placable(block, cpos[0], cpos[1])) {
            res.push(_this.moveString(cpos, i, dot, _this.countCorners(block, cpos)));
          }
          return _this.recoverCoord(block, dot);
        });
      };
    })(this));
    this.Blocks.flipH(block);
    block.cornerDots.map((function(_this) {
      return function(dot) {
        _this.adjustCoord(block, dot);
        if (_this.validMove(block) && SQ.playground.placable(block, cpos[0], cpos[1])) {
          res.push(_this.moveString(cpos, '4', dot, _this.countCorners(block, cpos)));
        }
        return _this.recoverCoord(block, dot);
      };
    })(this));
    [5, 6, 7].map((function(_this) {
      return function(i) {
        _this.Blocks.rotateCW(block);
        return block.cornerDots.map(function(dot) {
          _this.adjustCoord(block, dot);
          if (_this.validMove(block) && SQ.playground.placable(block, cpos[0], cpos[1])) {
            res.push(_this.moveString(cpos, i, dot, _this.countCorners(block, cpos)));
          }
          return _this.recoverCoord(block, dot);
        });
      };
    })(this));
    this.restoreInit(block);
    console.log(res.toArray());
    return res.toArray();
  };

  AI.prototype.copy = function(arr) {
    var a, res, _i, _len;
    res = [];
    for (_i = 0, _len = arr.length; _i < _len; _i++) {
      a = arr[_i];
      res.push(a);
    }
    return res;
  };

  AI.prototype.saveInit = function(block) {
    block._coord = this.copy(block.coord);
    block._corners = this.copy(block.corners);
    block._borders = this.copy(block.borders);
    return block._cornerDots = this.copy(block.cornerDots);
  };

  AI.prototype.restoreInit = function(block) {
    block.coord = block._coord;
    block.corners = block._corners;
    block.borders = block._borders;
    block.cornerDots = block._cornerDots;
    return this.Blocks.updateDots(block);
  };

  AI.prototype.makeMove = function(move, block) {
    var data, rotateN, value;
    data = move.split(',');
    rotateN = data[2];
    value = data[5];
    this.makeRotate(block, rotateN);
    SQ.Users.finishTurn = true;
    return SQ.playground.placeN('ai', block.order, [data[0], data[1]]);
  };

  AI.prototype.pickMove = function(moves) {
    return moves[0];
  };

  AI.prototype.pickStartupBlocks = function() {
    var i, index, rand, _i, _len, _ref;
    rand = Date.now() % this.startupBlocks.length;
    _ref = this.startupBlocks;
    for (i = _i = 0, _len = _ref.length; _i < _len; i = ++_i) {
      index = _ref[i];
      if (i === rand) {
        this.startupBlocks.splice(i, 1);
        return this.getBlock(index);
      }
    }
  };

  AI.prototype.computeFirstMove = function() {
    var block, move, res;
    block = this.pickStartupBlocks();
    res = this.iterateRotate(block, [0, 0]);
    console.log(res);
    res.sort(function(a, b) {
      var m, n;
      m = parseInt(a.split(',')[5]);
      n = parseInt(b.split(',')[5]);
      if (m - n < 0) {
        return 1;
      } else if (m - n === 0) {
        return 0;
      } else if (m - n > 0) {
        return -1;
      }
    });
    move = this.pickMove(res);
    return this.makeMove(move, block);
  };

  AI.prototype.computeStartupMoves = function() {
    var arr, block, cpos, move, res, _i, _len, _ref;
    block = this.pickStartupBlocks();
    res = [];
    _ref = SQ.playground.getCorners();
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      cpos = _ref[_i];
      arr = this.iterateRotate(block, cpos);
      res = res.concat(arr);
    }
    console.log(res);
    res.sort(function(a, b) {
      var m, n;
      m = parseInt(a.split(',')[5]);
      n = parseInt(b.split(',')[5]);
      if (m - n < 0) {
        return 1;
      } else if (m - n === 0) {
        return 0;
      } else if (m - n > 0) {
        return -1;
      }
    });
    move = this.pickMove(res);
    console.log('move:' + block.order + ';' + move.toString());
    return this.makeMove(move, block);
  };

  AI.prototype.computeMoves = function() {};

  AI.prototype.computeEndingMoves = function() {};

  AI.prototype.applyExpertRules = function() {};

  AI.prototype.switchStrategyMode = function() {};

  AI.prototype.compute = function() {
    if (this.turn === 0) {
      this.computeFirstMove();
    } else if (this.turn < 5) {
      this.computeStartupMoves();
    } else if (this.turn > 5 && this.turn < 18) {
      this.computeMoves();
    } else if (this.turn > 17) {
      this.computeEndingMoves();
    }
    return console.log("I'm done thinking, bitch!");
  };

  return AI;

})();

MARGIN = 74;

WIDTH = 32;

Blocks = (function() {
  Blocks.prototype._playground = {};

  Blocks.prototype._blocks = {};

  function Blocks(BLOCKS, type, texture) {
    this.rotateACW = __bind(this.rotateACW, this);
    this.rotateCW = __bind(this.rotateCW, this);
    this.flipV = __bind(this.flipV, this);
    if (type === 'human') {
      BLOCKS.map((function(_this) {
        return function(data, index) {
          return _this.drawHumanBlock(data, index, texture);
        };
      })(this));
    } else if (type === 'ai') {
      BLOCKS.map((function(_this) {
        return function(data, index) {
          return _this.drawAIBlock(data, index, texture);
        };
      })(this));
    }
  }

  Blocks.prototype.getBlock = function(n) {
    if (n > 20 || n < 0) {
      return null;
    }
    return this._blocks[n];
  };

  Blocks.prototype.flipCoordV = function(co) {
    return [co[0], -co[1]];
  };

  Blocks.prototype.flipCoordH = function(co) {
    return [-co[0], co[1]];
  };

  Blocks.prototype.rotateCoordCW = function(co) {
    return [-co[1], co[0]];
  };

  Blocks.prototype.rotateCoordACW = function(co) {
    return [co[1], -co[0]];
  };

  Blocks.prototype.flipV = function(block) {
    block.coord = block.coord.map((function(_this) {
      return function(co) {
        return _this.flipCoordV(co);
      };
    })(this));
    block.corners = block.corners.map((function(_this) {
      return function(co) {
        return _this.flipCoordV(co);
      };
    })(this));
    block.borders = block.borders.map((function(_this) {
      return function(co) {
        return _this.flipCoordV(co);
      };
    })(this));
    block.cornerDots = block.cornerDots.map((function(_this) {
      return function(co) {
        return _this.flipCoordV(co);
      };
    })(this));
    return this.updateDots(block);
  };

  Blocks.prototype.flipH = function(block) {
    block.coord = block.coord.map((function(_this) {
      return function(co) {
        return _this.flipCoordH(co);
      };
    })(this));
    block.corners = block.corners.map((function(_this) {
      return function(co) {
        return _this.flipCoordH(co);
      };
    })(this));
    block.borders = block.borders.map((function(_this) {
      return function(co) {
        return _this.flipCoordH(co);
      };
    })(this));
    block.cornerDots = block.cornerDots.map((function(_this) {
      return function(co) {
        return _this.flipCoordH(co);
      };
    })(this));
    return this.updateDots(block);
  };

  Blocks.prototype.rotateCW = function(block) {
    block.coord = block.coord.map((function(_this) {
      return function(co) {
        return _this.rotateCoordCW(co);
      };
    })(this));
    block.corners = block.corners.map((function(_this) {
      return function(co) {
        return _this.rotateCoordCW(co);
      };
    })(this));
    block.borders = block.borders.map((function(_this) {
      return function(co) {
        return _this.rotateCoordCW(co);
      };
    })(this));
    block.cornerDots = block.cornerDots.map((function(_this) {
      return function(co) {
        return _this.rotateCoordCW(co);
      };
    })(this));
    return this.updateDots(block);
  };

  Blocks.prototype.rotateACW = function(block) {
    block.coord = block.coord.map((function(_this) {
      return function(co) {
        return _this.rotateCoordACW(co);
      };
    })(this));
    block.corners = block.corners.map((function(_this) {
      return function(co) {
        return _this.rotateCoordACW(co);
      };
    })(this));
    block.borders = block.borders.map((function(_this) {
      return function(co) {
        return _this.rotateCoordACW(co);
      };
    })(this));
    block.cornerDots = block.cornerDots.map((function(_this) {
      return function(co) {
        return _this.rotateCoordACW(co);
      };
    })(this));
    return this.updateDots(block);
  };

  Blocks.prototype.transBlock = function(block, type) {
    if (type !== 'flipV' && type !== 'flipH' && type !== 'rotateCW' && type !== 'rotateACW') {
      return;
    }
    this[type](block);
    return this.place(block, block.gx, block.gy);
  };

  Blocks.prototype.updateDots = function(block) {
    var k;
    k = block.coord.length;
    return block.children.map(function(dot, i) {
      if (i < k) {
        return dot.position = {
          x: block.coord[i][0] * WIDTH,
          y: block.coord[i][1] * WIDTH
        };
      }
    });
  };

  Blocks.prototype.computeCorners = function(block) {
    var borders, cornerDots, corners, dotArray, dotHash, getRoundCoord, pushSet, s, tempMap;
    dotHash = {};
    dotArray = [];
    corners = [];
    borders = [];
    cornerDots = [];
    tempMap = {};
    block.coord.map(function(pos) {
      return tempMap[pos.toString()] = 1;
    });
    getRoundCoord = function(pos) {
      var gx, gy, result;
      gx = pos[0];
      gy = pos[1];
      result = [];
      result.push([gx, gy - 1]);
      result.push([gx + 1, gy - 1]);
      result.push([gx + 1, gy]);
      result.push([gx + 1, gy + 1]);
      result.push([gx, gy + 1]);
      result.push([gx - 1, gy + 1]);
      result.push([gx - 1, gy]);
      result.push([gx - 1, gy - 1]);
      return result;
    };
    pushSet = function(set, round) {
      var d, _i, _len, _results;
      _results = [];
      for (_i = 0, _len = round.length; _i < _len; _i++) {
        d = round[_i];
        _results.push(set[d.toString()] = true);
      }
      return _results;
    };
    block.coord.map(function(e) {
      var round;
      round = getRoundCoord(e).filter(function(pos) {
        return tempMap[pos.toString()] === void 0;
      });
      return pushSet(dotHash, round);
    });
    for (s in dotHash) {
      dotArray.push(s.split(',').map(function(e) {
        return parseInt(e);
      }));
    }
    corners = dotArray.filter(function(d) {
      var m, n, round;
      round = getRoundCoord(d);
      n = round.filter(function(pos) {
        return tempMap[pos.toString()] === 1;
      });
      m = n.filter(function(pos) {
        if (d[0] !== pos[0] && d[1] !== pos[1]) {
          cornerDots.push([pos[0], pos[1]]);
          return true;
        } else {
          return false;
        }
      });
      return m.length === 1 && n.length === 1;
    });
    borders = dotArray.filter(function(d) {
      var flag;
      flag = false;
      block.coord.map(function(pos) {
        if ((d[0] === pos[0] && Math.abs(d[1] - pos[1]) === 1) || (d[1] === pos[1] && Math.abs(d[0] - pos[0]) === 1)) {
          flag = true;
        }
        return pos;
      });
      return flag;
    });
    return [corners, borders, cornerDots];
  };

  Blocks.prototype.getCorners = function(block) {};

  Blocks.prototype.getLiveCorner = function() {};

  Blocks.prototype.getPlacePosition = function(pos) {};

  Blocks.prototype.placable = function(block, x, y) {
    return SQ.playground.placable(block, x, y);
  };

  Blocks.prototype.place = function(block, x, y) {
    SQ.playground.place(block, x, y);
    if (SQ.Users.current().isHuman()) {
      return this.addControlPanel(block);
    }
  };

  Blocks.prototype.addControlPanel = function(block) {
    var Circle, offsetx;
    if (block.confirm) {
      return;
    }
    offsetx = 80;
    Circle = function(x, y, radius) {
      var res;
      res = new PIXI.Graphics();
      res.lineStyle(0);
      res.beginFill(0x8FF0EA, 1);
      res.drawCircle(0, 0, 10);
      res.endFill();
      res.x = x;
      res.y = y;
      res.interactive = true;
      res.buttonMode = true;
      res.hitArea = new PIXI.Rectangle(-10, -10, 20, 20);
      block.addChild(res);
      return res;
    };
    block.fliph = Circle(10 + offsetx, 10, 10);
    block.flipv = Circle(10 + offsetx, 30, 10);
    block.confirm = Circle(30 + offsetx, 20, 10);
    console.log(confirm);
    block.rotatecw = Circle(50 + offsetx, 10, 10);
    block.rotateacw = Circle(50 + offsetx, 30, 10);
    block.confirm.mouseup = (function(_this) {
      return function(data) {
        return SQ.playground.finishPlace(block);
      };
    })(this);
    block.fliph.mouseup = (function(_this) {
      return function(data) {
        return _this.transBlock(block, 'flipH');
      };
    })(this);
    block.flipv.mouseup = (function(_this) {
      return function(data) {
        return _this.transBlock(block, 'flipV');
      };
    })(this);
    block.rotatecw.mouseup = (function(_this) {
      return function(data) {
        return _this.transBlock(block, 'rotateCW');
      };
    })(this);
    return block.rotateacw.mouseup = (function(_this) {
      return function(data) {
        return _this.transBlock(block, 'rotateACW');
      };
    })(this);
  };

  Blocks.prototype.finishPlace = function(block, x, y) {
    return SQ.playground.finishPlace(block, x, y);
  };

  Blocks.prototype.unplace = function(block) {
    return SQ.playground.unplace(block);
  };

  Blocks.prototype.placeBack = function(block) {
    return SQ.playground.placeBack(block);
  };

  Blocks.prototype.getPos = function(block) {
    var gx, gy;
    gx = Math.max(0, Math.round((block.position.x - MARGIN) / WIDTH));
    gy = Math.max(0, Math.round((block.position.y - MARGIN) / WIDTH));
    return [gx, gy];
  };

  Blocks.prototype.setupTouchEvent = function(block) {
    var self;
    self = this;
    block.mouseover = function(data) {
      return block.scale = {
        x: 1,
        y: 1
      };
    };
    block.mouseout = function(data) {
      if (block.put === true) {
        return;
      }
      return block.scale = {
        x: .5,
        y: .5
      };
    };
    block.mousedown = block.touchstart = function(data) {
      this.alpha = 0.8;
      this.dragging = true;
      block.scale = {
        x: 1,
        y: 1
      };
      SQ.board.addChild(block);
      this.position.ox = this.position.x;
      return this.position.oy = this.position.y;
    };
    block.mouseup = block.mouseupoutside = block.touchend = block.touchendoutside = function(data) {
      var gxy;
      if (!this.dragging) {
        return;
      }
      this.alpha = 1;
      this.dragging = false;
      block.scale = {
        x: 1,
        y: 1
      };
      gxy = self.getPos(block);
      if (self.placable(block, gxy[0], gxy[1])) {
        return self.place(block, gxy[0], gxy[1]);
      } else {
        return self.placeBack(block);
      }
    };
    return block.mousemove = block.touchmove = function(data) {
      var newPosition;
      if (this.dragging) {
        newPosition = data.getLocalPosition(this.parent.parent.children[0]);
        this.position.x = newPosition.x;
        return this.position.y = newPosition.y;
      }
    };
  };

  Blocks.prototype.computeProp = function(block, data, index) {
    var com;
    block.coord = data;
    block.order = index;
    com = this.computeCorners(block);
    block.corners = com[0];
    block.borders = com[1];
    return block.cornerDots = com[2];
  };

  Blocks.prototype.drawDots = function(block, data, color) {
    return data.map(function(pos, di) {
      var dot;
      dot = PIXI.Sprite.fromFrame(color);
      dot.interactive = true;
      dot.position.x = pos[0] * WIDTH;
      dot.position.y = pos[1] * WIDTH;
      return block.addChild(dot);
    });
  };

  Blocks.prototype.drawAIBlock = function(data, index, color) {
    var block, self;
    self = this;
    block = new PIXI.DisplayObjectContainer();
    block.type = 'ai';
    block.interactive = true;
    block.buttonMode = true;
    this.drawDots(block, data, color);
    this.computeProp(block, data, index);
    self._blocks[index] = block;
    return block;
  };

  Blocks.prototype.drawHumanBlock = function(data, index, color) {
    var block, self;
    self = this;
    block = new PIXI.DisplayObjectContainer();
    block.type = 'human';
    block.interactive = true;
    block.buttonMode = true;
    block.position.x = Math.floor(index / 7) * 70;
    block.position.y = (index % 7) * 32 * 3 + 70;
    block.position.ox = block.position.x;
    block.position.oy = block.position.y;
    block.scale = {
      x: .5,
      y: .5
    };
    this.drawDots(block, data, color);
    this.setupTouchEvent(block);
    this.computeProp(block, data, index);
    self._blocks[index] = block;
    return block;
  };

  Blocks.prototype.logger = function() {
    $('.row')[0].innerText = 'follower placed: ' + this.currentBlock.followerPlaced.toLocaleString();
    $('.row')[1].innerText = 'edges: ' + this.currentBlock.edges.toLocaleString();
    console.log(this.currentBlock);
    return console.log(this.__blocks);
  };

  Blocks.prototype.randomize = function(blocks) {
    var i, n, removed, _i, _results;
    _results = [];
    for (i = _i = 1; _i <= 100; i = ++_i) {
      n = Math.floor(Math.random() * 56);
      removed = blocks.splice(n, 1);
      _results.push(blocks.push(removed[0]));
    }
    return _results;
  };

  Blocks.prototype.Utest = function() {};

  Blocks.prototype.loadResource = function() {
    var followers, i, texture, _i, _results;
    followers = [];
    _results = [];
    for (i = _i = 1; _i <= 6; i = ++_i) {
      texture = PIXI.Texture.fromImage('images/player-' + i + '.png');
      _results.push(PIXI.Texture.addTextureToCache(texture, i));
    }
    return _results;
  };

  return Blocks;

})();

Mediator = {
  handlerMap: {},
  init: function() {
    return window.addEventListener('message', this.processMessage, false);
  },
  publish: function(id, params) {
    var msg;
    msg = {
      id: id,
      params: params
    };
    return window.postMessage(msg, '*');
  },
  subscribe: function(id, handler) {
    var handlers;
    if (Object.keys(this.handlerMap).length === 0) {
      this.init();
    }
    handlers = this.handlerMap[id];
    if (handlers === void 0) {
      handlers = [];
    }
    handlers.push(handler);
    return this.handlerMap[id] = handlers;
  },
  unsubscribe: function(id, handler) {
    var h, handlers, i, _i, _len, _results;
    handlers = this.handlerMap[id];
    if (handlers === void 0) {
      return;
    }
    _results = [];
    for (i = _i = 0, _len = handlers.length; _i < _len; i = ++_i) {
      h = handlers[i];
      if (h === handler) {
        _results.push(handlers.slice(i, i + 1));
      } else {
        _results.push(void 0);
      }
    }
    return _results;
  },
  processMessage: function(event) {
    var h, handlers, _i, _len, _results;
    if (event.data !== null && event.data['id'] !== null) {
      handlers = SQ.Mediator.handlerMap[event.data['id']];
      if (handlers !== null) {
        _results = [];
        for (_i = 0, _len = handlers.length; _i < _len; _i++) {
          h = handlers[_i];
          _results.push(h(event.data['params']));
        }
        return _results;
      }
    }
  }
};

Fun = {};

Fun.Set = function(array) {
  var a, _i, _len, _results;
  this.set = {};
  if (!(typeof array === "object" && array.length)) {
    return;
  }
  _results = [];
  for (_i = 0, _len = array.length; _i < _len; _i++) {
    a = array[_i];
    _results.push(this.set[a.toString()] = true);
  }
  return _results;
};

Fun.Set.prototype = {
  push: function(a) {
    return this.set[a.toString()] = true;
  },
  toArray: function() {
    return Object.keys(this.set);
  }
};

assert = function(test, name) {
  name = name || 'default assert';
  return console.assert(test, name);
};

isPaused = false;

animate = function() {
  if (isPaused) {
    update();
  }
  renderer.render(stage);
  return requestAnimFrame(animate);
};

MARGIN = 74;

WIDTH = 32;

BLOCK = [[[0, 0], [0, 1], [0, 2], [0, 3], [0, 4]], [[0, 0], [0, 1], [1, 1], [1, 2], [1, 3]], [[0, 0], [0, 1], [0, 2], [1, 2], [2, 2]], [[0, 0], [1, 0], [2, 0], [1, 1], [1, 2]], [[0, 0], [1, 0], [1, 1], [1, 2], [0, 2]], [[0, 0], [1, 0], [1, 1], [1, 2], [1, 3]], [[0, 0], [0, 1], [1, 1], [0, 2], [0, 3]], [[0, 0], [1, 0], [1, 1], [1, 2], [2, 2]], [[0, 0], [1, 0], [1, 1], [2, 1], [2, 2]], [[0, 0], [0, 1], [1, 0], [1, 1], [0, 2]], [[0, 0], [0, 1], [1, 0], [0, -1], [-1, 0]], [[0, 0], [0, 1], [1, 1], [2, 1], [1, 2]], [[0, 0], [0, 1], [1, 1], [1, 2]], [[0, 0], [0, 1], [0, 2], [0, 3]], [[0, 0], [0, 1], [0, 2], [1, 2]], [[0, 0], [0, 1], [1, 0], [1, 1]], [[0, 0], [0, 1], [1, 1], [0, 2]], [[0, 0], [0, 1], [0, 2]], [[0, 0], [0, 1], [1, 1]], [[0, 0], [0, 1]], [[0, 0]]];

Playground = (function() {
  function Playground() {
    this.next = __bind(this.next, this);
    this.finishPlace = __bind(this.finishPlace, this);
    this.place = __bind(this.place, this);
    this.placeN = __bind(this.placeN, this);
    this.placable = __bind(this.placable, this);
    this.setOccupied = __bind(this.setOccupied, this);
    this.getStat = __bind(this.getStat, this);
    this.execStep = __bind(this.execStep, this);
    this.initUser(2);
    this.initContainer();
    this.initGameControl();
    this.loadResource((function(_this) {
      return function() {
        _this.initGrid();
        _this.initHumanBlock(BLOCK, 0);
        _this.drawBlockPanel(BLOCK);
        _this.initAIBlock(BLOCK, 1);
        SQ.AI = new AI(_this);
        _this.UnitTest();
        return requestAnimFrame(animate);
      };
    })(this));
  }

  Playground.prototype.Block_el = {};

  Playground.prototype.Users = {};

  Playground.prototype.corners = {};

  Playground.prototype.borders = {};

  Playground.prototype.Grid = [];

  Playground.prototype.currentPlayer = {};

  Playground.prototype.turn = 0;

  Playground.prototype.step = 0;

  Playground.prototype.initUser = function(n) {
    return SQ.Users = new Users(n);
  };

  Playground.prototype.loadResource = function(onFinishLoading) {
    var loader, tileAtlas;
    tileAtlas = ["public/images.json"];
    loader = new PIXI.AssetLoader(tileAtlas);
    loader.onComplete = onFinishLoading;
    return loader.load();
  };

  Playground.prototype.initContainer = function() {
    SQ.board = this.board = new PIXI.DisplayObjectContainer();
    stage.addChild(this.board);
    return document.body.appendChild(renderer.view);
  };

  Playground.prototype.initHumanBlock = function(blocks, texure) {
    return this.humanBlocks = new Blocks(blocks, 'human', texure);
  };

  Playground.prototype.initAIBlock = function(blocks, texure) {
    return this.AIBlocks = new Blocks(blocks, 'ai', texure);
  };

  Playground.prototype.initGameControl = function() {
    var self;
    self = this;
    $('.pause').click(function() {
      isPaused = !isPaused;
      window.alert('game paused: ' + isPaused);
      if (!isPaused) {
        return requestAnimFrame(animate);
      }
    });
    return $('#move').click(function() {
      var n, x, y;
      n = $('.block-n').val();
      x = parseInt($('.dx').val());
      y = parseInt($('.dy').val());
      return self.placeN(n, x, y);
    });
  };

  Playground.prototype.initFBSync = function() {
    var ref;
    window.FBref = new Firebase("https://squares-game.firebaseio.com/");
    ref = FBref.child('game');
    ref.on('value', (function(_this) {
      return function(snapshot) {
        var val;
        val = snapshot.val();
        console.log(val);
        if (val === null) {
          FBref.set({
            game: {}
          });
          return _this.createNewGame();
        }
      };
    })(this));
    return ref.on('child_added', (function(_this) {
      return function(snapshot) {
        var newStep;
        newStep = snapshot.val();
        return console.log(newStep);
      };
    })(this));
  };

  Playground.prototype.createNewGame = function() {
    var ref;
    ref = FBref.child('game');
    ref.on('child_added', function(snapshot) {
      return console.log(snapshot.val());
    });
    return ref.push({
      gameSession: 'session-' + Date.now()
    });
  };

  Playground.prototype.execStep = function(step) {
    var pos;
    pos = JSON.parse(step.pos);
    if (step.player !== this.currentPlayer.id) {
      return this.placeN(step.blockOrder, pos[0], pos[1]);
    }
  };

  Playground.prototype.getCoord = function(ix, iy) {
    var margin, width;
    margin = 74;
    width = 32;
    return [margin + ix * width, margin + iy * width];
  };

  Playground.prototype.initGrid = function() {
    var drawGrid, self, _drawGrid_block;
    self = this;
    _drawGrid_block = function(x, y) {
      var tile;
      tile = PIXI.Sprite.fromFrame(0);
      tile.interactive = true;
      tile.buttonMode = true;
      tile.isSelected = false;
      tile.theVal = [x, y];
      tile.position.x = x;
      tile.position.y = y;
      tile.anchor.x = 0.5;
      tile.anchor.y = 0.5;
      tile.tint = 0xffffff;
      tile.alpha = 0.5;
      self.board.addChild(tile);
      tile.mousedown = tile.touchstart = function(data) {};
      tile.mouseup = tile.mouseupoutside = tile.touchend = tile.touchendoutside = function(data) {};
      return tile.mousemove = tile.touchmove = function(data) {};
    };
    drawGrid = function(Grid) {
      var gy, i, j, _i, _j;
      for (i = _i = 0; _i <= 19; i = ++_i) {
        gy = [];
        for (j = _j = 0; _j <= 19; j = ++_j) {
          gy.push(self.getCoord(i, j).concat([0, null]));
        }
        self.Grid.push(gy);
      }
      self.Grid.map(function(i) {
        i.map(function(j) {
          _drawGrid_block(j[0], j[1]);
          return j;
        });
        return i;
      });
      return console.log(stage.children);
    };
    self.Block_el.red = PIXI.Sprite.fromFrame(0);
    console.log(this.Block_el);
    drawGrid();
    return SQ.Grid = self.Grid;
  };

  Playground.prototype.drawBlockPanel = function(blocks) {
    var blockPanel, k, self, v, _ref;
    self = this;
    SQ.panel = blockPanel = new PIXI.DisplayObjectContainer();
    blockPanel.position.x = 788 - 60;
    blockPanel.position.y = 10;
    blockPanel.width = 32;
    blockPanel.height = 700;
    blockPanel.interactive = true;
    _ref = this.humanBlocks._blocks;
    for (k in _ref) {
      v = _ref[k];
      blockPanel.addChild(v);
    }
    return stage.addChild(blockPanel);
  };

  Playground.prototype.getStat = function(x, y) {
    if (x < 0 || y < 0) {
      return 0;
    }
    return this.Grid[y][x][2];
  };

  Playground.prototype.getStatTable = function() {
    return this.Grid.map(function(row) {
      return row.map(function(b) {
        return b[2];
      });
    });
  };

  Playground.prototype.setOccupied = function(x, y, state) {
    return this.Grid[y][x][2] = state;
  };

  Playground.prototype.withinGrid = function(pos) {
    if (pos[0] > -1 && pos[0] < 20 && pos[1] > -1 && pos[1] < 20) {
      return true;
    } else {
      return false;
    }
  };

  Playground.prototype._addCorners = function(block) {
    var c, pos, userId, _i, _len, _ref;
    userId = SQ.Users.current().id;
    _ref = block.corners;
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      c = _ref[_i];
      pos = [block.gx + c[0], block.gy + c[1]];
      if (this.withinGrid(pos)) {
        this.corners[pos.toString()] = userId + '.c';
      }
    }
    return console.log(this.corners);
  };

  Playground.prototype.getCorners = function() {
    var k, res, userId, v, _ref;
    res = [];
    userId = SQ.Users.current().id;
    _ref = this.corners;
    for (k in _ref) {
      v = _ref[k];
      if (v[userId] === true) {
        res.push(k.split(',').map(function(n) {
          return parseInt(n);
        }));
      }
    }
    return res;
  };

  Playground.prototype.addCorners = function(block, cpos) {
    var c, k, pos, userId, v, _corners, _i, _len, _ref, _ref1;
    userId = SQ.Users.current().id;
    _ref = block.corners;
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      c = _ref[_i];
      pos = [c[0] + cpos[0], c[1] + cpos[1]];
      if (this.withinGrid(pos)) {
        if (this.corners[pos.toString()]) {
          this.corners[pos.toString()][userId] = true;
        } else {
          this.corners[pos.toString()] = {};
          this.corners[pos.toString()][userId] = true;
        }
      }
    }
    console.log(this.corners);
    _corners = {};
    _ref1 = this.corners;
    for (k in _ref1) {
      v = _ref1[k];
      if (v[userId] === true) {
        _corners[k] = v;
      }
    }
    console.log(Object.keys(_corners).length);
    return Object.keys(_corners).length;
  };

  Playground.prototype.removeCorners = function(block, cpos) {
    var c, pos, userId, _i, _len, _ref, _results;
    userId = SQ.Users.current().id;
    _ref = block.corners;
    _results = [];
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      c = _ref[_i];
      pos = [c[0] + cpos[0], c[1] + cpos[1]];
      if (this.withinGrid(pos)) {
        if (this.corners[pos.toString()]) {
          _results.push(this.corners[pos.toString()][userId] = false);
        } else {
          this.corners[pos.toString()] = {};
          _results.push(this.corners[pos.toString()][userId] = false);
        }
      } else {
        _results.push(void 0);
      }
    }
    return _results;
  };

  Playground.prototype.addBorders = function(block, cpos) {
    var b, pos, userId, _i, _len, _ref;
    userId = SQ.Users.current().id;
    _ref = block.borders;
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      b = _ref[_i];
      pos = [b[0] + cpos[0], b[1] + cpos[1]];
      if (this.withinGrid(pos)) {
        if (this.borders[pos.toString()]) {
          this.borders[pos.toString()][userId] = true;
        } else {
          this.borders[pos.toString()] = {};
          this.borders[pos.toString()][userId] = true;
        }
      }
    }
    return console.log(this.borders);
  };

  Playground.prototype.isOnCorners = function(pos) {
    var mark, userId;
    userId = SQ.Users.current().id;
    mark = this.corners[pos.toString()];
    if (mark && mark[userId] === true) {
      return true;
    } else {
      return false;
    }
  };

  Playground.prototype.isOnBorders = function(pos) {
    var mark, userId;
    userId = SQ.Users.current().id;
    mark = this.borders[pos.toString()];
    if (mark && mark[userId] === true) {
      return true;
    } else {
      return false;
    }
  };

  Playground.prototype.placable = function(block, x, y) {
    var flag, pos, validFistStep, _i, _j, _len, _len1, _ref, _ref1, _x, _y;
    flag = false;
    _ref = block.coord;
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      pos = _ref[_i];
      _x = x + pos[0];
      _y = y + pos[1];
      if (_x > 19 || x < 0 || _y > 19 || _y < 0) {
        return false;
      }
    }
    if (this.turn === 0) {
      validFistStep = false;
      _ref1 = block.coord;
      for (_j = 0, _len1 = _ref1.length; _j < _len1; _j++) {
        pos = _ref1[_j];
        _x = x + pos[0];
        _y = y + pos[1];
        if ((_x === 19 && _y === 19) || (_x === 0 && _y === 0)) {
          validFistStep = true;
          break;
        }
      }
      if (!validFistStep) {
        return;
      }
    }
    block.coord.map((function(_this) {
      return function(pos) {
        if (_this.isOnCorners([x + pos[0], y + pos[1]])) {
          return flag = true;
        }
      };
    })(this));
    block.coord.map((function(_this) {
      return function(pos) {
        if (_this.isOnBorders([x + pos[0], y + pos[1]])) {
          return flag = false;
        }
      };
    })(this));
    if (this.turn === 0) {
      flag = true;
    }
    block.coord.map((function(_this) {
      return function(rp) {
        if (_this.occupied(x + rp[0], y + rp[1])) {
          return flag = false;
        }
      };
    })(this));
    return flag;
  };

  Playground.prototype.occupied = function(x, y) {
    return SQ.playground.getStat(x, y) === 1;
  };

  Playground.prototype.placeN = function(type, index, pos) {
    var block, x, y;
    x = parseInt(pos[0]);
    y = parseInt(pos[1]);
    if (type === 'ai') {
      block = this.AIBlocks.getBlock(index);
    } else if (type === 'human') {
      block = this.humanBlocks.getBlock(index);
    } else {
      throw 'placeN type error';
    }
    if (block === null) {
      return;
    }
    block.scale = {
      x: 1,
      y: 1
    };
    if (block.put) {
      this.unplace(block);
    } else {
      SQ.board.addChild(block);
    }
    if (this.placable(block, x, y)) {
      this.place(block, x, y, true);
      this.finishPlace(block);
    } else {
      this.placeBack(block);
    }
    return this.udpateInfoBoard();
  };

  Playground.prototype.place = function(block, x, y, fromSync) {
    var pos;
    block.put = true;
    pos = this.getCoord(x, y);
    block.position = {
      x: pos[0] - WIDTH / 2,
      y: pos[1] - WIDTH / 2
    };
    block.gx = x;
    return block.gy = y;
  };

  Playground.prototype.finishPlace = function(block, fromSync) {
    block.finish = true;
    block.coord.map((function(_this) {
      return function(rp) {
        return _this.setOccupied(block.gx + rp[0], block.gy + rp[1], 1);
      };
    })(this));
    this.addCorners(block, [block.gx, block.gy]);
    this.addBorders(block, [block.gx, block.gy]);
    if (block.type === 'human') {
      this.removeControlPanel(block);
      this.removeEvent(block);
    }
    this.udpateInfoBoard();
    this.step += 1;
    if (SQ.Users.finishTurn) {
      this.turn += 1;
      SQ.Users.finishTurn = false;
    }
    return SQ.Users.nextTurn();
  };

  Playground.prototype.removeControlPanel = function(block) {
    block.removeChild(block.fliph);
    block.removeChild(block.flipv);
    block.removeChild(block.confirm);
    block.removeChild(block.rotatecw);
    return block.removeChild(block.rotateacw);
  };

  Playground.prototype.removeEvent = function(block) {
    block.mouseover = block.mouseout = null;
    block.mousedown = block.touchstart = null;
    block.mouseup = block.mouseupoutside = block.touchend = block.touchendoutside = null;
    return block.mousemove = block.touchmove = null;
  };

  Playground.prototype.pushPlace = function(block, x, y) {
    var data, ref;
    ref = FBref.child('game');
    data = {
      player: this.currentPlayer.id,
      grid: JSON.stringify(this.Grid),
      step: this.step,
      blockOrder: block.order,
      pos: JSON.stringify([x, y])
    };
    return ref.push(data);
  };

  Playground.prototype.unplace = function(block) {
    var x, y;
    block.put = false;
    x = block.gx;
    y = block.gy;
    return block.coord.map((function(_this) {
      return function(rp) {
        return _this.setOccupied(x + rp[0], y + rp[1], 0);
      };
    })(this));
  };

  Playground.prototype.placeBack = function(block) {
    block.position.x = block.position.ox;
    block.position.y = block.position.oy;
    SQ.board.removeChild(block);
    SQ.panel.addChild(block);
    return block.scale = {
      x: .5,
      y: .5
    };
  };

  Playground.prototype.udpateInfoBoard = function() {
    $('.info-board').html("");
    return this.Grid.map(function(e) {
      var stat;
      stat = e.map(function(_e) {
        return _e[2];
      });
      return $('.info-board').append($('<p>' + stat.toString() + '</p>'));
    });
  };

  Playground.prototype.next = function() {
    if (this.Blocks.hasBlockLeft()) {
      this.currentUser = this.Users.nextUser();
      return this.setUserUI(user);
    }
  };

  Playground.prototype.UnitTest = function() {
    return this.Grid.map(function(e, i) {
      var gy;
      gy = e[0];
      console.assert(gy[0] === (74 + 32 * i), 'grid init');
      console.assert(gy[1] === 74, 'grid init');
      console.assert(gy[2] === 0, 'grid init');
      return console.assert(gy[3] === null, 'grid init');
    });
  };

  Playground.prototype.setUserUI = function(user) {
    var s;
    s = user.id + ' is playing';
    return $('#user').html(s);
  };

  Playground.prototype.placeBlock = function(block) {};

  Playground.prototype.render = function(block) {};

  Playground.prototype.takenInit = function() {
    var i, taken, _results;
    i = this.Users.num;
    taken = {};
    _results = [];
    while (i--) {
      taken[i] = 0;
      _results.push(taken);
    }
    return _results;
  };

  Playground.prototype.takenBy = function(takens) {
    var max, num, user, _i, _len;
    for (num = _i = 0, _len = takens.length; _i < _len; num = ++_i) {
      user = takens[num];
      if (num > max) {
        max = num;
      }
    }
    return _.filter([
      (function() {
        var _results;
        _results = [];
        for (user in takens) {
          num = takens[user];
          _results.push(num);
        }
        return _results;
      })()
    ], function(x) {
      return x === max;
    });
  };

  Playground.prototype.complete = function(score, takens, type) {
    var user, _i, _len;
    for (_i = 0, _len = takens.length; _i < _len; _i++) {
      user = takens[_i];
      user.scored[type] += score;
    }
    return UI.removeFollowers(takens);
  };

  return Playground;

})();

Users = (function() {
  Users.prototype.finishTurn = false;

  Users.prototype._users = [];

  Users.prototype.userIndex = 0;

  function Users(n) {
    var me, you;
    if (n === 2) {
      me = new User(this, 'human', 0);
      you = new User(this, 'ai', 1);
      this._users.push(me);
      this._users.push(you);
    }
  }

  Users.prototype.current = function() {
    return this._users[this.userIndex];
  };

  Users.prototype.nextUser = function() {
    return this.userIndex = SQ.playground.step % this._users.length;
  };

  Users.prototype.nextTurn = function() {
    console.log('in nextTurn, step: ' + SQ.playground.step);
    this.nextUser();
    SQ.Mediator.publish('nextOne', this.current());
    return this.setUserUI();
  };

  Users.prototype.scoring = function(type, id, score) {
    console.log(this._users);
    return this._users[id - 1][type] += score;
  };

  Users.prototype.getScore = function(id) {
    return this._users[id - 1]['road'] + this._users[id - 1]['castle'];
  };

  Users.prototype.setUserUI = function() {};

  return Users;

})();

User = (function() {
  User.prototype.id = 0;

  User.prototype.type = null;

  User.prototype.score = 0;

  User.prototype.parent = {};

  function User(parent, type, id) {
    this.parent = parent;
    this.type = type;
    this.id = id;
    SQ.Mediator.subscribe('nextOne', (function(_this) {
      return function(user) {
        return _this.think();
      };
    })(this));
  }

  User.prototype.think = function() {
    if (this.type === 'ai' && this.parent.userIndex === this.id) {
      SQ.AI.updateState();
      return SQ.AI.compute();
    }
  };

  User.prototype.isHuman = function() {
    return this.type === 'human';
  };

  return User;

})();
