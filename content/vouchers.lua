SMODS.Voucher {
    key = 'RoyalEmblem',
    loc_txt = {
        name = 'Royal Emblem',
        text = { 'Modded {C:attention}Face{} cards give {C:abn_eternal}+#1#{} Amperage when scored' }
    },
    atlas = 'Vouchers',
    pos = {
        x = 0,
        y = 0,
    },
    config = {
        extra = {
            amp = 0.25,
        }
    },
    loc_vars = function(self, info_queue, card)
        return {
            vars = { (card.ability.extra.amp) }
        }
    end,

    calculate = function(self, card, context)
        if context.individual and context.cardarea == G.play and context.other_card:is_face() and not ABN.is_number(context.other_card) and not context.other_card:is_suit("Hearts") and not context.other_card:is_suit("Spades") and not context.other_card:is_suit("Diamonds") and not context.other_card:is_suit("Clubs") then
			return {
                amp = card.ability.extra.amp,
                card = card,
            }
        end
    end,
    
    abn_artist_credits = {
        artist = "0kronix",
    },
}

SMODS.Voucher {
    key = 'EmperorSigil',
    loc_txt = {
        name = 'Emperor Sigil',
        text = { 'Modded rank {C:attention}Face{} cards give {C:abn_eternal}+#1#{} Amperage when scored' }
    },
    atlas = 'Vouchers',
	requires = { 'v_cutout_RoyalEmblem' },
    pos = {
        x = 0,
        y = 1,
    },
    config = {
        extra = {
            amp = 0.25,
        }
    },
    loc_vars = function(self, info_queue, card)
        return {
            vars = { (card.ability.extra.amp) }
        }
    end,
	

    calculate = function(self, card, context)
        if context.individual and context.cardarea == G.play and context.other_card:is_face() and not ABN.is_number(context.other_card) and context.other_card:get_id() ~= 11 and context.other_card:get_id() ~= 12 and context.other_card:get_id() ~= 13 then
            return {
                amp = card.ability.extra.amp,
                card = card,
            }
        end
    end,
    
    abn_artist_credits = {
        artist = "0kronix",
    },
}

SMODS.Voucher {
  key = 'SpiceWine',
  atlas = 'Vouchers',
  pos = { x = 1, y = 0 },
  

  config = {
    extra = {
      asc = 0.02,
    },
  },

  loc_txt = {
    name = 'Spice Wine',
    text = {
      "When the {C:planet}Planet{} {C:attention}Rank{} of {C:attention}Face{} cards is {C:attention}leveled up{}",
	  "they also gain {C:gold}+#1#{} Asc. Power",
    },
  },

  loc_vars = function(self, info_queue, card)
    return { vars = { card.ability.extra.asc } }
  end,

  calculate = function(self, card, context)
    if not (context.using_consumeable and context.consumeable) then return end

    local planet = context.consumeable
    if planet.ability.set ~= 'Planet' then return end

    local rank = planet.ability.rank
    if not rank or not G.GAME.abn_rank_upgrades[rank] then return end

    local def = SMODS.Ranks[rank]
    if not (def and def.face) then return end

    for _, c in ipairs(G.playing_cards or {}) do
      if not SMODS.has_no_rank(c) and c.base.value == rank then
        c.ability.abn_perma_asc = (c.ability.abn_perma_asc or 0) + card.ability.extra.asc
      end
    end
  end,

  abn_artist_credits = {
    artist = "0kronix and Ginger",
  },
}

do

  local function voucher_card()
    if G.vouchers and G.vouchers.cards then
      for _, v in ipairs(G.vouchers.cards) do
        if v.config and v.config.center and v.config.center.key == 'v_cutout_GourmetLiquor' then
          return v
        end
      end
    end
  end

  local function percent()
    local v = voucher_card()
    local p = v and v.ability and v.ability.extra and v.ability.extra.percent
    return (p or 0) / 100
  end

  local function active(card)
    return voucher_card() ~= nil
      and card and card.ability and card.ability.set == 'Enhanced'
      and card.is_face and card:is_face()
  end

  local getters = {
    { 'get_chip_bonus',     'bonus',     false },
    { 'get_chip_mult',      'mult',      false },
    { 'get_chip_h_bonus',   'h_chips',   false },
    { 'get_chip_h_mult',    'h_mult',    false },
    { 'get_chip_x_bonus',   'x_chips',   true  },
    { 'get_chip_x_mult',    'x_mult',    true  },
    { 'get_chip_h_x_bonus', 'h_x_chips', true  },
    { 'get_chip_h_x_mult',  'h_x_mult',  true  },
  }

  for _, g in ipairs(getters) do
    local name, field, is_x = g[1], g[2], g[3]
    local ref = Card[name]
    if ref then
      Card[name] = function(self, ...)
        local result = ref(self, ...)
        if type(result) == 'number' and active(self) then
          local v = self.ability[field]
          if type(v) == 'number' then
            local extra = is_x and (v > 1 and (v - 1) * percent() or 0) or (v * percent())
            result = result + extra
          end
        end
        return result
      end
    end
  end

  local additive = {
    chips = true, h_chips = true, chip_mod = true,
    mult = true, h_mult = true, mult_mod = true,
  }
  local multiplicative = {
    x_chips = true, xchips = true, Xchip_mod = true, h_x_chips = true,
    x_mult = true, xmult = true, Xmult = true, Xmult_mod = true, h_x_mult = true,
  }

  local function scale(eff, depth)
    if type(eff) ~= 'table' or depth > 8 then return end
    local p = percent()
    for k, v in pairs(eff) do
      if type(v) == 'number' then
        if additive[k] then
          eff[k] = v * (1 + p)
        elseif multiplicative[k] then
          eff[k] = 1 + (v - 1) * (1 + p)
        end
      end
    end
    if eff.extra then scale(eff.extra, depth + 1) end
  end

  local eval_card_gourmet = eval_card
  function eval_card(card, context)
    local ret, post = eval_card_gourmet(card, context)
    if type(ret) == 'table' and active(card) then
      scale(ret.enhancement, 0)
    end
    return ret, post
  end
end

SMODS.Voucher {
  key = 'GourmetLiquor',
  atlas = 'Vouchers',
  pos = { x = 1, y = 1 },
  requires = { 'v_abn_SpiceWine' },

  config = {
    extra = {
      percent = 20,
    },
  },

  loc_txt = {
    name = 'Gourmet Liquor',
    text = {
      "{C:attention}Enhancements{} on {C:attention}Face{} cards",
      "give {C:attention}+#1#%{} more {C:chips}Chips{} and {C:mult}Mult{}",
    },
  },

  loc_vars = function(self, info_queue, card)
    return { vars = { card.ability.extra.percent } }
  end,

  abn_artist_credits = {
    artist = "0kronix and Ginger",
  },
}
