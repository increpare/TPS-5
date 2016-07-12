import haxegon.*;
import js.Browser;
import haxe.Serializer;

class Main {

	var simulator:Simulator;

	var dataBoxWidth:Int;
	var boxWidth:Int;
	var commentsBoxWidth:Int;

	var inputBoxHeight:Int;
	var scriptBoxHeight:Int;

	var initSimulatorState:String = "";
	var stepCount:Int = 0;

	// new() is a special function that is called on startup.
	function new() {


		dataBoxWidth = (textWidth+letterSpaceH)*8-letterSpaceH+2*marginH;
		boxWidth = dataBoxWidth*2;
		commentsBoxWidth = (textWidth+letterSpaceH)*27-letterSpaceH+2*marginH;

		inputBoxHeight = (textHeight+letterSpaceV)*32-letterSpaceV;
		scriptBoxHeight = (textHeight+letterSpaceV)*16-letterSpaceV;

		Text.setfont("dos");
		//was width 694
		Gfx.resizescreen(900, 600);
		
		var defaultFile:String = Data.loadtext("default");
		Load(defaultFile);
	}

	function Load(s:String){
		var parts1 = s.split(':');
		parts1.shift();//remove empty first
		parts1[4]=parts1[4].toUpperCase();
		parts1[4]=parts1[4].substr(parts1[4].indexOf("\n")+1);
		trace(parts1);

		var parts2:Array<Array<String>> = [];

		for (p in parts1) {
			var t = p.split('\n');
			t.shift();//remove first element
			t=Lambda.array(Lambda.map(t,function(s:String){return StringTools.trim(s.toUpperCase());}));
			t=Lambda.array(Lambda.filter(t,function(s:String){return s!="";}));
			parts2.push(t);
		}
		trace(parts2);

		simulator = new Simulator(parts2[0],parts2[1],parts2[2],parts2[3],parts1[4]);
		RememberInitialState();
	}

	function RememberInitialState(){
		var serializer = new Serializer();
		serializer.useCache=true;
		serializer.serialize(simulator);
		initSimulatorState=serializer.toString();
		stepCount=0;
	}

	function GameTick(){
		if (Input.delaypressed(Key.X,6)){
			simulator.tick();
			stepCount++;
		}
		if (Input.justpressed(Key.L)){
			var s = Browser.window.prompt("input text","blah");
			Load(s);
		}

		if (Input.justpressed(Key.P)){
			var serializer = new Serializer();
			serializer.useCache=true;
			serializer.serialize(initSimulatorState);
			serializer.serialize(stepCount);
			serializer.serialize(simulator);
			Browser.window.console.log(serializer.toString());
		}
		
		if (Input.justpressed(Key.T)){
			Tests.RunTests();			
		}

		if (Input.justpressed(Key.S)){
			var serializer = new Serializer();
			serializer.useCache=true;
			serializer.serialize(simulator);
			trace(serializer.toString());
		}
	}

  function update(){
  	GameTick();
  	GfxTick();
  }

  var textHeight:Int=10;
  var textWidth:Int=7;
  var letterSpaceH=2;
  var letterSpaceV=6;
  var marginH=4;
  var marginV=4;


