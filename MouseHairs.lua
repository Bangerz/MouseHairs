


_G.CreateFrame("Frame"):SetScript("OnUpdate", function(self, elapsed)

	if IsMouselooking() then
		AddHideCondition("Mouselook");
	else
		RemoveHideCondition("Mouselook");
	end
end)

BINDING_HEADER_MOUSEHAIRS = "Mouse Sonar";
BINDING_NAME_FINDMOUSE = "Find Mouse";

local g_MouseHairsOptPanel = {};
local g_activeHideConditions = {};
local g_combat = false;
local g_circleInitialized = false;

local g_circle = CreateFrame("Model", nil, self);
g_circle:SetWidth(0);
g_circle:SetHeight(0);
g_circle:Show();
local g_texture = g_circle:CreateTexture(nil,"BACKGROUND");
g_texture:SetTexture("Interface\\AddOns\\MouseHairs\\Circle_White");
g_texture:SetVertexColor(1, 1, 1 , 1);
g_texture:SetAllPoints(g_circle);
g_texture:SetVertexColor(1,1,1);

function AddHideCondition(conditionName)
	if not g_activeHideConditions[conditionName] then
		g_activeHideConditions[conditionName] = true;
		g_circle:Hide();
	end
end


function RemoveHideCondition(conditionName)
	if g_activeHideConditions[conditionName] then
		g_activeHideConditions[conditionName] = nil;

		if next(g_activeHideConditions) == nil and MouseHairsOpt.onMouselook then
			ShowCircle();
		end
	end
end

--local f = CreateFrame('frame', "Crosshairs", WorldFrame)
----LibStub('LibNameplateRegistry-1.0'):Embed(f)
--f:SetFrameLevel(0)
--f:SetFrameStrata('BACKGROUND')
--f:SetPoint('CENTER')
--f:SetSize(64, 64)
----f:SetAlpha(0.5)

local uiScale = 1
--local screen_size = {GetPhysicalScreenSize()}
--if screen_size and screen_size[2] then
--	uiScale = 768 / screen_size[2]
--end
local lineWidth = uiScale

--local circle = WorldFrame:CreateTexture(nil, 'BACKGROUND')
--circle:SetTexture([[interface/addons/MouseHairs/circle]])
--circle:SetAllPoints(g_circle)
--circle:SetAlpha(alpha)
----circle:SetPoint('CENTER')
----circle:SetSize(86, 86)

local left = WorldFrame:CreateTexture(nil, 'BACKGROUND')
left:SetScale(1.0)
left:SetTexture([[interface/addons/MouseHairs/horizontal]],true)
left:SetTexCoord(left, right, top, bottom)
--left:SetColorTexture(1, 1, 1, alpha)
left:SetPoint('RIGHT', g_circle, 'LEFT', 0, 0)
left:SetSize(2000, lineWidth)
left:SetTexCoord(0,1,0,1)
left:SetHorizTile(true)
left:SetVertTile(false)
--left:SetAlpha(alpha)

local right = WorldFrame:CreateTexture(nil, 'BACKGROUND')
right:SetScale(1.0)
right:SetTexture([[interface/addons/MouseHairs/horizontal]],true)
--right:SetColorTexture(1, 1, 1, alpha)
right:SetPoint('LEFT', g_circle, 'RIGHT', 0, 0)
right:SetSize(2000, lineWidth)
right:SetTexCoord(0,1,0,1)
right:SetHorizTile(true)
right:SetVertTile(false)
--right:SetAlpha(alpha)

local top = WorldFrame:CreateTexture(nil, 'BACKGROUND')
top:SetScale(1.0)
top:SetTexture([[interface/addons/MouseHairs/vertical]],false,true)
--top:SetColorTexture(1, 1, 1, alpha)
top:SetPoint('BOTTOM', g_circle, 'TOP', 0, 0)
top:SetSize(lineWidth, 2000)
top:SetTexCoord(0,1,0,1)
top:SetHorizTile(false)
top:SetVertTile(true)
--top:SetAlpha(alpha)

