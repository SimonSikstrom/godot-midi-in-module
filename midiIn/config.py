def can_build(plat):
	return plat == "android" or plat == "iphone" or plat == "osx"

def configure(env):
	if (env['platform'] == 'android'):
		module_env = env.Clone()
		module_env.android_add_java_dir("android")
		module_env.android_add_to_manifest("android/AndroidManifestChunk.xml")
	
	if env['platform'] == "iphone" or env['platform'] == "osx":
		module_env = env.Clone()
		module_env.Append(LINKFLAGS=['-ObjC', '-framework', 'CoreMIDI', '-Wfunction-def-in-objc-container'])
