local InvestmentBlock = require "modules.UI.Investment_Block"

local InvestmentWidget = {}
InvestmentWidget.__index = InvestmentWidget

function InvestmentWidget:new(parent, x, y, width, label_padding_left)
    local block_height = 16
    local pad = 3
    local _ = {}
    _.body = milky.panel
        :new(milky, parent)
        :position(x, y)
        :size(192, 100)
        :toggle_border()
    local income_invest_label = milky.panel
        :new(milky, _.body, 'ROYAL INVESTMENTS')
        :position(label_padding_left, pad)
        :size(block_height, width)

    _.treasury_invest = InvestmentBlock
        :new(_.body, "TREASURY", "treasury", block_height, width, true)
        :position(pad, pad + block_height + pad)

    _.hunt_invest = InvestmentBlock
        :new(_.body, "HUNT", "hunt", block_height, width)
        :position(pad, pad + block_height + pad + block_height + pad)

    setmetatable(_, InvestmentWidget)
    return _
end

function InvestmentWidget:update()
    
    self.hunt_invest.value:update_label(tostring(castle.budget.hunt) .. '%')
    self.treasury_invest.value:update_label(tostring(castle.budget.treasury) .. '%')
end

return InvestmentWidget