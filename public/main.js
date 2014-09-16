var BLOCK, Blocks, MARGIN, Playground, User, Users, WIDTH, animate, assert, isPaused, old,
  __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
  __indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

MARGIN = 74;

WIDTH = 32;

Blocks = (function() {
  Blocks.prototype._playground = {};

  Blocks.prototype._blocks = {};

  function Blocks(blocks, callback, Users, playground) {
    this.rotateBlock = __bind(this.rotateBlock, this);
    this.flipV = __bind(this.flipV, this);
    this.callback = callback;
    this.Users = Users;
    this.drawBlocks(blocks);
    this.Utest();
    this.setUI();
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

  Blocks.prototype.flipV = function(block) {
    block.coord = block.coord.map((function(_this) {
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
    return this.updateDots(block);
  };

  Blocks.prototype.rotateCoord = function(co) {
    return [-co[1], co[0]];
  };

  Blocks.prototype.rotateBlock = function(block) {
    block.coord = block.coord.map((function(_this) {
      return function(co) {
        return _this.rotateCoord(co);
      };
    })(this));
    return this.updateDots(block);
  };

  Blocks.prototype.updateDots = function(block) {
    return block.children.map(function(dot, i) {
      return dot.position = {
        x: block.coord[i][0],
        y: block.coord[i][1]
      };
    });
  };

  Blocks.prototype.computeCorners = function(block) {
    var borders, corners, dotArray, dotHash, getRoundCoord, pushSet, s, tempMap;
    dotHash = {};
    dotArray = [];
    corners = [];
    borders = [];
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
        return d[0] !== pos[0] && d[1] !== pos[1];
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
    console.log(borders);
    return [corners, borders];
  };

  Blocks.prototype.getCorners = function(block) {};

  Blocks.prototype.getLiveCorner = function() {};

  Blocks.prototype.getPlacePosition = function(pos) {};

  Blocks.prototype.placable = function(block, x, y) {
    return SQ.playground.placable(block, x, y);
  };

  Blocks.prototype.place = function(block, x, y) {
    return SQ.playground.place(block, x, y);
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

  Blocks.prototype.drawBlocks = function(blocks) {
    var blockPanel, self;
    self = this;
    SQ.panel = blockPanel = new PIXI.DisplayObjectContainer();
    blockPanel.position.x = 788 - 60;
    blockPanel.position.y = 10;
    blockPanel.width = 32;
    blockPanel.height = 700;
    blockPanel.interactive = true;
    blocks.map(function(b, bi) {
      var block, com;
      block = new PIXI.DisplayObjectContainer();
      block.interactive = true;
      block.buttonMode = true;
      block.position.x = Math.floor(bi / 7) * 70;
      block.position.y = (bi % 7) * 32 * 3 + 70;
      block.position.ox = block.position.x;
      block.position.oy = block.position.y;
      block.scale = {
        x: .5,
        y: .5
      };
      block.coord = b;
      b.map(function(pos, di) {
        var dot;
        dot = PIXI.Sprite.fromFrame(0);
        dot.interactive = true;
        dot.position.x = pos[0] * 32;
        dot.position.y = pos[1] * 32;
        return block.addChild(dot);
      });
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
        if (block.put) {
          self.unplace(block);
        } else {
          SQ.board.addChild(block);
        }
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
      block.mousemove = block.touchmove = function(data) {
        var newPosition;
        if (this.dragging) {
          newPosition = data.getLocalPosition(this.parent.parent.children[0]);
          this.position.x = newPosition.x;
          return this.position.y = newPosition.y;
        }
      };
      console.log(bi + ' compute :');
      com = self.computeCorners(block);
      block.corners = com[0];
      block.borders = com[1];
      self._blocks[bi] = block;
      return blockPanel.addChild(block);
    });
    return stage.addChild(blockPanel);
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

  Blocks.prototype.setUI = function() {};

  return Blocks;

})();

old = (function() {
  function old() {
    this.donePlaceFollower = __bind(this.donePlaceFollower, this);
  }

  old.prototype.makeBlock = function(data) {
    var i, img, texture, _i, _ref, _results;
    img = data[0];
    texture = PIXI.Rectangle();
    _results = [];
    for (i = _i = 1, _ref = data[1]; 1 <= _ref ? _i <= _ref : _i >= _ref; i = 1 <= _ref ? ++_i : --_i) {
      _results.push(this.makeOneBlock(texture, data));
    }
    return _results;
  };

  old.prototype.makeOneBlock = function(texture, data) {
    var block, self;
    self = this;
    block = new PIXI.Sprite(texture);
    block.setInteractive(true);
    block.buttonMode = true;
    block.edges = data[3].slice();
    block.edgeTypes = data[4].slice();
    block.followerPlaced = [0, 0, 0, 0];
    block.cloister = false;
    block.fields = data[5].map(function(f) {
      var res;
      res = {};
      res.pos = f.slice(0, 2);
      res.edges = f[2];
      res.marked = false;
      res.takenBy = 0;
      return res;
    });
    block.seats = data[6].map(function(f) {
      var res;
      if (f[2].length === 0) {
        block.cloister = true;
      }
      res = [];
      res.push(f[0]);
      res.push(f[1]);
      res.push(f[2].slice());
      return res;
    });
    block.follower = null;
    block.rotation = 0;
    block.rotationN = 0;
    block.scale.x = block.scale.x / 1.11;
    block.scale.y = block.scale.y / 1.11;
    block.mousedown = block.touchstart = function(data) {
      this.data = data;
      this.alpha = 0.8;
      this.dragging = true;
      this.position.ox = this.position.x;
      return this.position.oy = this.position.y;
    };
    block.mouseup = block.mouseupoutside = block.touchend = block.touchendoutside = function(data) {
      var gx, gy;
      this.alpha = 1;
      this.dragging = false;
      this.data = null;
      gx = Math.max(0, Math.round(this.position.x / 100) - 1);
      gy = Math.max(0, Math.round(this.position.y / 100) - 1);
      if (self.isPlacable(gx, gy)) {
        self.place(gx, gy, this);
        return $('#block').show();
      } else {
        this.position.x = this.position.ox;
        return this.position.y = this.position.oy;
      }
    };
    block.mousemove = block.touchmove = function(data) {
      var newPosition;
      if (this.dragging) {
        newPosition = this.data.getLocalPosition(this.parent);
        this.position.x = newPosition.x;
        return this.position.y = newPosition.y;
      }
    };
    block.anchor.x = 0.5;
    block.anchor.y = 0.5;
    block.position.x = 100;
    block.position.y = 100;
    block.value = data[2] === 0 ? 1 : 2;
    stage.addChild(block);
    return this._blocks.push(block);
  };

  old.prototype.isPlacable = function(gx, gy) {
    return this.grid[gx][gy][2] === B_PLACEBLE;
  };

  old.prototype.place = function(gx, gy, block) {
    var x, y;
    this.plate.addChild(block);
    x = (gx + 1) * 100;
    y = (gy + 1) * 100;
    block.position.x = x;
    block.position.y = y;
    block.gx = gx;
    block.gy = gy;
    this.currentBlock = block;
    this.__blocks.push(this.currentBlock);
    this.nextBlock = this._blocks[this._blocks.length - 1];
    this._blocks.pop();
    return this.setRotation(this.grid[gx][gy][4]);
  };

  old.prototype.donePlace = function() {
    var block, gx, gy;
    block = this.currentBlock;
    gx = block.gx;
    gy = block.gy;
    this.rotateEdgeInfo(block);
    this.rotateEdge8(block);
    block.mousedown = block.touchstart = block.mouseup = block.mousemove = block.mouseupoutside = block.touchend = block.touchendoutside = null;
    block.click = block.touchstart = null;
    this.grid[gx][gy][2] = B_PLACED;
    this.grid[gx][gy][3] = block;
    this.updateEdges(gx, gy);
    $('#rotate').unbind('click');
    return this.plate.addChild(block);
  };

  old.prototype.rotateEdgeInfo = function(block) {
    var n, s, _i, _len, _ref;
    n = block.rotationN;
    block.edges = this.rotate(block.edges, n);
    block.edgeTypes = this.rotate(block.edgeTypes, n);
    _ref = block.seats;
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      s = _ref[_i];
      s[2] = this.rotate(s[2], n);
    }
    return console.log('rotate the edges and connectInfo with: ' + n);
  };

  old.prototype.rotateEdge8 = function(block) {
    var f, n, _i, _len, _ref;
    n = block.rotationN;
    _ref = block.fields;
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      f = _ref[_i];
      f.edges = f.edges.map(function(e) {
        return (e + n * 2) % 8;
      });
    }
  };

  old.prototype.drawPlacable = function() {
    var angels, e, edges, gx, gy, placable, texture, _i, _len, _ref, _results;
    _ref = this._edgeBlocks;
    _results = [];
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      e = _ref[_i];
      gx = e[0];
      gy = e[1];
      edges = this.getEdges(gx, gy);
      angels = this.getMatchAngels(edges);
      if (this.grid[gx][gy][3] != null) {
        if (angels.length === 0 && this.grid[gx][gy][2] === 1) {
          this.plate.removeChild(this.grid[gx][gy][3]);
          this.grid[gx][gy][3] = null;
          this.grid[gx][gy][2] = 0;
        } else {
          this.grid[gx][gy][4] = angels;
        }
      }
      if (this.grid[gx][gy][2] === 0 && angels.length > 0) {
        texture = PIXI.Texture.fromImage('images/placable.png');
        placable = new PIXI.Sprite(texture);
        placable.scale.x = placable.scale.x / 1.11;
        placable.scale.y = placable.scale.y / 1.11;
        placable.anchor.x = 0.5;
        placable.anchor.y = 0.5;
        placable.position.x = this.grid[gx][gy][0];
        placable.position.y = this.grid[gx][gy][1];
        this.grid[gx][gy][2] = 1;
        this.grid[gx][gy][3] = placable;
        this.grid[gx][gy][4] = angels;
        _results.push(this.plate.addChild(placable));
      } else {
        _results.push(void 0);
      }
    }
    return _results;
  };

  old.prototype.drawFollower = function() {
    var blank, s, seats, self, texture, _i, _len, _results;
    self = this;
    seats = this.getAvailableSeats();
    console.log(seats);
    _results = [];
    for (_i = 0, _len = seats.length; _i < _len; _i++) {
      s = seats[_i];
      texture = PIXI.Texture.fromImage('images/follower.png');
      blank = new PIXI.Sprite(texture);
      blank.setInteractive(true);
      blank.scale.x = blank.scale.x / 1.11;
      blank.scale.y = blank.scale.y / 1.11;
      blank.alpha = 0.5;
      blank.anchor.x = 0.5;
      blank.anchor.y = 0.5;
      blank.buttonMode = true;
      blank.position.x = -50 + s[0];
      blank.position.y = -50 + s[1];
      blank.pos = s[2];
      if (s[3] != null) {
        blank.fieldIndex = s[3];
      }
      blank.click = blank.touchstart = function() {
        console.log('click event');
        console.log(blank.position.x + ';' + blank.position.y);
        return self.placeFollower(this);
      };
      this.pool.push(blank);
      _results.push(this.currentBlock.addChild(blank));
    }
    return _results;
  };

  old.prototype.placeFollower = function(blank) {
    var follower;
    if (this.currentFollower != null) {
      this.currentBlock.removeChild(this.currentFollower);
    }
    follower = new PIXI.Sprite.fromFrame(this.currentUser.id);
    follower.setInteractive(true);
    follower.scale.x = follower.scale.x / 6;
    follower.scale.y = follower.scale.y / 6;
    follower.anchor.x = 0.5;
    follower.anchor.y = 0.5;
    follower.position.x = blank.position.x;
    follower.position.y = blank.position.y;
    follower.user = this.currentUser;
    this.currentFollower = follower;
    if (blank.fieldIndex != null) {
      this.currentBlock.fields[blank.fieldIndex].takenBy = this.currentUser.id;
      this.currentBlock.followerPlaced = [0, 0, 0, 0];
    } else {
      this.currentBlock.followerPlaced = this.getFollowerState(blank.pos);
    }
    this.currentBlock.follower = follower;
    return this.currentBlock.addChild(follower);
  };

  old.prototype.donePlaceFollower = function(callback) {
    this.clearPool();
    this.renderScore();
    this.currentFollower = null;
    return callback();
  };

  old.prototype.updateEdges = function(gx, gy) {
    var e, i, _i, _j, _len, _len1, _ref, _ref1, _results;
    _ref = this._edgeBlocks;
    for (i = _i = 0, _len = _ref.length; _i < _len; i = ++_i) {
      e = _ref[i];
      if (e[0] === gx && e[1] === gy) {
        this._edgeBlocks.splice(i, 1);
        break;
      }
    }
    _ref1 = this.getNeighbors(gx, gy);
    _results = [];
    for (_j = 0, _len1 = _ref1.length; _j < _len1; _j++) {
      e = _ref1[_j];
      if (this.grid[e[0]][e[1]][2] === 0) {
        _results.push(this._edgeBlocks.push(e));
      } else {
        _results.push(void 0);
      }
    }
    return _results;
  };

  old.prototype.setRotation = function(angels) {
    var block, i;
    console.debug('=== in setRotation === ');
    console.debug(angels);
    if (angels == null) {
      return;
    }
    block = this.currentBlock;
    block.rotation = angels[0] * Math.PI / 2;
    block.rotationN = angels[0];
    i = 1;
    return $('#rotate').click(function() {
      var a;
      a = angels[i % angels.length];
      block.rotation = a * Math.PI / 2;
      block.rotationN = a;
      return i++;
    });
  };

  old.prototype.getAvailableSeats = function() {
    var e, f, i, n, s, seats, _i, _j, _k, _len, _len1, _len2, _ref, _ref1, _ref2;
    seats = [];
    n = this.currentBlock.rotationN != null ? this.currentBlock.rotationN : 0;
    _ref = this.currentBlock.seats;
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      s = _ref[_i];
      _ref1 = s[2];
      for (i = _j = 0, _len1 = _ref1.length; _j < _len1; i = ++_j) {
        e = _ref1[i];
        if (e === 1 && this.currentBlock.edges[i] === E_ROAD) {
          this.probeRoad(this.currentBlock, s, i, false);
          if (!this.roadTaken && seats.indexOf(s) === -1) {
            seats.push(s);
          }
        }
        if (e === 1 && this.currentBlock.edges[i] === E_CASTLE) {
          this.castleDFS(this.currentBlock, s, false);
          if (!this.castleTaken && seats.indexOf(s) === -1) {
            seats.push(s);
          }
          continue;
        }
      }
    }
    _ref2 = this.currentBlock.fields;
    for (i = _k = 0, _len2 = _ref2.length; _k < _len2; i = ++_k) {
      f = _ref2[i];
      this.probeField(this.currentBlock, f);
      if (!this.fieldTaken) {
        seats.push([f.pos[0], f.pos[1], f.edges, i]);
      }
    }
    console.debug('=== castle dfs ===');
    return seats;
  };

  old.prototype.renderScore = function() {
    var e, i, s, _i, _j, _len, _len1, _ref, _ref1;
    _ref = this.currentBlock.seats;
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      s = _ref[_i];
      _ref1 = s[2];
      for (i = _j = 0, _len1 = _ref1.length; _j < _len1; i = ++_j) {
        e = _ref1[i];
        if (e === 1 && this.currentBlock.edges[i] === E_ROAD) {
          this.probeRoad(this.currentBlock, s, i, true);
        }
        if (e === 1 && this.currentBlock.edges[i] === E_CASTLE) {
          this.castleDFS(this.currentBlock, s, true);
        }
      }
    }
  };

  old.prototype.getFollowerState = function(followerState) {
    var self;
    self = this;
    return followerState.map(function(f) {
      if (f === 1) {
        return self.currentUser.id;
      } else {
        return 0;
      }
    });
  };

  old.prototype.isComplete = function(block) {
    var b, _i, _len, _ref;
    _ref = this.getNeighbors8(block.gx, block.gy);
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      b = _ref[_i];
      if (this.grid[b[0]][b[1]][3] == null) {
        return false;
      }
    }
    return true;
  };

  old.prototype.clearPool = function() {
    var obj, _i, _len, _ref;
    _ref = this.pool;
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      obj = _ref[_i];
      this.currentBlock.removeChild(obj);
    }
    return this.pool = [];
  };

  old.prototype.hasBlockLeft = function() {
    return this._blocks.length > 0;
  };

  old.prototype.getBlock = function(cord) {
    var block, status;
    status = this.grid[cord[0]][cord[1]][2];
    block = this.grid[cord[0]][cord[1]][3];
    if (status === B_PLACED) {
      return block;
    } else {
      return null;
    }
  };

  old.prototype.getEdges = function(gx, gy) {
    var edges, neighbors;
    neighbors = this.getNeighbors(gx, gy);
    edges = [];
    edges.push(this.getBlock(neighbors[0]) != null ? this.getBlock(neighbors[0]).edges[2] : null);
    edges.push(this.getBlock(neighbors[1]) != null ? this.getBlock(neighbors[1]).edges[3] : null);
    edges.push(this.getBlock(neighbors[2]) != null ? this.getBlock(neighbors[2]).edges[0] : null);
    edges.push(this.getBlock(neighbors[3]) != null ? this.getBlock(neighbors[3]).edges[1] : null);
    return edges;
  };

  old.prototype.getNeighbors = function(gx, gy) {
    var result;
    result = [];
    result.push([gx, gy - 1]);
    result.push([gx + 1, gy]);
    result.push([gx, gy + 1]);
    result.push([gx - 1, gy]);
    return result;
  };

  old.prototype.getNeighbors8 = function(gx, gy) {
    var result;
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

  old.prototype.getMatchAngels = function(edges) {
    var angels, i, index, j, _i, _j, _ref;
    console.log(this.nextBlock.edges);
    angels = [];
    for (i = _i = 0; _i <= 3; i = ++_i) {
      j = 0;
      for (j = _j = i, _ref = i + 3; i <= _ref ? _j <= _ref : _j >= _ref; j = i <= _ref ? ++_j : --_j) {
        index = j % 4;
        if (edges[index] !== this.nextBlock.edges[j - i] && edges[index] !== null) {
          break;
        }
      }
      if (j === i + 4) {
        angels.push(i);
      }
    }
    return angels;
  };

  old.prototype.getContra = function(pos) {
    var dic;
    dic = [2, 3, 0, 1];
    return dic[pos];
  };

  old.prototype.getContra8 = function(pos) {
    var dic;
    dic = [5, 4, 7, 6, 1, 0, 3, 2];
    return dic[pos];
  };

  old.prototype.rotate = function(array, n) {
    var e, i, _i;
    if (n === 0) {
      return array;
    }
    for (i = _i = 1; 1 <= n ? _i <= n : _i >= n; i = 1 <= n ? ++_i : --_i) {
      e = array.pop();
      array.unshift(e);
    }
    return array;
  };

  old.prototype.castleDFS = function(src, seat, ifRender) {
    var e, i, nextBlock, _i, _len, _ref;
    this.probeBlocks = [];
    this.castleTaken = false;
    this.castleCompleted = true;
    this._score = src.value;
    this.clearMarked();
    src.marked = true;
    _ref = seat[2];
    for (i = _i = 0, _len = _ref.length; _i < _len; i = ++_i) {
      e = _ref[i];
      if (e !== 1) {
        continue;
      }
      if (src.edgeTypes[i] === END) {
        nextBlock = this.getNeighborCastles(src.gx, src.gy)[i];
        if (nextBlock === null) {
          this.castleCompleted = false;
          this.castleTaken = false;
          break;
        }
        if (src.followerPlaced[i] !== 0) {
          this.probeBlocks.push(src);
        }
        if (nextBlock.edgeTypes[this.getContra(i)] === END) {
          if (nextBlock.followerPlaced[this.getContra(i)] !== 0) {
            this.probeBlocks.push(nextBlock);
            this.castleTaken = true;
          }
          this._score += nextBlock.value;
          continue;
        } else {
          this._score += nextBlock.value;
          this._castleDFS(nextBlock);
        }
      } else {
        this._castleDFS(src);
      }
    }
    if (ifRender && this.castleCompleted === true) {
      return this.renderFinished(this._score, 'castle');
    }
  };

  old.prototype._castleDFS = function(block) {
    var b, i, neighborCastles, takenBy, _i, _len, _results;
    block.marked = true;
    neighborCastles = this.getNeighborCastles(block.gx, block.gy);
    _results = [];
    for (i = _i = 0, _len = neighborCastles.length; _i < _len; i = ++_i) {
      b = neighborCastles[i];
      if (b === null) {
        if (block.edges[i] === E_CASTLE) {
          this.castleCompleted = false;
        }
        continue;
      }
      if (!b.marked) {
        this._score += b.value;
      }
      takenBy = b.followerPlaced[this.getContra(i)];
      if (takenBy !== 0) {
        this.probeBlocks.push(b);
        this.castleTaken = true;
      }
      if (!b.marked) {
        _results.push(this._castleDFS(b));
      } else {
        _results.push(void 0);
      }
    }
    return _results;
  };

  old.prototype.getNeighborCastles = function(gx, gy) {
    var edges, neighbors, res;
    neighbors = this.getNeighbors(gx, gy);
    edges = this.getEdges(gx, gy);
    res = [];
    res.push(edges[0] === E_CASTLE ? this.getBlock(neighbors[0]) : null);
    res.push(edges[1] === E_CASTLE ? this.getBlock(neighbors[1]) : null);
    res.push(edges[2] === E_CASTLE ? this.getBlock(neighbors[2]) : null);
    res.push(edges[3] === E_CASTLE ? this.getBlock(neighbors[3]) : null);
    return res;
  };

  old.prototype.clearMarked = function() {
    var b, _i, _len, _ref, _results;
    _ref = this.__blocks;
    _results = [];
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      b = _ref[_i];
      _results.push(b.marked = false);
    }
    return _results;
  };

  old.prototype.probeRoad = function(block, seat, pos, ifRender) {
    var i, otherEndPos, s, score, start, startEdgeType, _i, _len, _ref;
    this.probeBlocks = [];
    this.roadTaken = false;
    this.roadCompleted = true;
    this.endCount = 0;
    start = [block.gx, block.gy];
    startEdgeType = block.edgeTypes[pos];
    score = 1;
    if (startEdgeType < END) {
      _ref = seat[2];
      for (i = _i = 0, _len = _ref.length; _i < _len; i = ++_i) {
        s = _ref[i];
        if (s === 1 && i !== pos) {
          otherEndPos = i;
        }
      }
      this._probeRoad(block, start, startEdgeType, score, otherEndPos, ifRender);
    }
    return this._probeRoad(block, start, startEdgeType, score, pos, ifRender);
  };

  old.prototype._probeRoad = function(block, start, startEdgeType, score, pos, ifRender) {
    var gx, gy, neighbors, nextBlock, nextEdge, placedBy;
    neighbors = this.getNeighbors(block.gx, block.gy);
    gx = neighbors[pos][0];
    gy = neighbors[pos][1];
    nextBlock = this.grid[gx][gy][2] === B_PLACED ? this.grid[gx][gy][3] : null;
    if (nextBlock == null) {
      this.roadCompleted = false;
      this.probeBlocks = [];
      return false;
    }
    if (block.edgeTypes[pos] === END && block.followerPlaced[pos] !== 0) {
      this.probeBlocks.push(block);
    }
    if ((nextBlock.follower != null) && nextBlock.followerPlaced[this.getContra(pos)] !== 0) {
      this.probeBlocks.push(nextBlock);
    }
    score += 1;
    nextEdge = nextBlock.edgeTypes[this.getContra(pos)];
    placedBy = nextBlock.followerPlaced[this.getContra(pos)];
    if (placedBy !== 0) {
      this.roadTaken = true;
    }
    if (nextEdge < END) {
      nextEdge = (this.getContra(pos) + nextEdge) % 4;
      if (placedBy != null) {
        this.roadTakenBy[placedBy] += 1;
      }
      return this._probeRoad(nextBlock, start, startEdgeType, score, nextEdge, ifRender);
    } else if (nextEdge === END) {
      this.endCount += 1;
      if (startEdgeType === END || [gx, gy] === start || this.endCount === 2) {
        if (ifRender) {
          this.renderFinished(score, 'road');
        }
      }
      return false;
    } else {
      console.log('error in edgeType');
      return false;
    }
  };

  old.prototype.renderFinished = function(score, type) {
    var b, id, scorers, taken, user, _i, _j, _k, _len, _len1, _len2, _ref, _ref1;
    taken = [0, 0, 0, 0, 0, 0];
    console.debug('=== render finished ===');
    console.debug(this.probeBlocks);
    _ref = this.probeBlocks;
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      b = _ref[_i];
      _ref1 = b.followerPlaced;
      for (_j = 0, _len1 = _ref1.length; _j < _len1; _j++) {
        id = _ref1[_j];
        if (id !== 0) {
          taken[id - 1] += 1;
          break;
        }
      }
      if (b.follower != null) {
        b.removeChild(b.follower);
        b.followerPlaced = [0, 0, 0, 0];
      }
    }
    scorers = this.calScorers(taken);
    if (type === 'castle') {
      score = score * 2;
    }
    for (_k = 0, _len2 = scorers.length; _k < _len2; _k++) {
      user = scorers[_k];
      this.Users.scoring(type, user, score);
    }
    this.udpateScoreBoard();
    return this.probeBlocks = [];
  };

  old.prototype.udpateScoreBoard = function() {
    document.querySelectorAll('#u1')[0].innerText = this.Users.getScore(1);
    document.querySelectorAll('#u2')[0].innerText = this.Users.getScore(2);
    document.querySelectorAll('#u3')[0].innerText = this.Users.getScore(3);
    document.querySelectorAll('#u4')[0].innerText = this.Users.getScore(4);
    document.querySelectorAll('#u5')[0].innerText = this.Users.getScore(5);
    return document.querySelectorAll('#u6')[0].innerText = this.Users.getScore(6);
  };

  old.prototype.calScorers = function(users) {
    var hosts, max, num, _i;
    max = 1;
    hosts = [];
    for (num = _i = 0; _i <= 5; num = ++_i) {
      if (users[num] > max) {
        max = users[num];
        hosts.clear;
        hosts.push(num + 1);
      }
      if (users[num] === max) {
        hosts.push(num + 1);
      }
    }
    return hosts;
  };

  old.prototype.probeField = function(block, field) {
    this.fieldTaken = false;
    this.probeBlocks = [];
    this._score = 0;
    this.clearFieldMarked();
    this._probeField(block, field);
    return this.renderField();
  };

  old.prototype._probeField = function(block, field) {
    var edge, edgeFour, nextBlock, nextField, _i, _len, _ref, _ref1;
    field.marked = true;
    _ref = field.edges;
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      edge = _ref[_i];
      edgeFour = Math.floor(edge / 2);
      nextBlock = this.getBlock(this.getNeighbors(block.gx, block.gy)[edgeFour]);
      if (nextBlock == null) {
        continue;
      }
      nextField = this.getNeighborFields(nextBlock, edge);
      if ((_ref1 = this.getContra8(edge), __indexOf.call(nextField.edges, _ref1) >= 0) && nextField.takenBy > 0) {
        this.fieldTaken = true;
        this.probeBlocks.push(block);
        return;
      }
      if (!nextField.marked) {
        this._probeField(nextBlock, nextField);
      }
    }
  };

  old.prototype.getNeighborFields = function(nextBlock, edge) {
    var edgeFour, field, _i, _len, _ref, _ref1;
    edgeFour = Math.floor(edge / 2);
    _ref = nextBlock.fields;
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      field = _ref[_i];
      if (_ref1 = this.getContra8(edge), __indexOf.call(field.edges, _ref1) >= 0) {
        return field;
      } else {
        continue;
      }
    }
    return console.log('error in finding next field');
  };

  old.prototype.clearFieldMarked = function() {
    var b, f, _i, _len, _ref, _results;
    _ref = this.__blocks;
    _results = [];
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      b = _ref[_i];
      _results.push((function() {
        var _j, _len1, _ref1, _results1;
        _ref1 = b.fields;
        _results1 = [];
        for (_j = 0, _len1 = _ref1.length; _j < _len1; _j++) {
          f = _ref1[_j];
          _results1.push(f.marked = false);
        }
        return _results1;
      })());
    }
    return _results;
  };

  old.prototype.renderField = function() {
    console.log(this.probeBlocks);
    return console.log(this.fieldTaken);
  };

  return old;

})();

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
    this.place = __bind(this.place, this);
    this.placeN = __bind(this.placeN, this);
    this.placable = __bind(this.placable, this);
    this.setOccupied = __bind(this.setOccupied, this);
    this.getStat = __bind(this.getStat, this);
    this.Users = new Users(4);
    this.initContainer();
    this.initGameControl();
    this.loadResource((function(_this) {
      return function() {
        _this.initGrid();
        _this.initBlock(BLOCK, _this.Block_el);
        _this.UnitTest();
        return requestAnimFrame(animate);
      };
    })(this));
  }

  Playground.prototype.Block_el = {};

  Playground.prototype.Blocks = {};

  Playground.prototype.Users = {};

  Playground.prototype.corners = {};

  Playground.prototype.borders = {};

  Playground.prototype.Grid = [];

  Playground.prototype.CurrentUser = {};

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

  Playground.prototype.addCorners = function(block) {
    var c, pos, _i, _len, _ref;
    _ref = block.corners;
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      c = _ref[_i];
      pos = [block.gx + c[0], block.gy + c[1]];
      if (this.withinGrid(pos)) {
        this.corners[pos.toString()] = true;
        this.Grid[block.gy + c[1]][block.gx + c[0]][2] = 'c';
      }
    }
    return console.log(this.corners);
  };

  Playground.prototype.addBorders = function(block) {
    var b, pos, _i, _len, _ref;
    _ref = block.borders;
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      b = _ref[_i];
      pos = [block.gx + b[0], block.gy + b[1]];
      if (this.withinGrid(pos)) {
        this.borders[pos.toString()] = true;
        this.Grid[block.gy + b[1]][block.gx + b[0]][2] = 'b';
      }
    }
    return console.log(this.borders);
  };

  Playground.prototype.placable = function(block, x, y) {
    var flag, pos, _i, _len, _ref, _x, _y;
    flag = true;
    if (!this.corners[[x, y].toString()]) {
      flag = false;
    }
    _ref = block.coord;
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      pos = _ref[_i];
      _x = x + pos[0];
      _y = y + pos[1];
      if (_x > 19 || x < 0 || _y > 19 || _y < 0) {
        return false;
      }
    }
    block.coord.map((function(_this) {
      return function(pos) {
        if (_this.corners[[x + pos[0], y + pos[1]].toString()]) {
          return flag = true;
        }
      };
    })(this));
    block.coord.map((function(_this) {
      return function(pos) {
        if (_this.borders[[x + pos[0], y + pos[1]].toString()]) {
          return flag = false;
        }
      };
    })(this));
    if (Object.keys(this.corners).length === 0) {
      flag = true;
    }
    block.coord.map((function(_this) {
      return function(rp) {
        if (SQ.playground.getStat(x + rp[0], y + rp[1]) === 1) {
          return flag = false;
        }
      };
    })(this));
    return flag;
  };

  Playground.prototype.placeN = function(n, x, y) {
    var block;
    block = this.Blocks.getBlock(n);
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
    if (placable(block, x, y)) {
      return this.place(block, x, y);
    } else {
      return this.placeBack(block);
    }
  };

  Playground.prototype.place = function(block, x, y) {
    var pos;
    block.put = true;
    pos = this.getCoord(x, y);
    block.position = {
      x: pos[0] - WIDTH / 2,
      y: pos[1] - WIDTH / 2
    };
    block.gx = x;
    block.gy = y;
    block.coord.map((function(_this) {
      return function(rp) {
        return _this.setOccupied(x + rp[0], y + rp[1], 1);
      };
    })(this));
    this.addCorners(block);
    this.addBorders(block);
    return this.udpateInfoBoard();
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

  Playground.prototype.initBlock = function(blocks, texure) {
    this.Blocks = new Blocks(blocks, this.next, this.Users, this);
    return this.currentUser = this.Users.nextUser();
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
  function Users(num) {
    var i, _i, _ref;
    this.num = num;
    for (i = _i = 1, _ref = this.num; 1 <= _ref ? _i <= _ref : _i >= _ref; i = 1 <= _ref ? ++_i : --_i) {
      this._users.push(new User(i));
    }
  }

  Users.prototype._users = [];

  Users.prototype.nextUser = function() {
    if (this.num === 0) {
      this.num = this._users.length;
    }
    console.log(this.num);
    return this._users[--this.num];
  };

  Users.prototype.scoring = function(type, id, score) {
    console.log(this._users);
    return this._users[id - 1][type] += score;
  };

  Users.prototype.getScore = function(id) {
    return this._users[id - 1]['road'] + this._users[id - 1]['castle'];
  };

  return Users;

})();

User = (function() {
  function User(id) {
    this.id = id;
  }

  User.prototype.id = 0;

  User.prototype.score = 0;

  User.prototype.setUI = function() {
    var selector;
    selector = 'player' + this.id;
    return document.getElementById(selector).innerHTML = 'player ' + this.id + ' ongoing';
  };

  User.prototype.getBlock = function(block) {
    return this.placeBlock(block);
  };

  return User;

})();