  function DrawTable(startx:Int,starty:Int,buffer:Buffer, tableIndex:Int, thisTPS:TPS){


	Gfx.fillbox(
		startx-marginH,
		starty+textHeight+letterSpaceV+3-marginV,
		boxWidth+2*marginH+1,
		scriptBoxHeight+2*marginV, 
		0x0000ff);

	Gfx.fillbox(
		startx-marginH+boxWidth/2+marginH,
		starty+textHeight+letterSpaceV+3-marginV,
		1,
		scriptBoxHeight+2*marginV, 
		0x000055);

	var cursorPos = buffer.pos;
	//draw cursor
	Gfx.fillbox(
		startx-marginH+Math.floor(cursorPos/16)*(boxWidth/2+marginH+1),
		starty+textHeight+letterSpaceV+3-marginV
			+(textHeight+letterSpaceV)*(cursorPos%16),
		boxWidth/2+marginH,
		textHeight+2*marginV-2, 
		simulator.curTarget == tableIndex ? 0xff00ff:0xaa00aa);


	if (thisTPS!=null){
		if (thisTPS.state == State.If || thisTPS.state == State.While
			|| thisTPS.state == State.IfN || thisTPS.state == State.WhileN) {
			var cp = (cursorPos-1+buffer.length)%buffer.length;
			Gfx.fillbox(
				startx-marginH+Math.floor(cp/16)*(boxWidth/2+marginH+1),
				starty+textHeight+letterSpaceV+3-marginV
					+(textHeight+letterSpaceV)*(cp%16),
				boxWidth/2+marginH,
				textHeight+2*marginV-2, 
				0x00aaaa);
		} else if (thisTPS.state == State.While2 || thisTPS.state == State.While2N){
			var cp = (cursorPos-1+buffer.length)%buffer.length;
			Gfx.fillbox(
				startx-marginH+Math.floor(cp/16)*(boxWidth/2+marginH+1),
				starty+textHeight+letterSpaceV+3-marginV
					+(textHeight+letterSpaceV)*(cp%16),
				boxWidth/2+marginH,
				textHeight+2*marginV-2, 
				0x00aaaa);
			var cp = cursorPos;
			Gfx.fillbox(
				startx-marginH+Math.floor(cp/16)*(boxWidth/2+marginH+1),
				starty+textHeight+letterSpaceV+3-marginV
					+(textHeight+letterSpaceV)*(cp%16),
				boxWidth/2+marginH,
				textHeight+2*marginV-2, 
				0x00aa00);

			var cp = (cursorPos+1)%buffer.length;
			Gfx.fillbox(
				startx-marginH+Math.floor(cp/16)*(boxWidth/2+marginH+1),
				starty+textHeight+letterSpaceV+3-marginV
					+(textHeight+letterSpaceV)*(cp%16),
				boxWidth/2+marginH,
				textHeight+2*marginV-2, 
				simulator.curTarget == tableIndex ? 0xff00ff:0xaa00aa);

		}
	}
	
	cursorPos = buffer.storedPos;
	if (cursorPos>=0){
		//draw mark
		Gfx.fillbox(
			startx+boxWidth/2-textWidth-letterSpaceH
				+Math.floor(cursorPos/16)*(boxWidth/2+marginH+1),
			starty+textHeight+letterSpaceV+3-marginV
				+(textHeight+letterSpaceV)*(cursorPos%16),
			textWidth+letterSpaceH,
			textHeight+2*marginV-2, 
			0xaaaa00);
	}

	var strings = buffer.toString();
	Text.display(
		startx,
		starty+textHeight+letterSpaceV+3,
		strings[0],
		Col.WHITE);

	Text.display(
		startx+boxWidth/2+1+marginH,
		starty+textHeight+letterSpaceV+3,
		strings[1],
		Col.WHITE);
  }

