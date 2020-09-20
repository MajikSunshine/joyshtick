--JoyShtick version 1.7
--Ingame joystick saturation utility to increase sensitivity
--declare("joyshtick", {})
joyshtick = {}

joyshtick.info = {} --data from joystick.GetJoystickData()
joyshtick.numaxis = {}
joyshtick.numjoysticks = "0"
joyshtick.version = "1.7"
joyshtick.saturation = "0"
joyshtick.rawturn = 0
joyshtick.rawpitch = 0
joyshtickinit = {}--startup text print
joyshtickui = {}--settings dialog
joyshtickui.turnport = iup.list{dropdown = 'YES', value = ""}
joyshtickui.pitchport = iup.list{dropdown = 'YES', value = ""}
joyshtickui.turnaxis = iup.list{dropdown = 'YES', value = ""}
joyshtickui.pitchaxis = iup.list{dropdown = 'YES', value = ""}

--print startup text
function joyshtickinit:OnEvent(event, id)
	print("JoyShtick Version " .. joyshtick.version .. " [ " .. getjoysticks() .. " joystick(s) detected ]")
end

RegisterEvent(joyshtickinit, "PLAYER_ENTERED_GAME")

--read saved joystick settings from config.ini file
joyshtick.turnport = gkini.ReadString("joyshtick", "turnport", "-1")
joyshtick.pitchport = gkini.ReadString("joyshtick", "pitchport", "-1")
joyshtick.turnaxis = gkini.ReadString("joyshtick", "turnaxis", "-1")
joyshtick.pitchaxis = gkini.ReadString("joyshtick", "pitchaxis", "-1")

function getjoysticks()
	joyshtick.numjoysticks = 0
	for x = 0, 9 do
		joyshtick.info = joystick.GetJoystickData(x)
		if joyshtick.info then
		joyshtick[x] = joyshtick.info
		joyshtickui.turnport[x+1] = joyshtick[x].Name
		joyshtickui.pitchport[x+1] = joyshtick[x].Name
		joyshtick.numaxis[x] = joystick.GetJoystickNumAxes(x)
		joyshtick.numjoysticks = joyshtick.numjoysticks + 1
		end
	end
	if joyshtick.numjoysticks == 0 then
		print ("No joysticks were found")
	else print(joyshtick.numjoysticks .. " controllers were found")
	end
	if tonumber(joyshtick.turnport) > 0 then
		joyshtickui.turnport.value = joyshtick.turnport
	end
	if tonumber(joyshtick.pitchport) > 0 then
		joyshtickui.pitchport.value = joyshtick.pitchport
	end
	return joyshtick.numjoysticks
end

function joyshtickui.turnport:action (text,item,state)
	if (state == 1 and item) then--Item was selected, number of the item
		for y = 1, joyshtick.numaxis [item-1] do
			joyshtickui.turnaxis[y] = joyshtick[item-1].AxisNames[y]
		end
		joyshtickui.turnaxis[joyshtick.numaxis [item-1]+1] = nil--sets end of list
		iup.Refresh (joyshtickui.turnaxis)
		joyshtick.turnport = tostring(joyshtickui.turnport.value)
	end
end

function joyshtickui.pitchport:action (text,item,state)
	if (state == 1 and item) then
		for y = 1, joyshtick.numaxis [item-1] do
			joyshtickui.pitchaxis[y] = joyshtick[item-1].AxisNames[y]
		end
		joyshtickui.pitchaxis[joyshtick.numaxis [item-1]+1] = nil--sets end of list
		iup.Refresh (joyshtickui.pitchaxis)
		joyshtick.pitchport = tostring(joyshtickui.pitchport.value)
	end
end

function joyshtickui.turnaxis:action (text,item,state)
	if (state == 1 and item) then
		joyshtick.turnaxis = tostring(joyshtickui.turnaxis.value)
	end
end

function joyshtickui.pitchaxis:action (text,item,state)
	if (state == 1 and item) then
		joyshtick.pitchaxis = tostring(joyshtickui.pitchaxis.value)
	end
end

function joyshtickshow ()--open settings dialog
		ShowDialog(joyshtickui.dialog)
	setsat()
end
--setup "/js" to open settings dialog
RegisterUserCommand("js",joyshtickshow)

function joyshtickhide ()--close settings dialog
	HideDialog(joyshtickui.dialog)
end
--settings dialog "close" button
joyshtickui.close = iup.stationbutton{title="Click To Close", expand="HORIZONTAL", action=joyshtickhide}

function joyshticksave ()
	gkini.WriteString("joyshtick", "turnport", ""..tostring(joyshtick.turnport))
	gkini.WriteString("joyshtick", "pitchport", ""..tostring(joyshtick.pitchport))
	gkini.WriteString("joyshtick", "turnaxis", ""..tostring(joyshtick.turnaxis))
	gkini.WriteString("joyshtick", "pitchaxis", ""..tostring(joyshtick.pitchaxis))
end

joyshtickui.save = iup.stationbutton{title="Click To Save Settings", expand="HORIZONTAL", action=joyshticksave}

--Create settings dialog window
joyshtickui.dialog = iup.dialog{
	iup.vbox{
	iup.fill{},
		iup.hbox{
		iup.fill{},
		joyshtickui.close,
		joyshtickui.save,
		},
		iup.hbox{
		iup.fill{},
			iup.vbox{
			iup.fill{},
			iup.label { title = " Select Turn", bgcolor = "0 100 0", fgcolor = "255 255 255" },
			iup.label { title = "  Joystick Port" },
			iup.label { title = "     Select Axis" },
			},
			iup.vbox{
			iup.fill{},
			joyshtickui.turnport,
			joyshtickui.turnaxis,
			},
			iup.vbox{
			iup.fill{},
			iup.label { title = "Select Pitch", bgcolor = "0 100 0", fgcolor = "255 255 255" },
			iup.label { title = "  Joystick Port" },
			iup.label { title = "     Select Axis" },
			},
			iup.vbox{
			iup.fill{},
			joyshtickui.pitchport,
			joyshtickui.pitchaxis,
			},
		},
	},
	fullscreen="NO",
    topmost = "YES",
    BORDER="NO",
    RESIZE="NO",
    MAXBOX="NO",
    MINBOX="NO",
    MENUBOX="NO",
    MODAL="YES",
}

function setsat ()
print(joyshtick.turnport)
print(joyshtick.turnaxis)
	joyshtick.rawturn = joystick.GetJoystickSingleAxisValue(joyshtick.turnport, joyshtick.turnaxis)
	print(joystick.GetJoystickSingleAxisValue(1,2))
	joyshtick.rawpitch = joystick.GetJoystickSingleAxisValue(joyshtick.pitchport, joyshtick.pitchaxis)
print(joyshtick.pitchport)
print(joyshtick.pitchaxis)
	print(joyshtick.rawpitch)
	if joyshtick.rawturn > joyshtick.rawpitch then
		joystick.SetJoystickSingleAxisSaturation(joyshtick.turnport, joyshtick.turnaxis, joyshtick.rawturn/1000*100, (joyshtick.rawturn/1000*100)/100)
	else
		joystick.SetJoystickSingleAxisSaturation(joyshtick.pitchport, joyshtick.pitchaxis, joyshtick.rawpitch/1000*100, (joyshtick.rawpitch/1000*100)/100)
	end
end

