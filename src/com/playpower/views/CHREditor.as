﻿package com.playpower.views{	import flash.display.Bitmap;	import flash.display.BitmapData;	import flash.display.Graphics;	import flash.display.MovieClip;	import flash.display.Sprite;	import flash.events.Event;	import flash.events.KeyboardEvent;	import flash.events.MouseEvent;	import flash.events.TimerEvent;	import flash.geom.Rectangle;	import flash.text.TextField;	import flash.utils.ByteArray;	import flash.utils.Timer;	import com.carlcalderon.arthropod.Debug;	import com.playpower.core.*;	import com.playpower.events.CustomEvent;	import com.playpower.ui.OutlineButton;	public class CHREditor extends Sprite	{		public var _controller:Controller;		public var _w:Number;		public var _h:Number;		private var _lines:Sprite;		private var _btns:Sprite;		private var _btnArr:Array;		private var _bmd:BitmapData;		private var _bg:Bitmap;		private var _clr:*;		private var _paletteTileNum:Number;		private var _curTileNum:Number;		private var _selTileArr:Array;		private var _background:Sprite;		private var _quadLines:Sprite;		private var _label:TextField;				// have no idea why these were continually reset. they are stored in the singleton for now		//private var _selectedTile:Number = 120;		//private var _curAttr:Number;				private var _padding:int = 5;				public var _chrArr:ByteArray;		public var _palArr:ByteArray;		private var _dragTimer:Timer;				// these are being continually reset, too		/*private var _tile0:Number;		private var _tile1:Number;		private var _tile2:Number;		private var _tile3:Number;*/		/* BIT MATH		 0 + 0 = 0		 1 + 0 = 1		 0 + 1 = 2		 1 + 1 = 3 		 		 HAVE TO READ ONE BIT FROM EACH BIT PLANES AND USE ABOVE FORMULA		 TO CALC THE VALUE		 		 TAKE FIRST ARRAY VALUE + OFFSET OVER BY 8 TO GET SECOND VALUE		 ADD THESE TWO VALUES TOGETHER TO GET FINAL VAL		 */				public function CHREditor(w:Number,h:Number)		{			_w = w;			_h = h;						_controller = Controller.getInstance();			_btnArr = new Array();						_dragTimer = new Timer(10);			_dragTimer.addEventListener(TimerEvent.TIMER, _onDragTimer, false, 0, true);						_palArr = new ByteArray();			_chrArr = new ByteArray();						this.addEventListener(Event.ADDED_TO_STAGE, _onAddedToStage, false, 0, true);		}		public function _onAddedToStage($e:Event):void		{			this.removeEventListener(Event.ADDED_TO_STAGE, _onAddedToStage);						_background = new Sprite();			var g:Graphics = _background.graphics;			g.beginFill(0xFFFFFF);			g.drawRect(-_padding,-_padding,_w+(_padding*2),_h+(_padding*2));			g.endFill();			this.addChild(_background);				// DRAW GRIDS (BOTH NAM & CHR)			if(_controller.gridEnabled)			{				_bmd = new BitmapData(_w,_h,false,Constants.CLR_00);				_bg = new Bitmap(_bmd);				this.addChild(_bg);				//_bg.x = _bg.y = _padding;								_lines = new Sprite();				this.addChild(_lines);				//_lines.x = _lines.y = _padding;				var c:int = 0;				for(var i=0; i<_w+Constants.GUTTER_WIDTH; i+=Constants.GUTTER_WIDTH)				{					if(i <= _h)					{						// draw x-axis						var x_axis:Sprite = new Sprite();						var x_axis_g:Graphics = x_axis.graphics;						x_axis_g.lineStyle(1, Constants.GRID_CLR, 1);						x_axis_g.moveTo(0,i);						x_axis_g.lineTo(_w,i);						_lines.addChild(x_axis);					}										// draw y-axis					var y_axis:Sprite = new Sprite();					var y_axis_g:Graphics = y_axis.graphics;					y_axis_g.lineStyle(1, Constants.GRID_CLR, 1);					y_axis_g.moveTo(i,0);					y_axis_g.lineTo(i,_h);					_lines.addChild(y_axis);										c++;				}								var yy:Number = 0;				var xx:Number = 0;				_btns = new Sprite();				this.addChild(_btns);				//_btns.x = _btns.y = _padding;				for(var k=0; k<Math.pow(_w/Constants.BUTTON_DIMS,2); k++)				{					// place invisible buttons across grid					if(yy < _h)					{						var btn:OutlineButton = new OutlineButton();						btn.init(k.toString(),Constants.BUTTON_DIMS,Constants.BUTTON_DIMS);												btn.addEventListener(MouseEvent.MOUSE_DOWN, _onMouseDown, false, 0, true);						btn.addEventListener(MouseEvent.MOUSE_UP, _onMouseUp, false, 0, true);												if ( (k*Constants.BUTTON_DIMS)%_w == 0 && k!=0 ) 						{							xx = 0;							yy += Constants.BUTTON_DIMS;														// keeps from rendering a widowed button tile on a line below the grid							if(yy == _h) break;						}						btn.x = xx*Constants.BUTTON_DIMS;						btn.y = yy;						_btns.addChild(btn);						_btnArr.push(btn);												xx++;					}				}							_quadLines = new Sprite();				this.addChild(_quadLines);				var x_axis2:Sprite = new Sprite();				var x_axis2_g:Graphics = x_axis2.graphics;				x_axis2_g.lineStyle(1, Constants.GRID_CLR3, 1);				x_axis2_g.moveTo(_h/2,0);				x_axis2_g.lineTo(_h/2,_w);				_quadLines.addChild(x_axis2);								var y_axis2:Sprite = new Sprite();				var y_axis2_g:Graphics = y_axis2.graphics;				y_axis2_g.lineStyle(1, Constants.GRID_CLR3, 1);				y_axis2_g.moveTo(0,_w/2);				y_axis2_g.lineTo(_h,_w/2);				_quadLines.addChild(y_axis2);								_lines.alpha = _controller.gridAlpha/Constants.ALPHA_SLIDER_MAX_VAL;			}						_label = CustomTextField.getTextField("",0x000000,12);			_label.y = -1*Constants.GUTTER_WIDTH*1.5;			this.addChild(_label);		}				public function updateLinesAlpha():void		{			_lines.alpha = _controller.gridAlpha/Constants.ALPHA_SLIDER_MAX_VAL;		}				public function setChrBuffer(b:ByteArray):void		{			_chrArr = b;		}				public function setPalBuffer(b:ByteArray):void		{			_palArr = b;		}				public function updateEditor(paletteTileNum:Number, clr:String, palette:Number):void		{			if(_palArr.length){				_clr = clr; // this is the selected color byte				_controller.curAttr = palette;				_paletteTileNum = paletteTileNum%4;			}		}				public function resetEditor():void		{			_bmd = new BitmapData(_w,_h,false,Constants.CLR_00);			_bg = new Bitmap(_bmd);			this.addChild(_bg);			this.addChild(_lines);			this.addChild(_btns);			this.addChild(_quadLines);		}				public function loadEditor():void		{			_controller.selectedTile1 = _controller.selectedTile + 1;			_controller.selectedTile2 = _controller.selectedTile + 16;			_controller.selectedTile3 = _controller.selectedTile + 17;			_selTileArr = [_controller.selectedTile, _controller.selectedTile1, _controller.selectedTile2, _controller.selectedTile3];						_drawTile(0,0,_controller.selectedTile);			_drawTile(8,0,_controller.selectedTile1);			_drawTile(0,8,_controller.selectedTile2);			_drawTile(8,8,_controller.selectedTile3);		}				public function setLabel(str:String):void		{			_label.text = str;		}				private function _drawTile(xPos:Number, yPos:Number, tileNum:Number):void		{			tileNum <<= 4;			xPos <<= 4;			yPos <<= 4;						_bmd.lock();			for(var i=tileNum; i<tileNum+8; i++)			{				var b0 = 0; //first bitplane;				var b1 = 0; // second bitplane;				b0 = _chrArr[i];   // first plane				b1 = _chrArr[i + 0x08];  // first plane + 8 bytes, stored in sequential, not interleaved format								for (var xx = 0; xx < 128; xx += 16)				{					var colorIndex:int = (((b0 & 0x80) >> 7) + ((b1 & 0x80) >> 6));					var n:int = colorIndex + (_controller.curAttr*4);					var s:String = _palArr[n].toString(16).toUpperCase();					if(s.length < 2) s = "0"+s;					var clr:int = Constants["CLR_"+s];										for(var j = 0; j < 16; j++)					{						for(var k = 0; k < 16; k++)						{							_bmd.setPixel(xPos + xx + k, yPos + j, clr);						}					}											b0 <<= 1;					b1 <<= 1;				}								yPos += 16;			}			_bmd.unlock();				}				// Draw directly to the CHR buffer based on a point		// xLoc (0-127)		// yLoc (0-127)		// pClr   (0-3)		private function _drawCHRPixel(xLoc:int, yLoc:int, pClr:int):void		{			// Which byte in the array to start with, could have combined it with that up there ^			var _startPoint:int = (_curTileNum*16) + (yLoc % 8);			var tempByte0:int = 0;			var tempByte1:int = 0;			var bitMask:int = 0;						// Work out the bit based on pClr (0-3)			tempByte0 = pClr & 0x01;			// Test the second bit and align it			tempByte1 = (pClr & 0x02) >> 1;						// Create the mask so we know which bit to operate on			// Since the bit is in the rightmost position (LSb)			// we need to do a little math on xLoc to figure out how much to shift left			bitMask = 1 << (7-(xLoc % 8));						// These operation will force a bit to 0/1 based on the mask			// AND 0b11101111 forces bit to 0			// OR  0b00010000 forces bit to 1			if(tempByte0 == 0)			{				_chrArr[(_startPoint)] &= (bitMask ^ 0xFF);			}			else			{				_chrArr[(_startPoint)] |= bitMask;			}						if(tempByte1 == 0)			{				_chrArr[(_startPoint + 0x08)] &= (bitMask ^ 0xFF);			}			else			{				_chrArr[(_startPoint + 0x08)] |= bitMask;			}						//trace("xLoc:" + xLoc + " yLoc:" + yLoc + " pClr:" + pClr + " _tileNum:" + _tileNum + " _startPoint: " + _startPoint);		}				private function _drawToEditor(xx:Number, yy:Number):void		{			// continually update pixels for show only			var clr:int = Constants["CLR_"+_clr];			_bmd.lock();			for(var j=0; j<256; j++)			{				for(var i=0; i<256; i++)				{					_bmd.setPixel(xx + (i/Constants.BUTTON_DIMS), yy + (j/Constants.BUTTON_DIMS),clr);				}			}			_bmd.unlock();		}				private function _onDragTimer($e:TimerEvent):void		{			var xx:Number = Math.floor(mouseX/Constants.BUTTON_DIMS)*Constants.BUTTON_DIMS;			var yy:Number = Math.floor(mouseY/Constants.BUTTON_DIMS)*Constants.BUTTON_DIMS;						// draws toCHR editor			_drawToEditor(xx, yy);			_curTileNum = _selTileArr[_getTileNum(xx, yy)];						// draws to CHR table above			_drawCHRPixel((xx/16) + ((_curTileNum%16)*8), (yy/16) + ((_curTileNum%16)*8), _paletteTileNum);		}				private function _onMouseDown($e:MouseEvent):void		{			if(!_dragTimer.running) 			{				_dragTimer.start();			}		}				private function _getTileNum(xx:Number,yy:Number):Number		{			var val = NaN;			if(xx >= 0 && xx < 128 && yy >= 0 && yy < 128)			{				val = 0;			}			else if(xx >= 128 && xx <= 256 && yy >= 0 && yy < 128)			{				val = 1;			}			else if(xx >= 0 && xx < 128 && yy >= 128 && yy <= 256)			{				val = 2;			}			else if(xx >= 128 && xx <= 256 && yy >= 128 && yy <= 256)			{				val = 3 ;			}			return val;		}				private function _onMouseUp($e:MouseEvent):void		{			_dragTimer.stop();						var btn:OutlineButton = $e.currentTarget as OutlineButton;			var xx:Number = btn.x;			var yy:Number = btn.y;						// draws to CHR editor			_drawToEditor(xx, yy);			_getTileNum(xx, yy);			_curTileNum = _selTileArr[_getTileNum(xx, yy)];						// draws to CHR table above			_drawCHRPixel((xx/16) + ((_curTileNum%16)*8), (yy/16) + ((_curTileNum%16)*8), _paletteTileNum);						dispatchEvent( new CustomEvent(CustomEvent.UPDATE_BUFFER, {val:_chrArr}) );		}				public function destroy():void		{			this.removeChild(_bg);			_bg = null;			_controller = null;			this.removeChild(_lines);			while(_lines.numChildren > 0) _lines.removeChildAt(0);			_lines = null;			// clear btn arr		}	}}