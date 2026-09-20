-- VozoidUI v2
-- Lightweight Roblox UI library. The module intentionally ends with: return Library
local UIS = game:GetService("UserInputService")
local TS = game:GetService("TweenService")
local Players = game:GetService("Players")

local T = {
    Bg = Color3.fromRGB(18, 16, 20), Panel = Color3.fromRGB(26, 22, 30),
    Section = Color3.fromRGB(34, 28, 40), Row = Color3.fromRGB(28, 24, 34),
    Stroke = Color3.fromRGB(48, 40, 56), Accent = Color3.fromRGB(255, 130, 200),
    Text = Color3.fromRGB(230, 225, 235), TextDim = Color3.fromRGB(140, 130, 150),
    Font = Enum.Font.Gotham, FontBold = Enum.Font.GothamBold, FontMono = Enum.Font.Code,
}
local Library = { Flags = {}, Items = {}, Theme = T, ScreenGui = nil, Version = "2.0.0" }

local function new(class, props, parent)
    local x = Instance.new(class)
    for k, v in pairs(props or {}) do x[k] = v end
    if parent then x.Parent = parent end
    return x
end
local function corner(x, r) new("UICorner", { CornerRadius = UDim.new(0, r or 4) }, x) end
local function stroke(x, c, n) new("UIStroke", { Color = c or T.Stroke, Thickness = n or 1 }, x) end
local function padding(x, t, r, b, l)
    new("UIPadding", { PaddingTop = UDim.new(0,t or 0), PaddingRight = UDim.new(0,r or 0), PaddingBottom = UDim.new(0,b or 0), PaddingLeft = UDim.new(0,l or 0) }, x)
end
local function play(x, props, duration)
    if x and x.Parent then TS:Create(x, TweenInfo.new(duration or .12, Enum.EasingStyle.Quad), props):Play() end
end
local function callback(fn, ...)
    if type(fn) ~= "function" then return end
    local ok, err = pcall(fn, ...)
    if not ok then warn("[vozoid] callback error:", err) end
end
local function number(v, fallback) return type(v) == "number" and v == v and v or fallback end

local sg = new("ScreenGui", { Name = "VozoidUI", ResetOnSpawn = false, ZIndexBehavior = Enum.ZIndexBehavior.Global })
pcall(function() sg.Parent = (gethui and gethui()) or game:GetService("CoreGui") end)
if not sg.Parent then sg.Parent = Players.LocalPlayer:WaitForChild("PlayerGui") end
Library.ScreenGui = sg

function Library:SetTheme(theme)
    for k, v in pairs(theme or {}) do if T[k] ~= nil then T[k] = v end end
    return self
end
function Library:GetFlag(flag, fallback) local v = self.Flags[flag]; return v == nil and fallback or v end
function Library:SetFlag(flag, value)
    local item = self.Items[flag]
    if item and item.Set then item:Set(value) else self.Flags[flag] = value end
end

