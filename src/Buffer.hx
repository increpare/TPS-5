class Buffer {
	public var dat:Array<String>;
	public var capacity:Int;
	public var pos:Int;
	public var storedPos:Int;

	public function toString():Array<String> {
		var sb1:StringBuf = new StringBuf();
		var sb2:StringBuf = new StringBuf();
		for(i in 0...dat.length){			
			if (i<16){
				sb1.add(dat[i]);
				sb1.add("\n");
			} else {
				sb2.add(dat[i]);
				sb2.add("\n");			
			}
		}
		return [sb1.toString(),sb2.toString()];
	}

	public inline function get(key:Int) {
		if (key==0&&dat.length==0){
			return "";			
		}

		return dat[key];
	}

	public var length(get, null):Int;

  	function get_length():Int {
    	return dat.length;
  	}	 

  	public function insert(pos:Int, s:String){
  		dat.insert(pos,s);
  		if (dat.length>capacity){
  			dat.pop();
  		}
  	}
  	public function removeAt(pos:Int){
  		dat.splice(pos,1);
  	}

	public inline function set(k:Int, v:String):String {
		if (pos==0&& dat.length==0){
			dat.push(v);
			} else {
				dat[k]=v;
			}
			return v;
		}

	public function new(_capacity:Int, ?_dat:Array<String> ){			
		storedPos=-1;
		capacity=_capacity;
		if (_dat==null){
			dat = new Array<String>();
		} else {
			dat = _dat;
			if (dat.length>capacity){
				dat.splice(capacity,dat.length-capacity);
			}
		}
	}

		public function push(t:String){
			dat.insert(pos,t);
			if (dat.length>=capacity){
				dat.pop();
			}
		}

		public function clear(){
			dat.splice(0,dat.length);
			pos=0;
		}
	}