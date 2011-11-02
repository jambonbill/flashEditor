﻿package com.playpower.ui{	import flash.display.Sprite;	import flash.display.Graphics;	import flash.events.Event;	import flash.events.MouseEvent;	import flash.text.TextField;	import com.carlcalderon.arthropod.Debug;	import com.playpower.core.*;	import com.playpower.events.CustomEvent;	public class PP_CurTileButton extends Sprite	{		private var _clr:String;		private var _id:Number;		private var _tile:Sprite;		private var _txt:TextField;		public function PP_CurTileButton(clr:String,id:Number)		{			_clr = clr;			_id = id;			this.addEventListener(Event.ADDED_TO_STAGE, _onAddedToStage, false, 0, true);		}		public function _onAddedToStage($e:Event):void		{			//Debug.log("PP_Toggle added to stage");			this.removeEventListener(Event.ADDED_TO_STAGE, _onAddedToStage);						// draw tile			_tile = new Sprite();			var g:Graphics = _tile.graphics;			g.beginFill(Constants["CLR_"+_clr]);			g.drawRect(0,0,Constants.BUTTON_DIMS,Constants.BUTTON_DIMS);			g.endFill();					this.addChild(_tile);			_tile.buttonMode = true;			_tile.addEventListener(MouseEvent.MOUSE_UP, _onMouseUp, false, 0, true);						// tile label			_txt = CustomTextField.getTextField(_clr,Constants.CLR_TEXT,10);			_txt.x = -2;			_txt.y = 3;			this.addChild(_txt);		}				public function get clr():String		{			return _clr;		}				public function set clr(s:String):void		{			_clr = s;		}				public function update(clr:String)		{			_clr = clr;			var g:Graphics = _tile.graphics;			g.beginFill(Constants["CLR_"+clr]);			g.drawRect(0,0,Constants.BUTTON_DIMS,Constants.BUTTON_DIMS);			g.endFill();						this.removeChild(_txt);			_txt = null;			_txt = CustomTextField.getTextField(clr,Constants.CLR_TEXT,10);			_txt.x = -2;			_txt.y = 4;			this.addChild(_txt);		}				public function toggleString():void		{			_txt.visible = !_txt.visible;		}				private function _onMouseUp($e:MouseEvent):void		{			dispatchEvent( new CustomEvent(CustomEvent.BUTTON_UP, {id:_id}) );		}				public function destroy():void		{			this.removeChild(_txt);			_txt = null;			this.removeChild(_tile);			_tile.removeEventListener(MouseEvent.MOUSE_UP, _onMouseUp);			_tile = null;			_clr = null;		}	}}