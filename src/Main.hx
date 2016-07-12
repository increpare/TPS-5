import haxegon.*;

class Main {

	var simulator:Simulator;



	var dataBoxWidth:Int;
	var boxWidth:Int;
	var commentsBoxWidth:Int;

	var inputBoxHeight:Int;
	var scriptBoxHeight:Int;

	// new() is a special function that is called on startup.
	function new() {


		dataBoxWidth = (textWidth+letterSpaceH)*8-letterSpaceH+2*marginH;
		boxWidth = dataBoxWidth*2;
		commentsBoxWidth = (textWidth+letterSpaceH)*30-letterSpaceH+2*marginH;

		inputBoxHeight = (textHeight+letterSpaceV)*32-letterSpaceV;
		scriptBoxHeight = (textHeight+letterSpaceV)*16-letterSpaceV;

		Text.setfont("dos");
		//was width 694
		Gfx.resizescreen(900, 600);
		
		var startText:String = Data.loadtext("default");
		trace(startText);

		var parts1 = startText.split(':');
		parts1.shift();//remove empty first
		parts1[4]=parts1[4].toUpperCase();
		parts1[4]=parts1[4].substr(parts1[4].indexOf("\n")+1);
		trace(parts1);

		var parts2:Array<Array<String>> = [];

		for (p in parts1) {
			var t = p.split('\n');
			t.shift();//remove first element
			t=Lambda.array(Lambda.map(t,function(s:String){return s.toUpperCase();}));
			t=Lambda.array(Lambda.filter(t,function(s:String){return s!="";}));
			parts2.push(t);
		}
		trace(parts2);

		simulator = new Simulator(parts2[0],parts2[1],parts2[2],parts2[3],parts1[4]);

	}

	function GameTick(){
		if (Input.justpressed(Key.X)){
			simulator.tick();
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


  function DrawTable(startx:Int,starty:Int,buffer:Buffer, tableIndex:Int){


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

	cursorPos = buffer.storedPos;
	if (cursorPos>0){
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
	if (cursorPos>0){
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


	if (simulator.tps[0].target==0){
		Text.display(
			startx-marginH*3-3,
			starty+8*(textHeight+letterSpaceV)+3,
			"<",
			Col.WHITE);
	} else {
		Text.display(
			startx-marginH*3-3+5*(textWidth+letterSpaceH),
			starty+17*(textHeight+letterSpaceV)+3,
			"v",
			Col.WHITE);
	}
	if (simulator.tps_stack[0].target==1){
		Text.display(
			startx-marginH*3-3+6*(textWidth+letterSpaceH),
			starty+17*(textHeight+letterSpaceV)+3+3,
			"^",
			Col.WHITE);
	}

	Text.display(startx,starty,"TPS#1",Col.WHITE);

	DrawTable(startx,starty,simulator.data_tps[0],0);

	starty += scriptBoxHeight+38;

	if (simulator.tps_stack[0].target==0){
		Text.display(
			startx-marginH*3-3,
			starty+7*(textHeight+letterSpaceV)+3,
			"<",
			Col.WHITE);
	}

	DrawTable(startx,starty-textHeight-letterSpaceV ,simulator.data_stack[0],3);

	Text.display(startx,starty+scriptBoxHeight+3*marginV,"STACK#1",Col.WHITE);

	starty -= scriptBoxHeight+38;


	startx += boxWidth+marginH*5+3;


	if (simulator.tps[1].target==0){
		Text.display(
			startx-marginH*3-3,
			starty+8*(textHeight+letterSpaceV)+3,
			"<",
			Col.WHITE);
	} else {
		Text.display(
			startx-marginH*3-3+5*(textWidth+letterSpaceH),
			starty+17*(textHeight+letterSpaceV)+3,
			"v",
			Col.WHITE);
	}
	if (simulator.tps_stack[1].target==1){
		Text.display(
			startx-marginH*3-3+6*(textWidth+letterSpaceH),
			starty+17*(textHeight+letterSpaceV)+3+3,
			"^",
			Col.WHITE);
	}

	Text.display(startx,starty,"TPS#2",Col.WHITE);

	DrawTable(startx,starty,simulator.data_tps[1],1);

	starty += scriptBoxHeight+38;

	if (simulator.tps_stack[1].target==0){
		Text.display(
			startx-marginH*3-3,
			starty+7*(textHeight+letterSpaceV)+3,
			"<",
			Col.WHITE);
	}

	DrawTable(startx,starty-textHeight-letterSpaceV ,simulator.data_stack[1],4);

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

	if (simulator.tps[2].target==0){
		Text.display(
			startx-marginH*3-3,
			starty+8*(textHeight+letterSpaceV)+3,
			"<",
			Col.WHITE);
	} else {
		Text.display(
			startx-marginH*3-3+5*(textWidth+letterSpaceH),
			starty+17*(textHeight+letterSpaceV)+3,
			"v",
			Col.WHITE);
	}
	if (simulator.tps_stack[2].target==1){
		Text.display(
			startx-marginH*3-3+6*(textWidth+letterSpaceH),
			starty+17*(textHeight+letterSpaceV)+3+3,
			"^",
			Col.WHITE);
	}

	DrawTable(startx,starty,simulator.data_tps[2],2);

	starty += scriptBoxHeight+38;

	if (simulator.tps_stack[2].target==0){
		Text.display(
			startx-marginH*3-3,
			starty+7*(textHeight+letterSpaceV)+3,
			"<",
			Col.WHITE);
	}

	DrawTable(startx,starty-textHeight-letterSpaceV ,simulator.data_stack[2],5);

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
		"TPS-5 message console V 0.1",
		Col.WHITE);

		Text.display(startx,starty+scriptBoxHeight+3*marginV,"MESSAGES",Col.WHITE);

	var right = startx + commentsBoxWidth+marginH;
	startx=5;
	starty=3;
	right+=startx;
trace(right);
  	Gfx.fillbox(0,0,right,16,0xaaaaaa);
  	Text.display(startx,starty,"CHALLENGES",Col.WHITE);
  	Text.display(startx+20*9,starty,"C01 [RUNNING]",Col.WHITE);
  	Text.display(startx+40*9,starty,"PLAY",Col.WHITE);
  	Text.display(startx+50*9,starty,"STEP",Col.WHITE);
  	Text.display(right-4*9-startx,starty,"HELP",Col.WHITE);

  }

}