local bottom = WorldFrame:CreateTexture(nil, 'BACKGROUND')
bottom:SetScale(1.0)
bottom:SetTexture([[interface/addons/MouseHairs/vertical]],false,true)
--bottom:SetColorTexture(1, 1, 1, alpha)
bottom:SetPoint('TOP', g_circle, 'BOTTOM', 0, 4)
bottom:SetSize(lineWidth, 2000)
bottom:SetTexCoord(0,1,0,1)
bottom:SetHorizTile(false)
bottom:SetVertTile(true)
--bottom:SetAlpha(alpha)

---[[
--circle:SetBlendMode('ADD')
left:SetBlendMode('DISABLE')
right:SetBlendMode('DISABLE')
top:SetBlendMode('DISABLE')
bottom:SetBlendMode('DISABLE')
--]]

--local tx = WorldFrame:CreateTexture(nil, 'BACKGROUND')
--tx:SetTexture([[interface/addons/MouseHairs/arrows]])
--tx:SetAllPoints(g_circle)
--tx:SetPoint('CENTER')
--tx:SetSize(86, 86)
--tx:SetAlpha(0.5)

local function HideEverything()
	--circle:Hide()
	left:Hide()
	right:Hide()
	top:Hide()
	bottom:Hide()
	--tx:Hide()
end

local function ShowEverything()
	--circle:Show()
	left:Show()
	right:Show()
	top:Show()
	bottom:Show()
	--tx:Show()
end

g_circle:HookScript('OnHide', HideEverything)
g_circle:HookScript('OnShow', ShowEverything)
g_circle:Hide()



local PULSE_LIFE_TIME = 0.5; -- seconds
local g_totalElapsed = -1;

local function SquareInvertFunc(elapsedTime, startingValue)
	local temp = elapsedTime / PULSE_LIFE_TIME;
	local value = 1.0 - (temp * temp);
	return value * startingValue;
end

local function UpdatePulse(elapsed)

	if g_totalElapsed == -1 then
		return;
	elseif g_totalElapsed > PULSE_LIFE_TIME then
		g_totalElapsed = -1;
		g_circle:Hide();
		return;
	end


	local alpha = SquareInvertFunc(g_totalElapsed, MouseHairsOpt.startingAlphaValue);
	g_texture:SetAlpha(alpha);
	local linealpha = SquareInvertFunc(g_totalElapsed, MouseHairsOpt.lineAlphaValue);
    left:SetAlpha(alpha);
	right:SetAlpha(alpha);
	top:SetAlpha(alpha);
	bottom:SetAlpha(alpha);
	local pulseSizeThisFrame = SquareInvertFunc(g_totalElapsed, MouseHairsOpt.pulseSize);
	g_circle:SetWidth(pulseSizeThisFrame);
	g_circle:SetHeight(pulseSizeThisFrame);

	local cursorX, cursorY = GetCursorPosition();
	g_circle:SetPoint("BOTTOMLEFT", cursorX - (pulseSizeThisFrame * 0.5), cursorY - (pulseSizeThisFrame * 0.5));

	g_totalElapsed = g_totalElapsed + elapsed;
end

local function UpdateAlwaysVisible()

	if not g_circleInitialized then

		g_circle:SetWidth(MouseHairsOpt.pulseSize);
		g_circle:SetHeight(MouseHairsOpt.pulseSize);
		g_texture:SetAlpha(MouseHairsOpt.startingAlphaValue);
        left:SetAlpha(MouseHairsOpt.lineAlphaValue);
        right:SetAlpha(MouseHairsOpt.lineAlphaValue);
        top:SetAlpha(MouseHairsOpt.lineAlphaValue);
        bottom:SetAlpha(MouseHairsOpt.lineAlphaValue);

		g_circleInitialized = true;
	end


	-- TOGGLE VISIBLE
	local combatOK = not MouseHairsOpt.onlyCombat or g_combat;
	local raidOK = not MouseHairsOpt.onlyRaid or IsInRaid();
	local canBeShown = combatOK and raidOK;

	local isCurrentlyVisible = g_circle:IsVisible();

	if not isCurrentlyVisible and canBeShown then
		g_circle:Show();
	elseif isCurrentlyVisible and not canBeShown then
		g_circle:Hide();
	end


	local cursorX, cursorY = GetCursorPosition();
	g_circle:SetPoint("BOTTOMLEFT", cursorX - (MouseHairsOpt.pulseSize * 0.5), cursorY - (MouseHairsOpt.pulseSize * 0.5));
