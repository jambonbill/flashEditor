﻿package com.playpower.ui {	import flash.display.Sprite;	import flash.events.Event;	import flash.text.TextField;	import com.carlcalderon.arthropod.Debug;	import com.playpower.core.CustomTextField;	public class PP_Label extends Sprite	{		var _str:String;		var _txt:TextField;		public function PP_Label(str:String)		{			_str = str;						this.mouseEnabled = false;						this.addEventListener(Event.ADDED_TO_STAGE, _onAddedToStage, false, 0, true);		}		public function _onAddedToStage($e:Event):void		{			this.removeEventListener(Event.ADDED_TO_STAGE, _onAddedToStage);						_txt = CustomTextField.getTextField(_str,0xFFFFFF,8);			this.addChild(_txt);		}				public function get txt():String		{			return _str;		}				public function update(str:String)		{			_str = str;			_txt.htmlText = _str;		}				public function destroy():void		{			_str = null;			this.removeChild(_txt);			_txt = null;		}	}}