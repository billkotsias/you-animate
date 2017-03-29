package fanlib.utils
{
	public class Json
	{
		static public function RemoveNonValues(key:*, value:*):* {
			if (value == null) return undefined;
			if ((value is Number) && (value != value)) return undefined;
			//if (value is Array && !(value as Array).length) return undefined;
			if (value is Array) {
				if (!(value as Array).length) return undefined;
			}
			return value;
		}
	}
}