end

local function onUpdate(self, elapsed)

	if MouseHairsOpt.deactivated then
		return;
	end

	if MouseHairsOpt.alwaysVisible then
		UpdateAlwaysVisible();
	else
		UpdatePulse(elapsed);
	end
end


local function refreshPulseColor()
	g_texture:SetVertexColor(MouseHairsOpt.colorValue[1], MouseHairsOpt.colorValue[2], MouseHairsOpt.colorValue[3])
end


local MouseHairs = CreateFrame("frame");
MouseHairs:SetScript("OnEvent", function(self, event, ...)
	self[event](self, ...);
end);
g_circle:SetScript("OnUpdate", onUpdate);
MouseHairs:RegisterEvent("ADDON_LOADED");
MouseHairs:RegisterEvent("CINEMATIC_START");
MouseHairs:RegisterEvent("CINEMATIC_STOP");
MouseHairs:RegisterEvent("SCREENSHOT_FAILED");
MouseHairs:RegisterEvent("SCREENSHOT_SUCCEEDED");
MouseHairs:RegisterEvent("PLAYER_REGEN_DISABLED");
MouseHairs:RegisterEvent("PLAYER_REGEN_ENABLED");


function MouseHairs:ADDON_LOADED(addon,...)
	if addon == "MouseHairs" then
		MouseHairsOpt =
			{
				deactivated = (MouseHairsOpt ~= nil and MouseHairsOpt.deactivated) or (MouseHairsOpt == nil and false),
				alwaysVisible = (MouseHairsOpt ~= nil and MouseHairsOpt.alwaysVisible) or (MouseHairsOpt == nil and true),
				pulseSize = (MouseHairsOpt ~= nil and MouseHairsOpt.pulseSize) or 16,
				startingAlphaValue = (MouseHairsOpt ~= nil and MouseHairsOpt.startingAlphaValue) or 0,
				lineAlphaValue = (MouseHairsOpt ~= nil and MouseHairsOpt.lineAlphaValue) or 0.6,
				onlyCombat = (MouseHairsOpt ~= nil and MouseHairsOpt.onlyCombat) or (MouseHairsOpt == nil and false),
				onlyRaid = (MouseHairsOpt ~= nil and MouseHairsOpt.onlyRaid) or (MouseHairsOpt == nil and false),
				onMouselook = (MouseHairsOpt ~= nil and MouseHairsOpt.onMouselook) or (MouseHairsOpt == nil and true),
				colorValue = (MouseHairsOpt ~= nil and MouseHairsOpt.colorValue) or {1,1,1},
				HollowCircle = (MouseHairsOpt ~= nil and MouseHairsOpt.HollowCircle) or (MouseHairsOpt == nil and false),
			}
		UpdatePulseTexture();
		createOptions();
		refreshPulseColor();
		ToggleAlwaysVisible();
	end
end

function MouseHairs:SCREENSHOT_FAILED()
	RemoveHideCondition("Screenshot");
end

function MouseHairs:PLAYER_REGEN_ENABLED( ... )
	g_combat = false;
end

function MouseHairs:PLAYER_REGEN_DISABLED( ... )
	g_combat = true;
	ToggleAlwaysVisible();
end

MouseHairs.SCREENSHOT_SUCCEEDED = MouseHairs.SCREENSHOT_FAILED;


function MouseHairs:CINEMATIC_START()
	AddHideCondition("Cinematic");
end

function MouseHairs:CINEMATIC_STOP()
	RemoveHideCondition("Cinematic");
end

-- Hide during screenshots
_G.hooksecurefunc("Screenshot", function()
	AddHideCondition("Screenshot");
end);

