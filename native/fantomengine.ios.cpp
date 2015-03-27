class fantomengine
{
	public:

	static String DeviceName()
	{
		NSString * localizedModel = [[UIDevice currentDevice] localizedModel];
		return [localizedModel UTF8String];
	}
	static String Hardware()
	{
		NSString *model = [[UIDevice currentDevice] model];
		return [model UTF8String];
	}
	
	static String User()
	{
		NSString * name = [[UIDevice currentDevice] name];
		return [name UTF8String];
	}

	static String Product()
	{
		return '-' ;
	}

	static String Serial()
	{
		NSString *uniqueIdentifier = [[UIDevice currentDevice] uniqueIdentifier];
		return [uniqueIdentifier UTF8String];
	}
	
	static String GetBrowserName()
	{
		return '-' ;
	}
	
	static String GetBrowserVersion()
	{
		return '-' ;
	}

	static String GetBrowserPlatform()
	{
		return '-' ;
	}

};
