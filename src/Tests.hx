import openfl.Assets;
import haxe.Serializer;
import haxe.Unserializer;
import js.Browser;

class Tests {

	public static function RunTests(){
		var list = Assets.list(AssetType.TEXT);
		var failCount=0;
		var testCount=0;
		for (path in list){
			if (path.indexOf("data/text/tests/")!=0){
				continue;
			}

			var s = Assets.getText(path);
			testCount++;

			var unserializer = new Unserializer(s);
			var simulatorStateStr : String = unserializer.unserialize();	
			var stepCount : Int = unserializer.unserialize();		
			var simulatorTargetState : Simulator = unserializer.unserialize();

			var serializer = new Serializer();
			serializer.useCache=true;
			serializer.serialize(simulatorTargetState);
			var desiredOutput : String = serializer.toString();

			var unserializer2 = new Unserializer(simulatorStateStr);
			var simulator:Simulator = unserializer2.unserialize();

			for (i in 0...stepCount){
				simulator.tick();
			}

			var serializer2 = new Serializer();
			serializer2.useCache=true;
			serializer2.serialize(simulator);
			var actualOutput = serializer2.toString();
			if (actualOutput == desiredOutput){
				trace(path + " passed!");
			}
			else 
			{
				trace(path + " failed!");
				failCount++;				
				Browser.window.console.log(actualOutput);
				Browser.window.console.log(desiredOutput);
			}

		}
		if (failCount==0){			
				Browser.window.alert("success!");
		} else {
				Browser.window.alert("failed!");
		}
		
		trace(list);
	}
}