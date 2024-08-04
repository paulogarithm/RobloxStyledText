--!strict
--!optimize 2

local TextService = game:GetService("TextService")

local rshift = bit32.rshift
local band = bit32.band

local CLASSIC_COLOR_NAME = "Medium stone grey"
local CLASSIC_COLOR = BrickColor.new(CLASSIC_COLOR_NAME)

local StyledClass = {}
local Styled = {}
local _M_Styled = { __index = Styled }

export type TextBase = TextLabel
export type StyledText = STObject

type STPattern = {
	pattern: string,
	func: (STObject, string, string) -> Color3?
}

type STToken = {
	color: Color3,
	text: string,
	instance: TextLabel
}

type STObject = typeof(setmetatable(
	{} :: {
		source: TextBase,
		_copy: TextBase,
		_currentLexer: STLexer,
		_realText: string
	},
	_M_Styled)
)

type STLexer = {STToken}

-- private

@native
local function hexToColor(str: string): Color3?
	local num = tonumber(str, 16)

	if (not num) then
		return nil
	end
	return if (#str == 3) then
		Color3.new(
			rshift(num, 8) / 0xF,
			band(rshift(num, 4), 0xF) / 0xF,
			band(num, 0xF) / 0xF
		)
		else
		Color3.fromRGB(
			rshift(num, 16),
			band(rshift(num, 8), 0xFF),
			band(num, 0xFF)
		)
end

@native
local function capitalize(str: string)
	return string.upper(string.sub(str, 1, 1)) ..
		string.lower(string.sub(str, 2))
end

local function fromHexa(self, col: string, rest: string): Color3?
	return (hexToColor(col))
end

local function fromBrickColor(self, col: string, rest: string): Color3?
	local func, brick

	col = capitalize(col)
	func = BrickColor[col]
	if (func) then 
		return func().Color
	end
	brick = BrickColor.new(col)
	if (brick ~= CLASSIC_COLOR) or (col == CLASSIC_COLOR_NAME) then
		return brick.Color
	end 
	return nil
end

local PATTERNS: {STPattern} = {
	{
		func = fromHexa,
		pattern = "%[#([0-9a-fA-F]+)%](.+)"
	},
	{
		func = fromBrickColor,
		pattern = "%[([%a%s]+)%](.+)"
	}
}

local function getColorAndText
(self: STObject, str: string): (Color3?, string)
	local a, b

	for _, pattern in next, PATTERNS do
		a, b = string.match(str, pattern.pattern)
		if (a and b) then
			return pattern.func(self, a, b), b
		end
	end
	return self._copy.TextColor3, str
end

local function getLexer(self: STObject, str: string): STLexer
	local split = string.split(str, "&")
	local lexer: STLexer = {}
	local a, b
	local text = ""

	for _, word in next, split do
		if (word == "") then
			continue
		end
		a, b = getColorAndText(self, word)
		table.insert(lexer, {
			color = a or self._copy.TextColor3,
			text = b,
			instance = Instance.new("TextLabel")
		})
		text ..= b
	end
	self._currentLexer = lexer
	self._realText = text
	return lexer
end

local function setupInstance(self: STObject, e: STToken)
	e.instance.Text = e.text
	e.instance.TextColor3 = e.color
	e.instance.AnchorPoint = Vector2.new(0, .5)
	e.instance.TextSize = self._copy.TextSize
	e.instance.BackgroundTransparency = 1
	e.instance.FontFace = self._copy.FontFace
	e.instance.TextXAlignment = Enum.TextXAlignment.Center
	e.instance.Parent = self.source
end

local function buildLabels(self: STObject)
	local TEXT_BOUNDS = TextService:GetTextSize(
		self._realText, self._copy.TextSize,
		self._copy.Font, self._copy.AbsoluteSize
	)
	local TEXT_START_POS =  self._copy.AbsoluteSize.X/2 - TEXT_BOUNDS.X/2
	local sizeScroll = 0
	local size

	for _, e in next, self._currentLexer do
		size = TextService:GetTextSize(
			e.text, self._copy.TextSize,
			self._copy.Font, self._copy.AbsoluteSize
		).X
		e.instance.Size = UDim2.new(0, size, 1, 0)
		e.instance.Position = UDim2.new(
			0, sizeScroll + TEXT_START_POS, .5, 0)
		setupInstance(self, e)
		sizeScroll += size
	end
end

local function clearLexer(self: STObject)
	for _, e in next, self._currentLexer do
		e.instance:Destroy()
	end
	self._currentLexer = {}
end

local function start(self: STObject)
	self.source.Text = ""
	self:update(self._copy.Text)
end

-- object

function Styled:unload()
	self._copy.Parent = self.source.Parent
	self.source:Destroy()
end

function Styled:update(text: string)
	clearLexer(self)
	getLexer(self, text)
	buildLabels(self)
end

-- class

function StyledClass.load(text: TextBase): StyledText
	local self
	local object = {
		source = text,
		_copy = text:Clone(),
		_currentLexer = {},
		_realText = text.Text
	}

	object._copy.Parent = nil
	self = setmetatable(object, _M_Styled)
	start(self)
	return self
end

return StyledClass
