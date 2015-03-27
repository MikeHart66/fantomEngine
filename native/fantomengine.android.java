import android.os.Build;

class fantomengine
{
	static String DeviceName()
	{
		return android.os.Build.MODEL;
	}

	static String Hardware()
	{
		return android.os.Build.HARDWARE;
	}
	
	static String User()
	{
		return android.os.Build.USER;
	}

	static String Product()
	{
		return android.os.Build.PRODUCT;
	}

	static String Serial()
	{
		return android.os.Build.SERIAL;
	}
	
	static String GetBrowserName()
	{
		return "---";
	}
	
	static String GetBrowserVersion()
	{
		return "---";
	}
	
	static String GetBrowserPlatform()
	{
		return "---";
	}
}