  function GfxTick() {
	var startx:Int=5;
	var starty:Int=3;



	var cursorPos = 0;

  	starty+=20;


	Text.display(startx,starty,"DATA",Col.WHITE);

	Gfx.fillbox(
		startx-marginH,
		starty+textHeight+letterSpaceV+3-marginV,
		dataBoxWidth+2*marginH,
		inputBoxHeight+2*marginV, 
		0x0000ff);

	cursorPos = simulator.data.pos;
	//draw cursor
	Gfx.fillbox(
		startx-marginH,
		starty+textHeight+letterSpaceV+3-marginV
			+(textHeight+letterSpaceV)*cursorPos,
		dataBoxWidth+2*marginH,
		textHeight+2*marginV-2, 
		0xaa00aa);

	cursorPos = simulator.data.storedPos;
	if (cursorPos>=0){
		//draw mark
		Gfx.fillbox(
			startx+dataBoxWidth+marginH-textWidth-letterSpaceH,
			starty+textHeight+letterSpaceV+3-marginV
				+(textHeight+letterSpaceV)*cursorPos,
			textWidth+letterSpaceH,
			textHeight+2*marginV-2, 
			0xaaaa00);
	}

	Text.display(
		startx,
		starty+textHeight+letterSpaceV+3,
		simulator.data.toString()[0],
		Col.WHITE);


	startx += dataBoxWidth+marginH*5+3;

/*
	if (simulator.tps.curTarget==0){
		Text.display(
			startx-marginH*3-3,
			starty+8*(textHeight+letterSpaceV)+3,
			"<",
			Col.WHITE);
	}*/

	Text.display(startx,starty,"TPS#1",Col.WHITE);

	DrawTable(startx,starty,simulator.data_tps[0],0,simulator.tps[0]);

	starty += scriptBoxHeight+38;

	DrawTable(startx,starty-textHeight-letterSpaceV ,simulator.data_stack[0],3,null);

	Text.display(startx,starty+scriptBoxHeight+3*marginV,"STACK#1",Col.WHITE);

	starty -= scriptBoxHeight+38;


	startx += boxWidth+marginH*5+3;

	if (simulator.curTarget==0){
		Text.display(
			startx-marginH*3-3,
			starty+8*(textHeight+letterSpaceV)+3,
			"<",
			Col.WHITE);
		if (simulator.tps[0].contextLock){
			Text.display(
				startx-marginH*3-3,
				starty+7*(textHeight+letterSpaceV)+3,			
				String.fromCharCode(6),
				Col.WHITE);
		}
		if (simulator.tps[0].state != State.Regular){
			Text.display(
				startx-marginH*3-3,
				starty+9*(textHeight+letterSpaceV)+3,			
				String.fromCharCode(6),
				Col.WHITE);
		}

	}


	Text.display(startx,starty,"TPS#2",Col.WHITE);

	DrawTable(startx,starty,simulator.data_tps[1],1,simulator.tps[1]);

	starty += scriptBoxHeight+38;

	DrawTable(startx,starty-textHeight-letterSpaceV ,simulator.data_stack[1],4,null);

	Text.display(startx,starty+scriptBoxHeight+3*marginV,"STACK#2",Col.WHITE);

	starty -= scriptBoxHeight+38;

	startx += boxWidth+marginH*5+3;


	Gfx.fillbox(
		startx-marginH,
		starty-marginV+1,
		boxWidth+2*marginH,
		textHeight+2*marginV, 
		0xaaaaaa);

	Text.display(startx,starty,"TPS#3",Col.BLACK);

	if (simulator.curTarget<2){
		Text.display(
			startx-marginH*3-3,
			starty+8*(textHeight+letterSpaceV)+3,
			"<",
			Col.WHITE);
		if (simulator.tps[1].Locked()){
			Text.display(
				startx-marginH*3-3,
				starty+7*(textHeight+letterSpaceV)+3,			
				String.fromCharCode(6),
				Col.WHITE);

			Text.display(
				startx-marginH*3-3,
				starty+9*(textHeight+letterSpaceV)+3,			
				String.fromCharCode(6),
				Col.WHITE);
		}
	}

	DrawTable(startx,starty,simulator.data_tps[2],2,simulator.tps[2]);

	starty += scriptBoxHeight+38;

	DrawTable(startx,starty-textHeight-letterSpaceV ,simulator.data_stack[2],5,null);

	Text.display(startx,starty+scriptBoxHeight+3*marginV,"STACK#3",Col.WHITE);

	starty -= scriptBoxHeight+38;

	startx += boxWidth+marginH*5+3;


	Text.display(startx,starty,"SPECIFICATIONS",Col.WHITE);

	Gfx.fillbox(
		startx-marginH,
		starty+textHeight+letterSpaceV+3-marginV,
		commentsBoxWidth+2*marginH,
		scriptBoxHeight+2*marginV, 
		0x0000ff);

	Text.display(
		startx,
		starty+textHeight+letterSpaceV+3,
		simulator.specifications,
		Col.WHITE);

	starty += scriptBoxHeight+38;

	Gfx.fillbox(
		startx-marginH,
		starty+3-marginV,
		commentsBoxWidth+2*marginH,
		scriptBoxHeight+2*marginV, 
		0x0000ff);

	Text.display(
		startx,
		starty+3,
		"MESSAGE CONSOLE V 0.1",
		Col.WHITE);

		Text.display(startx,starty+scriptBoxHeight+3*marginV,"MESSAGES",Col.WHITE);

	var right = startx + commentsBoxWidth+marginH;
	startx=5;
	starty=3;
	right+=startx;

  	Gfx.fillbox(0,0,right,16,0xaaaaaa);
  	Text.display(startx,starty,"CHALLENGES",Col.WHITE);
  	Text.display(startx+20*9,starty,"C01 [RUNNING]",Col.WHITE);
  	Text.display(startx+40*9,starty,"PLAY",Col.WHITE);
  	Text.display(startx+50*9,starty,"STEP",Col.WHITE);
  	Text.display(right-4*9-startx,starty,"HELP",Col.WHITE);

  }

}