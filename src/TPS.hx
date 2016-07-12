import haxegon.*;

enum State {
    Regular;
    If;
    While;
}

class TPS {	
    public var sim : Simulator;

    public var script : Buffer;
    public var data : Buffer;
    public var stack : Buffer;

    public var standardTarget:Int;
    public var altTarget:Int;

    public var target:Int=0;
    var state : State;


//don't forget to set standardTarget + altTarget!
    public function new(sim:Simulator, data:Buffer,script:Buffer,stack:Buffer){
        this.sim = sim;
        this.script = script;
        this.data = data;
        this.stack = stack;
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

    public function tick(){
        if (target==1){
            var t = data;
            data = stack;
            stack = t;
        }
        if (state == State.If)
        {
            state = State.Regular;
            if (data.get(data.pos) != script.get(script.pos))
            {
                script.pos +=2;
                return;
            } 
        } else if (state == State.While)
        {
            if (data.get(data.pos) != script.get(script.pos-1))
            {
                state = State.Regular;
                script.pos += 1;
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
                    data.pos--;
                }
            case "NEXT":
                if (data.pos<data.length-1){
                    data.pos++;
                }
            case "TOP":
                data.pos=0;
            case "BOTTOM":
                data.pos=data.length-1;
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
                if (data.pos>=data.length){
                    data.pos=data.length-1;
                }
            case "END":
                script.pos=-1;
            case "IF":
                state = State.If;
            case "WHILE":
                state = State.While;
                script.pos++;
            case "EXEC":
                Error("tried to call exec recursively");
            //case "TICK":
            //    sim.curTarget=target==0?standardTarget:altTarget;
            //    sim.curTargetStack.push(sim.curTarget);
            case "SWITCH":
                target = 1-target;
                if (target==0){
                    var t = data;
                    data = stack;
                    stack = t;
                }
            case "SAVE":
                data.storedPos=data.pos;
            case "RESUME":
                if (data.storedPos>=0){                
                    data.pos=data.storedPos;
                }    
            case "IN":         
                sim.curTarget=target==0?standardTarget:altTarget;
                sim.curTargetStack.push(sim.curTarget);
            case "OUT":
                if (sim.curTargetStack.length>1){
                    sim.curTargetStack.pop();
                    sim.curTarget = sim.curTargetStack[sim.curTargetStack.length-1];
                }
        }
        script.pos++;
        if (script.pos>=script.length){
            script.pos=script.length-1;
        }

        if (target==1){
            var t = data;
            data = stack;
            stack = t;
        }
    }

}