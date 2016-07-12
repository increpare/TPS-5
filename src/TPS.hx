import haxegon.*;

class TPS {	
    public var sim : Simulator;

    public var script : Buffer;
    public var data : Buffer;
    public var stack : Buffer;

    public var childTarget:Int;

    public var target : Int = 0;
    public var state : State;
    
    public var contextLock:Bool = false;


//don't forget to set childTarget
    public function new(sim:Simulator, data:Buffer,script:Buffer,stack:Buffer, childTarget:Int){
        this.sim = sim;
        this.script = script;
        this.data = data;
        this.stack = stack;
        this.childTarget = childTarget;
        Reset();
    }

    public function Error(message:String){
        trace(message);
    }

    public function Reset(){
        data.pos = 0;
        script.pos = 0;
        stack.pos = 0;
        state = State.Regular;
    }


    public function PrintData(title:String, tokens:Buffer) : String{
        var result : StringBuf = new StringBuf();

        if (title != "") {
            result.add(title);
            result.add("\n");
        }

        for (i in 0...tokens.length)
        {

            //line number
            if (i < 10)
            {
                result.add("0");
            } 
            result.add(i);

            //position
            if (i == tokens.pos)
            {
                result.add(">");
            } else
            {
                result.add(" ");
            }

            //token
            result.add(tokens.get(i).toUpperCase());
            result.add("\n");
        }
        return result.toString();
    }

    public function Print():String {

        var result : StringBuf = new StringBuf();

        result.add(PrintData("DATA", data));
        result.add("\n");

        result.add(PrintData("SCRIPT", script));
        result.add("\n");

        result.add(PrintData("STACK", stack));
        result.add("\n");

        return result.toString();
    }

    public function Locked():Bool {
        return contextLock || state != State.Regular;
    }

    public function tick(){
        if (target==1){
            var t = data;
            data = stack;
            stack = t;
        }

        if (state == State.While2){
            state = State.While;
        }

        if (state == State.If)
        {
            state = State.Regular;
            if (data.get(data.pos) != script.get(script.pos))
            {
                script.ProgressCursor();
                script.ProgressCursor();
                return;
            } 
        } else if (state == State.IfN)
        {
            state = State.Regular;
            if (data.get(data.pos) == script.get(script.pos))
            {
                script.ProgressCursor();
                script.ProgressCursor();
                return;
            } 
        } else if (state == State.While)
        {
            if (data.get(data.pos) != script.get(script.pos))
            {
                state = State.Regular;
                script.ProgressCursor();
                script.ProgressCursor();
                return;
            }         
            else {      
                script.ProgressCursor();    
                state = State.While2;      
            }
        }  else if (state == State.WhileN)
        {
            if (data.get(data.pos) == script.get(script.pos))
            {
                state = State.Regular;
                script.ProgressCursor();
                script.ProgressCursor();
                return;
            }         
            else {      
                script.ProgressCursor();    
                state = State.While2N;      
            }
        } 
         
        var t : String = script.get(script.pos);
        if (t == "EXEC")
        {
            t = data.get(data.pos);
        }


        switch (t)
        {
            case "PREV":
                if (data.pos>0){
                    data.RegressCursor();
                }
            case "NEXT":
                if (data.pos<data.length-1){
                    data.ProgressCursor();
                }
            case "TOP":
                data.pos=0;
            case "BOTTOM":
                    if (data.length>0){
                        data.pos=data.length-1;
                    } else {
                        data.pos=0;
                    }
            case "PUSH": 
                var item = data.get(data.pos);
                if (item!=""){
                    stack.insert(stack.pos,item);                
                }
            case "POP": 
                var item = stack.get(stack.pos);
                if (item!=""){
                    data.insert(data.pos,item);
                }                
            case "REMOVE":
                data.removeAt(data.pos);
                if (data.pos>=data.length&&data.length>0){
                    data.pos=data.length-1;
                }
            case "END":
                sim.curTarget=-1;
            case "IF":
                if (data.get((data.pos+1)%data.length) != script.get((script.pos+1)%script.length))
                {
                    script.ProgressCursor();
                } 
            case "IFN":
                if (data.get((data.pos+1)%data.length) != script.get((script.pos+1)%script.length))
                {
                    script.ProgressCursor();
                } 
            case "WHILE":
                state = State.While;
                script.ProgressCursor();
            case "WHILEN":
                state = State.WhileN;
                script.ProgressCursor();
            case "EXEC":
                Error("tried to call exec recursively");
            case "TICK":
                if (childTarget>=0){
                    sim.curTarget=childTarget;
                }
            case "SWITCH":
                sim.swapStacks(data,stack);               
            case "SAVE":
                data.storedPos=data.pos;
            case "RESUME":
                if (data.storedPos>=0){                
                    data.pos=data.storedPos;
                }    
            case "IN":         
                if (childTarget>=0){
                    sim.tps[childTarget].contextLock=true;
                    sim.curTarget=childTarget;    
                }
            case "OUT":
                if (sim.curTarget<2){
                    contextLock=false;
                    sim.curTarget++;
                    var targetTPS = sim.tps[sim.curTarget];
                    targetTPS.script.ProgressCursor();
                }
        }

        if (state==State.While || state==State.WhileN){

        } else if (state == State.While2 || state == State.While2N){
            script.RegressCursor();
        } else {
            script.ProgressCursor();        
        }

        if (target==1){
            var t = data;
            data = stack;
            stack = t;
        }
    }

}