-- Hide while FMV movies play
_G.MovieFrame:HookScript("OnShow", function()
	AddHideCondition("Movie") -- FMV movie sequence, like the Wrathgate cinematic
end);

_G.MovieFrame:HookScript("OnHide", function()
	RemoveHideCondition("Movie");
end);

-- Hook camera movement to hide cursor effects
_G.hooksecurefunc("CameraOrSelectOrMoveStart", function()
	AddHideCondition("Camera");
end);

_G.hooksecurefunc("CameraOrSelectOrMoveStop", function()
	RemoveHideCondition("Camera");
end);



function ShowCircle(bypass)
	if (g_combat or not MouseHairsOpt.onlyCombat) and (IsInRaid() or not MouseHairsOpt.onlyRaid) or bypass then

		g_totalElapsed = 0;
		g_circleInitialized = false;
		g_circle:Show();
	end
end

function ToggleAlwaysVisible()

	if MouseHairsOpt.alwaysVisible and not MouseHairsOpt.deactivated and (not MouseHairsOpt.onlyCombat or g_combat) and (not MouseHairsOpt.onlyRaid or IsInRaid()) then
		ShowCircle();
		return true;
	end

	return false;
end

SlashCmdList["PULSE"] = function() ShowCircle(1) end;
SLASH_PULSE1 = "/pulse";


--OPTIONS

local function createLabel(name)
	local label = g_MouseHairsOptPanel.panel:CreateFontString(nil, "ARTWORK", "GameFontHighlight");
	label:SetText(name);
	return label;
end
local function createCheck(key, wth, hgt)
	local chkOpt = CreateFrame("CheckButton", "MouseHairs_" .. key, g_MouseHairsOptPanel.panel, "UICheckButtonTemplate");
	chkOpt:SetWidth(wth);
	chkOpt:SetHeight(hgt);
	return chkOpt;
end
local function createSlider(name, x, y, min, max, step)
	local sliderOpt = CreateFrame("Slider", "MouseHairs_" .. name, g_MouseHairsOptPanel.panel, "OptionsSliderTemplate");
	sliderOpt:SetWidth(x);
	sliderOpt:SetHeight(y);
	sliderOpt:SetMinMaxValues(min, max);
	sliderOpt:SetValueStep(step);
	_G[sliderOpt:GetName() .. "Low"]:SetText(min);
	_G[sliderOpt:GetName() .. "High"]:SetText(max);
	_G[sliderOpt:GetName() .. "Text"]:SetText(name);
	return sliderOpt;
end

local function showColorPicker(r,g,b,a,callback)
	ColorPickerFrame:SetColorRGB(r,g,b);
	ColorPickerFrame.hasOpacity = false;
	ColorPickerFrame.opacity = (a ~= nil), a;
	ColorPickerFrame.previousValues = {r,g,b,a};
	ColorPickerFrame.func, ColorPickerFrame.opacityFunc, ColorPickerFrame.cancelFunc = callback, callback, callback;
	ColorPickerFrame:Hide(); -- Need to run the OnShow handler.
	ColorPickerFrame:Show();
end


local function createColorSelect(name,...)
	--frame
	local f = CreateFrame("FRAME","MouseHairs_" .. name,g_MouseHairsOptPanel.panel);
	f:SetSize(25,25);
	f:SetPoint("CENTER",0,0);

	--texture
	f.tex = f:CreateTexture(nil,"BACKGROUND");
	f.tex:SetAllPoints(f);
	f.tex:SetColorTexture(MouseHairsOpt.colorValue[1], MouseHairsOpt.colorValue[2], MouseHairsOpt.colorValue[3], 1);

	--recolor callback function
	f.recolorTexture = function(oldColor)
		local r,g,b,a;
		if not oldColor then
			r,g,b = ColorPickerFrame:GetColorRGB();
			a = 1;
			f.tex:SetColorTexture(r,g,b,a);
			MouseHairsOpt.colorValue[1], MouseHairsOpt.colorValue[2], MouseHairsOpt.colorValue[3] = r,g,b;
			refreshPulseColor();
		else
			f.tex:SetColorTexture(MouseHairsOpt.colorValue[1], MouseHairsOpt.colorValue[2], MouseHairsOpt.colorValue[3], 1);
		end
	end

	f:EnableMouse(true)
	f:SetScript("OnMouseDown", function(self,button,...)
		if button == "LeftButton" then
			local r,g,b = MouseHairsOpt.colorValue[1], MouseHairsOpt.colorValue[2], MouseHairsOpt.colorValue[3];
			showColorPicker(r,g,b,1,self.recolorTexture);
		end
	end)

	return f