local function picker(anchor, initial, onChange)
    local popup = new("Frame", { Size = UDim2.fromOffset(176, 138), BackgroundColor3 = T.Panel, BorderSizePixel = 0, ZIndex = 500, Parent = sg })
    local p = anchor.AbsolutePosition; popup.Position = UDim2.fromOffset(p.X, p.Y + anchor.AbsoluteSize.Y + 4)
    corner(popup, 6); stroke(popup)
    local sat = new("ImageLabel", { Size = UDim2.fromOffset(132, 88), Position = UDim2.fromOffset(8,8), BackgroundColor3 = initial, BorderSizePixel = 0, Image = "rbxassetid://4155801252", ZIndex = 501, Parent = popup }); corner(sat,4)
    local hue = new("Frame", { Size = UDim2.fromOffset(20,88), Position = UDim2.fromOffset(148,8), BorderSizePixel = 0, ZIndex = 501, Parent = popup }); corner(hue,4)
    new("UIGradient", { Rotation = 90, Color = ColorSequence.new({ ColorSequenceKeypoint.new(0,Color3.new(1,0,0)), ColorSequenceKeypoint.new(.17,Color3.new(1,1,0)), ColorSequenceKeypoint.new(.33,Color3.new(0,1,0)), ColorSequenceKeypoint.new(.5,Color3.new(0,1,1)), ColorSequenceKeypoint.new(.67,Color3.new(0,0,1)), ColorSequenceKeypoint.new(.83,Color3.new(1,0,1)), ColorSequenceKeypoint.new(1,Color3.new(1,0,0)) }) }, hue)
    local h,s,v = initial:ToHSV()
    local cs = new("Frame", { Size=UDim2.fromOffset(8,8), AnchorPoint=Vector2.new(.5,.5), Position=UDim2.fromScale(s,1-v), BackgroundColor3=Color3.new(1,1,1), ZIndex=502, Parent=sat }); corner(cs,4)
    local ch = new("Frame", { Size=UDim2.new(1,2,0,3), AnchorPoint=Vector2.new(.5,.5), Position=UDim2.fromScale(.5,h), BackgroundColor3=Color3.new(1,1,1), ZIndex=502, Parent=hue)
    local function update() sat.BackgroundColor3=Color3.fromHSV(h,1,1); callback(onChange,Color3.fromHSV(h,s,v)) end
    local dragging
    local function drag(target, fn)
        target.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then dragging=fn; fn() end end)
    end
    drag(sat,function() local m=UIS:GetMouseLocation(); s=math.clamp((m.X-sat.AbsolutePosition.X)/sat.AbsoluteSize.X,0,1); v=1-math.clamp((m.Y-sat.AbsolutePosition.Y)/sat.AbsoluteSize.Y,0,1); cs.Position=UDim2.fromScale(s,1-v); update() end)
    drag(hue,function() local m=UIS:GetMouseLocation(); h=math.clamp((m.Y-hue.AbsolutePosition.Y)/hue.AbsoluteSize.Y,0,1); ch.Position=UDim2.fromScale(.5,h); update() end)
    local move = UIS.InputChanged:Connect(function(i) if dragging and i.UserInputType==Enum.UserInputType.MouseMovement then dragging() end end)
    local ended = UIS.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then dragging=nil end end)
    local outside = UIS.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then local m=UIS:GetMouseLocation(); local q,z=popup.AbsolutePosition,popup.AbsoluteSize; if m.X<q.X or m.X>q.X+z.X or m.Y<q.Y or m.Y>q.Y+z.Y then popup:Destroy(); move:Disconnect(); ended:Disconnect(); outside:Disconnect() end end end)
    update()
end

