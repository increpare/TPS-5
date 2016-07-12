class Simulator {
	
	public var data:Buffer;

	public var data_tps:Array<Buffer> = new Array<Buffer> ();
	public var data_stack:Array<Buffer> = new Array<Buffer> ();

	public var tps:Array<TPS> = new Array<TPS> ();
	public var tps_stack:Array<TPS> = new Array<TPS> ();

	public var curTargetStack:Array<Int>=[2];
	public var curTarget:Int=2;

	public var specifications:String;

	public function new(data_tokens:Array<String>,tps1_tokens:Array<String>,tps2_tokens:Array<String>,tps3_tokens:Array<String>,specifications){		
		data = new Buffer(32,data_tokens);
		data_tps.push(new Buffer(32,tps1_tokens));
		data_tps.push(new Buffer(32,tps2_tokens));
		data_tps.push(new Buffer(32,tps3_tokens));
		data_stack.push(new Buffer(32));
		data_stack.push(new Buffer(32));
		data_stack.push(new Buffer(32));

		tps.push(new TPS(this, data,			data_tps[0],	data_stack[0]));
		tps.push(new TPS(this, data_tps[0],		data_tps[1],	data_stack[1]));
		tps.push(new TPS(this, data_tps[1],		data_tps[2],	data_stack[2]));

		tps_stack.push(new TPS(this, data, 				data_stack[0], 	data_tps[0]));
		tps_stack.push(new TPS(this, data_stack[0], 	data_stack[1], 	data_tps[1]));
		tps_stack.push(new TPS(this, data_stack[1], 	data_stack[2], 	data_tps[2]));

		tps[0].standardTarget = -1;
		tps[0].altTarget = 3;

		tps[1].standardTarget = 0;
		tps[1].altTarget = 4;

		tps[2].standardTarget = 1;
		tps[2].altTarget = 5;

		tps_stack[0].standardTarget = -1;
		tps_stack[0].altTarget = 0;

		tps_stack[1].standardTarget = 0;
		tps_stack[1].altTarget = 1;

		tps_stack[2].standardTarget = 1;
		tps_stack[2].altTarget = 2;

		this.specifications=specifications;
	}

	public function tick() {
		//var oldStackLength = curTargetStack.length;
		if (curTarget==-1){
			return;
		}
		if (curTarget<=2){
			tps[curTarget].tick();
		} else {
			tps_stack[curTarget-3].tick();
		}
		/*if (curTargetStack.length==oldStackLength){	
			curTargetStack=[2];
			curTarget=2;
		}*/
	}
}