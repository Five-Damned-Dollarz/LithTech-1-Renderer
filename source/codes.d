module Codes;

enum LTResult
{
	Ok=0, // No problem!
	LT_OK=0,
	DE_OK=0,
	Error=1, // Uh oh..
	LT_ERROR=1,
	DE_ERROR=1,
	Finished=2, // Done with operation.
	DE_FINISHED=2,

	// Video status.
	VIDEO_STARTED=10,
	VIDEO_ERROR=11,
	VIDEO_PLAYING=12,
	VIDEO_NOTPLAYING=13,
	DE_TRIEDTOREMOVECLIENTOBJECT=20, // Tried to remove a client's object.
	DE_NOTINWORLD=21, // Tried to do an operation but a world wasn't running.
	DE_MISSINGFILE=22, // Missing the requested file.
	DE_MISSINGWORLDMODEL=23, // Missing the requested WorldModel.
	DE_INVALIDMODELFILE=24, // Invalid model file.
	DE_OBJECTNOTINWORLD=25, // Tried to modify an object but it was removed from the world.
	DE_CANTREMOVESERVEROBJECT=26, // Can't remove a server object from the client.
	DE_CANTLOADGAMERESOURCES=27, // Was missing game rezfile or directory.
	DE_CANTINITIALIZEINPUT=28, // Unable to initialize input.
	DE_MISSINGSHELLDLL=29,
	DE_INVALIDSHELLDLL=30,
	DE_INVALIDSHELLDLLVERSION=31,
	DE_CANTCREATECLIENTSHELL=32,
	DE_UNABLETOINITSOUND=35,
	DE_MISSINGMUSICDLL=36,
	DE_INVALIDMUSICDLL=37,
	DE_UNABLETOINITMUSICDLL=38,
	DE_CANTINITDIRECTPLAY=39,
	DE_USERCANCELED=40, // User canceled connect dialog.
	DE_MISSINGWORLDFILE=41, // Missing world file from server.
	DE_INVALIDWORLDFILE=42, // Invalid world file.
	DE_ERRORBINDINGWORLD=43, // Error binding world to renderer.
	DE_INVALIDSERVERPACKET=44, // Got a bad packet from the server.
	DE_MISSINGSPRITEFILE=45,
	DE_INVALIDSPRITEFILE=46,
	DE_MISSINGMODELFILE=47,
	DE_UNABLETORESTOREVIDEO=48, // Couldn't restore video mode.
	DE_SERVERERROR=49, // Got an error from the server.
	DE_CANTCREATESERVER=50, // Was unable to create a server.
	DE_ERRORLOADINGRENDERDLL=51, // Error loading the render DLL.
	DE_MISSINGCLASS=52, // Missing a needed class from object.dll.
	DE_CANTCREATESERVERSHELL=53, // Unable to create a server shell.
	DE_INVALIDOBJECTDLL=54, // Invalid (or missing) object DLL.
	DE_INVALIDOBJECTDLLVERSION=55, // Invalid object DLL version.
	DE_ERRORINITTINGNETDRIVER=56, // Couldn't initialize net driver.
	LT_NOGAMERESOURCES=57, // No game resources specified.
	DE_CANTRESTOREOBJECT=58, // Couldn't restore an object.
	DE_NODENOTFOUND=59, // Couldn't find the specified model node.
	InvalidParams=60, // Invalid parameters passed to function (like NULL for an HOBJECT).
	DE_INVALIDPARAMS=60,
	DE_NOTFOUND=61, // Something was not found.
	DE_ALREADYEXISTS=62, // Something already exists.
	DE_NOTCONNECTED=63, // Not currently on a server.
	DE_INSIDE=64, // Inside.
	DE_OUTSIDE=65, // Outside.
	DE_INVALIDDATA=66, // Invalid data.
	DE_OUTOFMEMORY=67, // Couldn't get enough memory.  The engine
			// will always shutdown before giving this
			// error, so it's only used in tools.
	DE_MISSINGPALETTE=68, // Internal.
	DE_INVALIDVERSION=69, // Invalid version.
	LT_NOCHANGE=70, // Nothing was changed.
	LT_INPUTBUFFEROVERFLOW=71, // Input buffer overflowed.
	LT_OVERFLOW=71, // Overflow (no shit).
	LT_KEPTSAMEMODE=72, // Wasn't able to switch to new mode.
	LT_NOTINITIALIZED=73,
	LT_ALREADYIN3D=74, // Already between a Start3D/End3D block.
	LT_NOTIN3D=75, // Not between a Start3D/End3D block.
	LT_ERRORCOPYINGFILE=76,
	LT_INVALIDFILE=77,
	LT_INVALIDNETVERSION=78, // Tried to connect to a server with a different
			// network protocol version.
	LT_TIMEOUT=79, // Timed out..
	LT_CANTBINDTOPORT=80, // Couldn't bind to the requested port.
	LT_REJECTED=81, // Connection rejected.
	LT_NOTSAMEGUID=82, // The host you tried to connect to was running a game
			// with a different app DGUID.
	LT_NO3DSOUNDPROVIDER=83, // Unable to initialize the 3d sound provider
}