function Library:Window(cfg)
    cfg=cfg or {}; local win={Tabs={},ActiveTab=nil}; local connections={}
    local root=new("Frame",{Name="Window",Size=cfg.Size or UDim2.fromOffset(620,500),Position=UDim2.fromScale(.5,.5),AnchorPoint=Vector2.new(.5,.5),BackgroundColor3=T.Bg,BorderSizePixel=0,Active=true,Draggable=true,ZIndex=1,Parent=sg}); corner(root,6); stroke(root)
    local title=new("Frame",{Size=UDim2.new(1,0,0,28),BackgroundColor3=T.Panel,BorderSizePixel=0,ZIndex=2,Parent=root}); corner(title,6)
    new("Frame",{Size=UDim2.new(1,0,0,8),Position=UDim2.new(0,0,1,-8),BackgroundColor3=T.Panel,BorderSizePixel=0,ZIndex=2,Parent=title})
    new("TextLabel",{Text=cfg.Name or "vozoid ui",Font=T.FontBold,TextSize=12,TextColor3=T.Text,BackgroundTransparency=1,Position=UDim2.fromOffset(10,0),Size=UDim2.new(1,-60,1,0),TextXAlignment=Enum.TextXAlignment.Left,ZIndex=3,Parent=title})
    local close=new("TextButton",{Text="X",Font=T.FontBold,TextSize=14,TextColor3=T.TextDim,BackgroundTransparency=1,Size=UDim2.fromOffset(24,28),Position=UDim2.new(1,-28,0,0),ZIndex=3,Parent=title}); close.MouseButton1Click:Connect(function() win:Close() end)
    local tabs=new("Frame",{Size=UDim2.new(1,0,0,26),Position=UDim2.fromOffset(0,28),BackgroundColor3=T.Panel,BorderSizePixel=0,ZIndex=2,Parent=root}); padding(tabs,0,0,0,6); new("UIListLayout",{FillDirection=Enum.FillDirection.Horizontal,VerticalAlignment=Enum.VerticalAlignment.Center},tabs)
    local content=new("Frame",{Size=UDim2.new(1,0,1,-54),Position=UDim2.fromOffset(0,54),BackgroundTransparency=1,ClipsDescendants=true,ZIndex=2,Parent=root})
    function win:Tab(name)
        local tab={Name=name}; table.insert(win.Tabs,tab)
        local btn=new("TextButton",{Text=name,Font=T.Font,TextSize=12,TextColor3=T.TextDim,BackgroundTransparency=1,Size=UDim2.fromOffset(72,26),LayoutOrder=#win.Tabs,ZIndex=3,Parent=tabs})
        local line=new("Frame",{Size=UDim2.new(1,0,0,2),Position=UDim2.new(0,0,1,-2),BackgroundColor3=T.Accent,Visible=false,ZIndex=3,Parent=btn})
        local page=new("Frame",{Size=UDim2.fromScale(1,1),BackgroundTransparency=1,Visible=false,ZIndex=3,Parent=content})
        local function col(pos, right)
            local f=new("ScrollingFrame",{Size=UDim2.new(.5,-6,1,0),Position=pos,BackgroundTransparency=1,BorderSizePixel=0,ScrollBarThickness=2,ScrollBarImageColor3=T.Stroke,AutomaticCanvasSize=Enum.AutomaticSize.Y,CanvasSize=UDim2.new(),ZIndex=3,Parent=page}); padding(f,6,right and 6 or 3,6,right and 3 or 6); new("UIListLayout",{Padding=UDim.new(0,6),SortOrder=Enum.SortOrder.LayoutOrder},f); return f end
        local left,right=col(UDim2.new(0,0,0,0),false),col(UDim2.new(.5,3,0,0),true); tab.Left,tab.Right=left,right; tab.Button,tab.Page,tab.Underline=btn,page,line
        local function select() if win.ActiveTab then win.ActiveTab.Page.Visible=false; win.ActiveTab.Button.TextColor3=T.TextDim; win.ActiveTab.Underline.Visible=false end; win.ActiveTab=tab; page.Visible=true; btn.TextColor3=T.Text; line.Visible=true end
        btn.MouseButton1Click:Connect(select); if not win.ActiveTab then select() end
        function tab:Section(name, side)
            local box=new("Frame",{Size=UDim2.new(1,0,0,0),AutomaticSize=Enum.AutomaticSize.Y,BackgroundColor3=T.Section,BorderSizePixel=0,ZIndex=4,Parent=(side=="Right" and right or left)}); corner(box,5); stroke(box)
            local head=new("TextLabel",{Text=name,Font=T.FontBold,TextSize=11,TextColor3=T.Text,BackgroundColor3=T.Row,BorderSizePixel=0,Size=UDim2.new(1,0,0,20),TextXAlignment=Enum.TextXAlignment.Left,ZIndex=5,Parent=box}); corner(head,5); padding(head,0,8,0,8)
            local body=new("Frame",{Position=UDim2.fromOffset(0,22),Size=UDim2.new(1,0,0,0),AutomaticSize=Enum.AutomaticSize.Y,BackgroundTransparency=1,ZIndex=5,Parent=box}); padding(body,4,6,6,6); new("UIListLayout",{Padding=UDim.new(0,4),SortOrder=Enum.SortOrder.LayoutOrder},body)
            local sec={Items={}}
            local function row(height) return new("Frame",{Size=UDim2.new(1,0,0,height),BackgroundTransparency=1,ZIndex=6,Parent=body}) end
            local function register(item) Library.Items[item.Flag]=item; table.insert(sec.Items,item); return item end
            function sec:Toggle(o) o=o or {}; local flag=o.Flag or o.Name or "Toggle"; local val=o.Default==true; Library.Flags[flag]=val; local r=row(18); local label=new("TextLabel",{Text=o.Name or "Toggle",Font=T.Font,TextSize=11,TextColor3=val and T.Text or T.TextDim,BackgroundTransparency=1,Position=UDim2.fromOffset(22,0),Size=UDim2.new(1,-22,1,0),TextXAlignment=Enum.TextXAlignment.Left,Parent=r}); local mark=new("Frame",{Size=UDim2.fromOffset(14,14),Position=UDim2.new(0,0,.5,-7),BackgroundColor3=val and T.Accent or T.Row,BorderSizePixel=0,Parent=r}); corner(mark,3); stroke(mark); local hit=new("TextButton",{Text="",BackgroundTransparency=1,Size=UDim2.fromScale(1,1),Parent=r}); local item={Name=o.Name,Flag=flag,Value=val}; function item:Set(v,quiet) val=not not v; item.Value=val; Library.Flags[flag]=val; mark.BackgroundColor3=val and T.Accent or T.Row; label.TextColor3=val and T.Text or T.TextDim; if not quiet then callback(o.Callback,val) end end; hit.MouseButton1Click:Connect(function() item:Set(not val) end); return register(item) end
            function sec:Slider(o) o=o or {}; local flag=o.Flag or o.Name or "Slider"; local min=number(o.Min,0); local max=number(o.Max,100); if max<=min then max=min+1 end; local dec=math.max(0,math.floor(number(o.Decimals,0))); local val=math.clamp(number(o.Default,min),min,max); local r=row(30); new("TextLabel",{Text=o.Name or "Slider",Font=T.Font,TextSize=11,TextColor3=T.Text,BackgroundTransparency=1,Size=UDim2.new(1,-52,0,13),TextXAlignment=Enum.TextXAlignment.Left,Parent=r}); local input=new("TextBox",{Text=tostring(val),Font=T.FontMono,TextSize=10,TextColor3=T.Text,BackgroundColor3=T.Row,BorderSizePixel=0,Size=UDim2.fromOffset(48,14),Position=UDim2.new(1,-48,0,0),TextXAlignment=Enum.TextXAlignment.Center,Parent=r}); corner(input,2); stroke(input); local bar=new("Frame",{Size=UDim2.new(1,0,0,6),Position=UDim2.fromOffset(0,20),BackgroundColor3=T.Row,BorderSizePixel=0,Parent=r}); corner(bar,3); local fill=new("Frame",{BackgroundColor3=T.Accent,BorderSizePixel=0,Parent=bar}); corner(fill,3)
                local function set(v,quiet) v=math.clamp(number(v,val),min,max); local p=10^dec; v=dec>0 and math.floor(v*p+.5)/p or math.floor(v+.5); val=v; Library.Flags[flag]=v; input.Text=tostring(v); fill.Size=UDim2.new((v-min)/(max-min),0,1,0); if not quiet then callback(o.Callback,v) end end
                set(val,true); local dragging=false; bar.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then dragging=true end end); local mc=UIS.InputChanged:Connect(function(i) if dragging and i.UserInputType==Enum.UserInputType.MouseMovement then local m=UIS:GetMouseLocation(); set(min+math.clamp((m.X-bar.AbsolutePosition.X)/bar.AbsoluteSize.X,0,1)*(max-min)) end end); local ec=UIS.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then dragging=false end end); table.insert(connections,mc); table.insert(connections,ec); input.FocusLost:Connect(function() set(tonumber(input.Text) or val) end); local item={Name=o.Name,Flag=flag,Value=val}; function item:Set(v,quiet) set(v,quiet); item.Value=val end; return register(item) end
            function sec:Dropdown(o) o=o or {}; local flag=o.Flag or o.Name or "Dropdown"; local values=o.Values or {}; local val=o.Default; if val==nil then val=values[1] end; Library.Flags[flag]=val; local r=row(18); local button=new("TextButton",{Text=tostring(val or ""),Font=T.Font,TextSize=11,TextColor3=T.Text,BackgroundColor3=T.Row,BorderSizePixel=0,Size=UDim2.fromScale(1,1),TextXAlignment=Enum.TextXAlignment.Left,Parent=r}); corner(button,3); stroke(button); padding(button,0,6,0,6); local list=new("Frame",{Visible=false,Position=UDim2.fromOffset(0,20),Size=UDim2.new(1,0,0,0),BackgroundColor3=T.Section,BorderSizePixel=0,ZIndex=50,Parent=r}); corner(list,3); stroke(list); local open=false; local function rebuild() for _,c in ipairs(list:GetChildren()) do if c:IsA("TextButton") then c:Destroy() end end; for i,v in ipairs(values) do local b=new("TextButton",{Text=tostring(v),Font=T.Font,TextSize=11,TextColor3=v==val and T.Accent or T.Text,BackgroundColor3=T.Section,BorderSizePixel=0,Size=UDim2.new(1,0,0,16),LayoutOrder=i,ZIndex=51,Parent=list}); padding(b,0,4,0,4); b.TextXAlignment=Enum.TextXAlignment.Left; b.MouseButton1Click:Connect(function() val=v; Library.Flags[flag]=v; button.Text=tostring(v); open=false; list.Visible=false; rebuild(); callback(o.Callback,v) end) end; list.Size=UDim2.new(1,0,0,math.min(#values,6)*17+8) end; rebuild(); button.MouseButton1Click:Connect(function() open=not open; list.Visible=open end); local item={Name=o.Name,Flag=flag,Value=val}; function item:Set(v,quiet) val=v; item.Value=v; Library.Flags[flag]=v; button.Text=tostring(v); rebuild(); if not quiet then callback(o.Callback,v) end end; function item:Refresh(v) values=v or {}; rebuild() end; return register(item) end
            function sec:Input(o) o=o or {}; local flag=o.Flag or o.Name or "Input"; local val=o.Default or ""; Library.Flags[flag]=val; local r=row(18); local input=new("TextBox",{Text=val,PlaceholderText=o.Placeholder or "",Font=T.Font,TextSize=11,TextColor3=T.Text,PlaceholderColor3=T.TextDim,BackgroundColor3=T.Row,BorderSizePixel=0,Size=UDim2.fromScale(1,1),TextXAlignment=Enum.TextXAlignment.Left,Parent=r}); corner(input,3); stroke(input); padding(input,0,6,0,6); local item={Name=o.Name,Flag=flag,Value=val}; function item:Set(v,quiet) val=tostring(v or ""); item.Value=val; Library.Flags[flag]=val; input.Text=val; if not quiet then callback(o.Callback,val) end end; input.FocusLost:Connect(function() item:Set(input.Text) end); return register(item) end
            function sec:Button(o) o=o or {}; local b=new("TextButton",{Text=o.Name or "Button",Font=T.Font,TextSize=11,TextColor3=T.Text,BackgroundColor3=T.Row,BorderSizePixel=0,Size=UDim2.new(1,0,0,20),Parent=body}); corner(b,3); stroke(b); b.MouseEnter:Connect(function() play(b,{BackgroundColor3=T.Accent}) end); b.MouseLeave:Connect(function() play(b,{BackgroundColor3=T.Row}) end); b.MouseButton1Click:Connect(function() callback(o.Callback) end); return b end
            function sec:Label(text) return new("TextLabel",{Text=text or "",Font=T.Font,TextSize=11,TextColor3=T.TextDim,BackgroundTransparency=1,Size=UDim2.new(1,0,0,18),TextXAlignment=Enum.TextXAlignment.Left,Parent=body}) end
            function sec:ColorPicker(o) o=o or {}; local flag=o.Flag or o.Name or "Color"; local val=o.Default or T.Accent; Library.Flags[flag]=val; local r=row(20); local b=new("TextButton",{Text=o.Name or "Color",Font=T.Font,TextSize=11,TextColor3=T.Text,BackgroundColor3=T.Row,BorderSizePixel=0,Size=UDim2.new(1,0,0,20),TextXAlignment=Enum.TextXAlignment.Left,Parent=r}); padding(b,0,30,0,6); local sw=new("Frame",{Size=UDim2.fromOffset(18,14),Position=UDim2.new(1,-22,.5,-7),BackgroundColor3=val,BorderSizePixel=0,Parent=b}); corner(sw,3); local item={Name=o.Name,Flag=flag,Value=val}; function item:Set(v,quiet) if typeof(v)=="Color3" then val=v; item.Value=v; Library.Flags[flag]=v; sw.BackgroundColor3=v; if not quiet then callback(o.Callback,v) end end end; b.MouseButton1Click:Connect(function() picker(b,val,function(v) item:Set(v) end) end); return register(item) end
            function sec:Keybind(o) o=o or {}; local flag=o.Flag or o.Name or "Keybind"; local key=o.Default or Enum.KeyCode.F; Library.Flags[flag]=key; local r=row(18); new("TextLabel",{Text=o.Name or "Keybind",Font=T.Font,TextSize=11,TextColor3=T.Text,BackgroundTransparency=1,Size=UDim2.new(1,-50,1,0),TextXAlignment=Enum.TextXAlignment.Left,Parent=r}); local b=new("TextButton",{Text=key.Name,Font=T.FontMono,TextSize=10,TextColor3=T.Text,BackgroundColor3=T.Row,BorderSizePixel=0,Size=UDim2.fromOffset(48,14),Position=UDim2.new(1,-48,.5,-7),Parent=r}); corner(b,3); stroke(b); local listening=false; local item={Name=o.Name,Flag=flag,Value=key}; function item:Set(v,quiet) if typeof(v)=="EnumItem" then key=v; item.Value=v; Library.Flags[flag]=v; b.Text=v.Name; if not quiet then callback(o.Callback,v) end end end; b.MouseButton1Click:Connect(function() if listening then return end; listening=true; b.Text="..." end); local c=UIS.InputBegan:Connect(function(i,p) if p then return end; if listening and i.UserInputType==Enum.UserInputType.Keyboard then listening=false; item:Set(i.KeyCode); elseif not listening and i.KeyCode==key then callback(o.Callback,key) end end); table.insert(connections,c); return register(item) end
            return sec
        end
        return tab
    end
    function win:Close() sg.Enabled=false end
    function win:Open() sg.Enabled=true end
    function win:Destroy() for _,c in ipairs(connections) do pcall(function() c:Disconnect() end) end; if root.Parent then root:Destroy() end end
    return win
end

local toggleConn=UIS.InputBegan:Connect(function(i,p) if not p and i.KeyCode==Enum.KeyCode.RightShift then sg.Enabled=not sg.Enabled end end)
Library.ToggleKeyConnection=toggleConn
return Library