end

function UpdatePulseTexture()
	if MouseHairsOpt.HollowCircle then
		g_texture:SetTexture("Interface\\AddOns\\MouseHairs\\Circle_Hollow");
	else
		g_texture:SetTexture("Interface\\AddOns\\MouseHairs\\Circle_White");
	end
end

function createOptions()
	g_MouseHairsOptPanel.panel = CreateFrame( "Frame", "Mouse Sonar Options", UIParent);
	g_MouseHairsOptPanel.panel.name = "Mouse Sonar Options";


	-- DEACTIVATED
	g_MouseHairsOptPanel.lab = createLabel("Deactivated");
	g_MouseHairsOptPanel.lab:SetPoint("TOPLEFT", 80, -48);
	g_MouseHairsOptPanel.chk = createCheck("chkDeactivate", 20, 20);
	g_MouseHairsOptPanel.chk:SetPoint("TOPLEFT", 60, -45);
	g_MouseHairsOptPanel.chk:SetChecked(MouseHairsOpt.deactivated);

	g_MouseHairsOptPanel.chk:SetScript("OnClick", function()
		MouseHairsOpt.deactivated = not MouseHairsOpt.deactivated;

		if not ToggleAlwaysVisible() then
			g_circle:Hide();
		end
	end);


	-- ALWAYS VISIBLE
	g_MouseHairsOptPanel.lab = createLabel("Circle always visible");
	g_MouseHairsOptPanel.lab:SetPoint("TOPLEFT", 80, -68);
	g_MouseHairsOptPanel.chk = createCheck("chkAlwaysVisible", 20, 20);
	g_MouseHairsOptPanel.chk:SetPoint("TOPLEFT", 60, -65);
	g_MouseHairsOptPanel.chk:SetChecked(MouseHairsOpt.alwaysVisible);

	g_MouseHairsOptPanel.chk:SetScript("OnClick", function()
		MouseHairsOpt.alwaysVisible = not MouseHairsOpt.alwaysVisible;
		ToggleAlwaysVisible();
	end);

	-- ONLY IN COMBAT
	g_MouseHairsOptPanel.lab = createLabel("Show only in Combat");
	g_MouseHairsOptPanel.lab:SetPoint("TOPLEFT", 80, -88);
	g_MouseHairsOptPanel.chk = createCheck("chkOnlyInCombat", 20, 20);
	g_MouseHairsOptPanel.chk:SetPoint("TOPLEFT", 60, -85);
	g_MouseHairsOptPanel.chk:SetChecked(MouseHairsOpt.onlyCombat);

	g_MouseHairsOptPanel.chk:SetScript("OnClick", function()
		MouseHairsOpt.onlyCombat = not MouseHairsOpt.onlyCombat;
		ToggleAlwaysVisible();
	end)

	-- ONLY IN RAID
	g_MouseHairsOptPanel.lab = createLabel("Show only while in raid group");
	g_MouseHairsOptPanel.lab:SetPoint("TOPLEFT", 80, -108);
	g_MouseHairsOptPanel.chk = createCheck("chkOnlyInRaid", 20, 20);
	g_MouseHairsOptPanel.chk:SetPoint("TOPLEFT", 60, -105);
	g_MouseHairsOptPanel.chk:SetChecked(MouseHairsOpt.onlyRaid);

	g_MouseHairsOptPanel.chk:SetScript("OnClick", function()
		MouseHairsOpt.onlyRaid = not MouseHairsOpt.onlyRaid;
		ToggleAlwaysVisible();
	end)


	-- MOUSE LOOK END
	g_MouseHairsOptPanel.lab = createLabel("Show on Mouselook end");
	g_MouseHairsOptPanel.lab:SetPoint("TOPLEFT", 80, -128);
	g_MouseHairsOptPanel.chk = createCheck("chkMouselook", 20, 20);
	g_MouseHairsOptPanel.chk:SetPoint("TOPLEFT", 60, -125);
	g_MouseHairsOptPanel.chk:SetChecked(MouseHairsOpt.onMouselook);

	g_MouseHairsOptPanel.chk:SetScript("OnClick", function()
		MouseHairsOpt.onMouselook = not MouseHairsOpt.onMouselook;
	end);

	-- HOLLOW CIRCLE OPTION
	g_MouseHairsOptPanel.lab = createLabel("Show as Hollow Circle");
	g_MouseHairsOptPanel.lab:SetPoint("TOPLEFT", 80, -148);
	g_MouseHairsOptPanel.chk = createCheck("chkHollowCircle", 20, 20);
	g_MouseHairsOptPanel.chk:SetPoint("TOPLEFT", 60, -145);
	g_MouseHairsOptPanel.chk:SetChecked(MouseHairsOpt.HollowCircle);

	g_MouseHairsOptPanel.chk:SetScript("OnClick", function()
		MouseHairsOpt.HollowCircle = not MouseHairsOpt.HollowCircle;
		UpdatePulseTexture();
	end);


	-- PULSE SIZE
	g_MouseHairsOptPanel.slider = createSlider("Pulse Size", 140, 15, 16, 1024, 32);
	g_MouseHairsOptPanel.slider:SetValue(MouseHairsOpt.pulseSize);
	g_MouseHairsOptPanel.slider:SetPoint("TOPLEFT", 60, -205);

	g_MouseHairsOptPanel.slider:SetScript("OnValueChanged", function(self, value)
		MouseHairsOpt.pulseSize = value;
		ShowCircle(1);
	end);


	-- STARTING ALPHA VALUE
	g_MouseHairsOptPanel.slider = createSlider("Starting alpha value", 160, 15, 0, 255, 1);
	g_MouseHairsOptPanel.slider:SetValue(MouseHairsOpt.startingAlphaValue * 255);
	g_MouseHairsOptPanel.slider:SetPoint("TOPLEFT", 60, -255);

	g_MouseHairsOptPanel.slider:SetScript("OnValueChanged", function(self, value)
		MouseHairsOpt.startingAlphaValue = value / 255;
		ShowCircle(1);
	end);


	-- STARTING ALPHA VALUE
	g_MouseHairsOptPanel.slider = createSlider("Line alpha value", 160, 15, 0, 255, 1);
	g_MouseHairsOptPanel.slider:SetValue(MouseHairsOpt.lineAlphaValue * 255);
	g_MouseHairsOptPanel.slider:SetPoint("TOPLEFT", 60, -305);

	g_MouseHairsOptPanel.slider:SetScript("OnValueChanged", function(self, value)
		MouseHairsOpt.lineAlphaValue = value / 255;
		ShowCircle(1);
	end);


	-- COLOR
	g_MouseHairsOptPanel.lab = createLabel("Color");
	g_MouseHairsOptPanel.lab:SetPoint("TOPLEFT", 90, -350);
	g_MouseHairsOptPanel.clr = createColorSelect("ColorSelect");
	g_MouseHairsOptPanel.clr:SetPoint("TOPLEFT", 60, -335);


	g_MouseHairsOptPanel.helpText = createLabel("You can Keybind or macro /pulse to Pulse Manually");
	g_MouseHairsOptPanel.helpText:SetPoint("TOPLEFT", 60, -375);

    if InterfaceOptions_AddCategory then
		InterfaceOptions_AddCategory(g_MouseHairsOptPanel.panel)
	else
		local category, layout = _G.Settings.RegisterCanvasLayoutCategory(g_MouseHairsOptPanel.panel, g_MouseHairsOptPanel.panel.name, g_MouseHairsOptPanel.panel.name)
		_G.Settings.RegisterAddOnCategory(category)
	end
end
