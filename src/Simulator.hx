class Simulator {
	
	public var data:Buffer;

	public var data_tps:Array<Buffer> = new Array<Buffer> ();
	public var data_stack:Array<Buffer> = new Array<Buffer> ();

	public var tps:Array<TPS> = new Array<TPS> ();


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

		tps.push(new TPS(this, data,			data_tps[0],	data_stack[0],	-1));
		tps.push(new TPS(this, data_tps[0],		data_tps[1],	data_stack[1],	0));
		tps.push(new TPS(this, data_tps[1],		data_tps[2],	data_stack[2],	1));

		this.specifications=specifications;
	}

	public function swapStacks(a : Buffer, b : Buffer){

		//data
		if (data==a){
			data=b;
		} else if (data==b){
			data=a;
		}

		//data_tps
		for(i in 0...data_tps.length){
			if (data_tps[i]==a){
				data_tps[i]=b;
			} else if (data_tps[i]==b){
				data_tps[i]=a;
			}
		}

		//data_stack
		for(i in 0...data_stack.length){
			if (data_stack[i]==a){
				data_stack[i]=b;
			} else if (data_stack[i]==b){
				data_stack[i]=a;
			}
		}

		//tps
		for(i in 0...tps.length){
			var curTPS = tps[i];
			
			
			if (curTPS.data==a){
				curTPS.data=b;
			} else if (curTPS.data==b){
				curTPS.data=a;
			}
			
			if (curTPS.script==a){
				curTPS.script=b;
			} else if (curTPS.script==b){
				curTPS.script=a;
			}

			if (curTPS.stack==a){
				curTPS.stack=b;
			} else if (curTPS.stack==b){
				curTPS.stack=a;
			}
		}

	}
	public function tick() {
		var oldTarget = curTarget;

		if (curTarget==-1){
			return;
		}
		
		tps[curTarget].tick();

		if (oldTarget == curTarget){	
			while ( !tps[curTarget].Locked() && curTarget<2){
				curTarget++;
			}
		}
	}
}