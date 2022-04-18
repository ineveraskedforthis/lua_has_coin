local InvestmentBlock = {}
InvestmentBlock.__index = InvestmentBlock

function InvestmentBlock:new(parent, label, it, height, width, treas_flag)
    local _ = milky.panel
        :new(milky, parent)
        :size(width, height)

    local label = milky.panel:new(milky, _, label)
        :position(2, 0)
        :size(80, height)
        :center_text_vertically()

    _.value = milky.panel
        :new(milky, _, '???')
        :position(120, 0)
        :size(35, height)
        :center_text_vertically()
    if not treas_flag then
        local bd = milky.panel:new(milky, _, "-")
            :position(90, 0)
            :size(height, height)
            :button(milky, function (self, button) castle:dec_inv(it) end)
            :toggle_border()
            :toggle_background()
            :center_text()
        local bi = milky.panel:new(milky, _, "+")
            :position(160, 0)
            :size(height, height)
            :button(milky, function (self, button) castle:inc_inv(it) end)
            :toggle_border()
            :toggle_background()
            :center_text()
    end
    return _
end


return InvestmentBlock