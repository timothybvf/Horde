if SERVER then return end
surface.CreateFont('Title', { font = 'arial', size = 30 })
surface.CreateFont('Content', { font = 'arial', size = 19 })

local PANEL = {}

function PANEL:Init()
	self.description = ""
    self.buy_btn = vgui.Create('DButton', self)
	self.buy_btn:Dock(BOTTOM)
    self.buy_btn:SetFont("Content")
    self.buy_btn:SetTextColor(Color(0,0,0,0))
	self.buy_btn:SetText("")
    self.buy_btn:SetTall(50)
    self.buy_btn.Paint = function () end

    self.ammo_panel = vgui.Create('DPanel', self)
	self.ammo_panel:Dock(BOTTOM)
    self.ammo_panel:SetTall(50)

    self.ammo_one_btn = vgui.Create('DButton', self.ammo_panel)
	self.ammo_one_btn:Dock(LEFT)
    self.ammo_one_btn:SetFont("Content")
    self.ammo_one_btn:SetTextColor(Color(0,0,0,0))
	self.ammo_one_btn:SetText("")

    self.ammo_ten_btn = vgui.Create('DButton', self.ammo_panel)
    self.ammo_ten_btn:Dock(LEFT)
    self.ammo_ten_btn:SetFont("Content")
    self.ammo_ten_btn:SetTextColor(Color(0,0,0,0))
    self.ammo_ten_btn:SetText("")
    self.ammo_ten_btn:SetTall(50)

    self.ammo_panel.Paint = function () end
    self.ammo_one_btn.Paint = function () end
    self.ammo_ten_btn.Paint = function () end

    function self.buy_btn:DoClick()
		self:GetParent():DoClick()
	end

    function self.ammo_one_btn:DoClick()
        self:GetParent():GetParent():AmmoDoClick(1)
    end

    function self.ammo_ten_btn:DoClick()
        self:GetParent():GetParent():AmmoDoClick(10)
    end
end

function PANEL:DoClick()
    if not self.item then return end
    if not self.item.class then
		Derma_Query('Changing class will remove all your items!', 'Change Class',
			'Yes',
            function()
                net.Start("Horde_SelectClass")
                net.WriteString(self.item.name)
                net.SendToServer()
            end,
			'No', function() end
		)
        return
    end
    if LocalPlayer():GetMoney() < self.item.price or LocalPlayer():GetWeight() < self.item.weight then return end
    -- Buy the item
    net.Start("Horde_BuyItem")
    net.WriteString(self.item.class)
    net.WriteInt(self.item.price, 16)
    net.WriteInt(self.item.weight, 16)
    net.SendToServer()
end

function PANEL:AmmoDoClick(count)
    if not self.item then return end
    local price = self.item.ammo_price and self.item.ammo_price or HORDE.default_ammo_price
    price = price * count
    if LocalPlayer():GetMoney() < price then return end
    -- Buy the item
    net.Start("Horde_BuyItemAmmoPrimary")
    net.WriteString(self.item.class)
    net.WriteInt(price,16)
    net.WriteInt(count,16)
    net.SendToServer()
end

function PANEL:SetData(item)
	self.item = item
end

function PANEL:Paint()
	surface.SetDrawColor(Color(50,50,50))
	surface.DrawRect(0, 0, self:GetWide(), self:GetTall())
    if self.item then
        draw.DrawText(self.item.name, "Title", self:GetWide() / 2, 32, Color(255, 255, 255), TEXT_ALIGN_CENTER)
        draw.DrawText(self.item.description, "Content", 50, 80, Color(200, 200, 200), TEXT_ALIGN_LEFT)
        
        -- Check if this is a class or an item
        if not self.item.class then 
            self.buy_btn:SetTextColor(Color(255,255,255))
            self.buy_btn:SetText("Select Class")
            self.buy_btn.Paint = function ()
                surface.SetDrawColor(HORDE.color_crimson)
                surface.DrawRect(0, 0, self:GetWide(), 200)
            end
            return
        end
        
        if LocalPlayer():HasWeapon(self.item.class) then
            self.buy_btn:SetTextColor(Color(255,255,255))
            self.buy_btn:SetText("OWNED")
            self.buy_btn.Paint = function ()
                surface.SetDrawColor(Color(40,40,40))
                surface.DrawRect(0, 0, self:GetWide(), 200)
            end
            
            if self.item.category ~= "Melee" and self.item.category ~= "Equipment" then
                self.ammo_one_btn:SetFont("Content")
                self.ammo_one_btn:SetTextColor(Color(255,255,255))
                local price = self.item.ammo_price and self.item.ammo_price or HORDE.default_ammo_price
                self.ammo_one_btn:SetText("Buy Ammo x 1 (" .. tostring(price) .. "$)")
                self.ammo_one_btn:SetWide(self:GetWide() / 2)
                self.ammo_one_btn.Paint = function ()
                    surface.SetDrawColor(HORDE.color_crimson)
                    surface.DrawRect(0, 0, self:GetParent():GetParent():GetWide()/2, 200)
                end

                self.ammo_ten_btn:SetFont("Content")
                self.ammo_ten_btn:SetTextColor(Color(255,255,255))
                self.ammo_ten_btn:SetText("Buy Ammo x 10 (" .. tostring(price * 10) .. "$)")
                self.ammo_ten_btn:SetWide(self:GetWide() / 2)
                self.ammo_ten_btn.Paint = function ()
                    surface.SetDrawColor(HORDE.color_crimson)
                    surface.DrawRect(0, 0, self:GetParent():GetParent():GetWide()/2, 200)
                end
            else
                self.ammo_one_btn.Paint = function () end
                self.ammo_ten_btn.Paint = function () end
            end
        elseif LocalPlayer():GetMoney() < self.item.price or LocalPlayer():GetWeight() < self.item.weight then
            self.buy_btn:SetTextColor(Color(200,200,200))
            self.buy_btn:SetText("Not Enough Money or Carrying Capacity!")
            self.buy_btn.Paint = function ()
                surface.SetDrawColor(Color(100,0,0))
                surface.DrawRect(0, 0, self:GetWide(), 200)
            end

            self.ammo_one_btn:SetText("")
            self.ammo_ten_btn:SetText("")
            self.ammo_one_btn.Paint = function () end
            self.ammo_ten_btn.Paint = function () end
        else
            self.buy_btn:SetTextColor(Color(255,255,255))
            self.buy_btn:SetText("Buy Weapon")
            self.buy_btn.Paint = function ()
                surface.SetDrawColor(HORDE.color_crimson)
                surface.DrawRect(0, 0, self:GetWide(), 200)
            end
            
            self.ammo_one_btn:SetText("")
            self.ammo_ten_btn:SetText("")
            self.ammo_one_btn.Paint = function () end
            self.ammo_ten_btn.Paint = function () end
        end
    end

end

vgui.Register('HordeDescription', PANEL, 'DPanel')