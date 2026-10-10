CUTOUT = SMODS.current_mod
CUTOUT.description_loc_vars = function()
  return { background_colour = G.C.CLEAR, text_colour = G.C.WHITE, scale = 1.2, shadow = true }
end

function CUTOUT.recursive_load(path)
  local files = NFS.getDirectoryItems(ASAS.path .. path)
  table.sort(files)
  for _, item in ipairs(files) do
    if string.sub(item, -4) == ".lua" then
      local f, err = SMODS.load_file(path .. "/" .. item)
      if err then
        error(err)
      elseif f then
        f()
      end
    elseif path:find("%.") == nil then
      CUTOUT.recursive_load(path .. "/" .. item)
    end
  end
end

--[[
Usage for the above function would be:
CUTOUT.recursive_load("content")
(loads everything including subfolders for any given directory)
]]


--new ranks
SMODS.Atlas({
  key = "Ranks",
  path = "suits_ranks_icons/faceranks.png",
  px = 71,
  py = 95,
})

local suit_map = {
    Hearts = 0,
    Clubs = 1,
    Diamonds = 2,
    Spades = 3,
}

SMODS.Rank {
  key = 'Sire',
  card_key = 'Sire',
  shorthand = 'Sire',
  lc_atlas = 'Ranks',
  hc_atlas = 'Ranks',
  pos = { x = 2},
  next = { 'Jack' },
  nominal = 10,
  face = true,
  suit_map = suit_map,
  
  loc_txt = {
	name = 'Sire',
  },

  in_pool = function(self, args)
    if args and ((args.suit == '') or (args.initial_deck)) then
      return false
    else
      return true
    end
  end,
}

SMODS.Rank {
  key = 'Grace',
  card_key = 'Grace',
  shorthand = 'Grace',
  lc_atlas = 'Ranks',
  hc_atlas = 'Ranks',
  pos = { x = 1},
  next = { 'Queen' },
  nominal = 10,
  face = true,
  suit_map = suit_map,
  
  loc_txt = {
	name = 'Grace',
  },

  in_pool = function(self, args)
    if args and ((args.suit == '') or (args.initial_deck)) then
      return false
    else
      return true
    end
  end,
}

SMODS.Rank {
  key = 'Duke',
  card_key = 'Duke',
  shorthand = 'Duke',
  lc_atlas = 'Ranks',
  hc_atlas = 'Ranks',
  pos = { x = 0},
  next = { 'King' },
  nominal = 10,
  face = true,
  suit_map = suit_map,
  
  loc_txt = {
	name = 'Duke',
  },

  in_pool = function(self, args)
    if args and ((args.suit == '') or (args.initial_deck)) then
      return false
    else
      return true
    end
  end,
}

SMODS.Atlas({
  key = "Ranks2",
  path = "suits_ranks_icons/to_rename.png",
  px = 71,
  py = 95,
})

SMODS.Rank {
  key = 'Cavalier',
  card_key = 'Cavalier',
  shorthand = 'Cavalier',
  lc_atlas = 'Ranks2',
  hc_atlas = 'Ranks2',
  pos = { x = 13},
  next = { 'cutout_Duke' },
  nominal = 10,
  face = true,
  suit_map = suit_map,
  
  loc_txt = {
	name = 'Cavalier',
  },

  in_pool = function(self, args)
    if args and ((args.suit == '') or (args.initial_deck)) then
      return false
    else
      return true
    end
  end,
}

SMODS.Atlas({
  key = "Ranks3",
  path = "suits_ranks_icons/music_suit.png",
  px = 71,
  py = 95,
})

SMODS.Rank {
  key = 'AA', --like the batteries...
  card_key = 'AA',
  shorthand = 'AA',
  lc_atlas = 'Ranks3',
  hc_atlas = 'Ranks3',
  pos = { x = 13},
  next = { 'abn_11' },
  nominal = 11,
  suit_map = suit_map,
  
  loc_txt = {
	name = 'Double Ace',
  },

  in_pool = function(self, args)
    if args and ((args.suit == '') or (args.initial_deck)) then
      return false
    else
      return true
    end
  end,
}

SMODS.Rank:take_ownership('10',
  {
    next = { 'cutout_Sire' },
    straight_edge = false
  }, true
)

SMODS.Rank:take_ownership('Jack',
  {
    next = { 'cutout_Grace' },
    straight_edge = false
  }, true
)

SMODS.Rank:take_ownership('Queen',
  {
    next = { 'cutout_Cavalier' },
    straight_edge = false
  }, true
)

SMODS.Rank:take_ownership('Ace',
  {
    next = { 'cutout_AA' },
    straight_edge = false
  }, true
)
--new ranks

--new hands

SMODS.PokerHand({
	key = "Blaze",
	loc_txt = {
		name = "Blaze",
		description = { "5 different face ranks" },
	},
	visible = false,
	chips = 50,
	mult = 5,
	l_chips = 20,
	l_mult = 3,
	example = {
		{ "S_cutout_Sire", true },
		{ "H_cutout_Grace", true },
		{ "D_Q", true },
		{ "C_cutout_Cavalier", true },
		{ "S_cutout_Duke", true },
	},

	evaluate = function(parts, hand)
		if #hand ~= 5 then return {} end

		local seen_ranks = {}
		local matching = {}

		for _, card in ipairs(hand) do
			if not card:is_face() then
				return {}
			end

			local rank = card:get_id()
			
			if seen_ranks[rank] then
				return {}
			end

			seen_ranks[rank] = true
			matching[#matching + 1] = card
		end

		return { matching }
	end,
})

SMODS.PokerHand({
	key = "RoyalCourt",
	loc_txt = {
		name = "Royal Court",
		description = { "A Straight made entirely of face cards" },
	},
	visible = false,
	chips = 100,
	mult = 9,
	l_chips = 25,
	l_mult = 3,
	example = {
		{ "S_cutout_Sire", true },
		{ "H_J", true },
		{ "D_cutout_Grace", true },
		{ "C_Q", true },
		{ "S_cutout_Cavalier", true },
	},

	evaluate = function(parts, hand)
		if not parts._straight or #parts._straight == 0 then
			return {}
		end

		for _, card in ipairs(hand) do
			if not card:is_face() then
				return {}
			end
		end

		return parts._straight
	end,
})

--new hands

--new enhancements

SMODS.Atlas({
  key = "Enhancements",
  path = "enhancements.png",
  px = 71,
  py = 95,
})

local scie = SMODS.calculate_individual_effect
function SMODS.calculate_individual_effect(effect, scored_card, key, amount, from_edition)
  if scored_card 
     and scored_card.config 
     and scored_card.config.center == G.P_CENTERS.m_cutout_Tallied 
     and (key == "chips" or key == "chip_mod") then
    return nil
  end

  return scie(effect, scored_card, key, amount, from_edition)
end
SMODS.Enhancement({
  key = "Tallied",
  loc_txt = {
	name = "Tallied",
	text = {
		"Instead of {C:chips}Chips{} give",
		"{C:attention}rank{} {X:mult,C:white}X#1#{} as {C:purple}score{}",
		"{C:inactive}Currently:{} {C:purple}+#2#{} {C:inactive}Score{}",
    },
  },
  pos = { x = 0, y = 0 }, 
  atlas = "Enhancements",
  replace_base_card = false,
  no_rank = false,
  no_suit = false,
  always_scores = false,
  config = {
    extra = {
      mult = 100,
    }
  },
  loc_vars = function(self, info_queue, card)
    local cae = card.ability.extra
    local nominal = card.base and card.base.nominal or 0
    local total_score = nominal * cae.mult
    return { vars = { cae.mult, total_score } }
  end,
  calculate = function(self, card, context)
    if context.main_scoring and context.cardarea == G.play then
      local nominal = card.base and card.base.nominal or 0
      return {
        score = nominal * card.ability.extra.mult,
        card = card
      }
    end
  end,
})

SMODS.Enhancement({
  key = "Zigzag",
  loc_txt = {
    name = "Zig Zag",
    text = {
      {
        "When held in hand {C:green}#2# in #3#{} chance to",
        "lower the {C:attention}blind requirements{} by {C:attention}%{} equal to its {C:attention}rank{}",
      },
      {
        "When scoring {C:green}#4# in #5#{} chance",
        "for hand to give {C:attention}double{} it's value",
      },
    }
  },
  pos = { x = 1, y = 0 }, 
  atlas = "Enhancements",
  replace_base_card = false,
  no_rank = false,
  no_suit = false,
  always_scores = false,
  config = {
    extra = {
      odds_blind = 7,
      odds_double = 9,
    }
  },
  loc_vars = function(self, info_queue, card)
    local cae = card.ability.extra
    local nominal = card.base and card.base.nominal or 0
    local b_num, b_den = SMODS.get_probability_vars(card, 1, cae.odds_blind, 'zigzag_blind')
    local d_num, d_den = SMODS.get_probability_vars(card, 1, cae.odds_double, 'zigzag_double')

    return { vars = { nominal, b_num, b_den, d_num, d_den } }
  end,
  calculate = function(self, card, context)
    if context.modify_hand and card.area == G.hand and not card.debuffed then
      if SMODS.pseudorandom_probability(card, "zigzag_blind", 1, card.ability.extra.odds_blind) then
        local nominal = card.base and card.base.nominal or 0
        if nominal > 0 and G.GAME.blind and G.GAME.blind.chips then
          local reduction = math.floor(G.GAME.blind.chips * (nominal / 100))
          G.GAME.blind.chips = math.max(1, G.GAME.blind.chips - reduction)
          G.GAME.blind.chip_text = number_format(G.GAME.blind.chips)

          card_eval_status_text(card, 'extra', nil, nil, nil, {
            message = "-" .. nominal .. "%!",
            colour = G.C.GREEN
          })
        end
      else
        card_eval_status_text(card, 'extra', nil, nil, nil, {
          message = localize('k_nope_ex'),
          colour = G.C.SECONDARY_SET.Tarot
        })
      end
    end

    if context.modify_hand and context.cardarea == G.play and not card.debuffed then
      if SMODS.pseudorandom_probability(card, "zigzag_double", 1, card.ability.extra.odds_double) then
        mult = mod_mult(mult * 2)
        hand_chips = mod_chips(hand_chips * 2)

        update_hand_text({ delay = 0 }, { chips = hand_chips, mult = mult })

        card_eval_status_text(card, 'extra', nil, nil, nil, {
          message = localize('k_upgrade_ex'),
          colour = G.C.FILTER
        })
      else
        card_eval_status_text(card, 'extra', nil, nil, nil, {
          message = localize('k_nope_ex'),
          colour = G.C.SECONDARY_SET.Tarot
        })
      end
    end
  end,
})

SMODS.Enhancement({
  key = "Sandy",
  loc_txt = {
    name = "Sandy",
    text = {
      {
        "No rank or suit",
        "{C:mult}+#1#{} Mult per scoring {C:attention}Face card{}",
		"{C:chips}+#2#{} Chips per scoring {C:attention}Numbered card{}",
      },
    }
  },
  pos = { x = 2, y = 0 }, 
  atlas = "Enhancements",
  no_rank = true,
  no_suit = true,
  replace_base_card = true,
  always_scores = true,
  config = {
    extra = {
      mult_per_face = 10,
      chips_per_num = 15,
    }
  },
  loc_vars = function(self, info_queue, card)
    local cae = card.ability.extra
    return { vars = { cae.mult_per_face, cae.chips_per_num } }
  end,
  calculate = function(self, card, context)
    if context.main_scoring and context.cardarea == G.play then
		local face_count = 0
        local number_count = 0

        if context.scoring_hand then
          for _, sc in ipairs(context.scoring_hand) do
            if sc:is_face() then
              face_count = face_count + 1
            elseif not SMODS.has_no_rank(sc) and not sc:is_face() then
              number_count = number_count + 1
            end
          end
        end

        local total_mult = face_count * card.ability.extra.mult_per_face
        local total_chips = number_count * card.ability.extra.chips_per_num

        return {
			mult = total_mult,
            chips = total_chips,
            card = card
        }
    end
  end,
})

SMODS.Enhancement({
  key = "Spare",
  loc_txt = {
    name = "Spare",
    text = {
      {
        "Gain {C:abn_eternal}+#2#{} Amperage per {C:blue}Hand{} left when played",
        "{C:inactive}Currently: {C:abn_eternal}+#1#{} {C:inactive}Amperage{}",
      },
    }
  },
  pos = { x = 3, y = 0 }, 
  atlas = "Enhancements",
  replace_base_card = false,
  no_rank = false,
  no_suit = false,
  always_scores = false,
  config = {
    extra = {
      amp = 0,
      amp_gain = 0.25,
    }
  },
  loc_vars = function(self, info_queue, card)
    local cae = card.ability.extra
    return { vars = { cae.amp, cae.amp_gain } }
  end,
  calculate = function(self, card, context)
    if context.before and context.cardarea == G.play and not card.debuffed then
      local hands_left = G.GAME.current_round.hands_left or 0
      if hands_left > 0 then
        local gains = hands_left * card.ability.extra.amp_gain
        SMODS.scale_card(card, {
          ref_table = card.ability.extra,
          ref_value = "amp",
          scalar_value = "amp_gain",
          operation = function(ref_table, ref_value, initial, change)
            ref_table[ref_value] = initial + gains
          end,
          message = localize('k_upgrade_ex'),
          message_colour = G.C.ABN_ETERNAL
        })
      end
    end

    if context.main_scoring and context.cardarea == G.play and not card.debuffed then
      return {
        amp = card.ability.extra.amp,
        card = card
      }
    end
  end,
})

SMODS.Enhancement({
  key = "Ample",
  loc_txt = {
    name = "Ample",
    text = {
      {
        "After {C:attention}scoring{} change the {C:attention}Rank{} and gain {C:gold}+#2#{} Asc. Power",
        "{C:inactive}Currently:{} {C:gold}+#1#{} {C:inactive}Asc. Power{}",
      },
    }
  },
  pos = { x = 4, y = 0 }, 
  atlas = "Enhancements",
  replace_base_card = false,
  no_rank = false,
  no_suit = false,
  always_scores = false,
  config = {
    extra = {
      asc = 0,
      asc_gain = 0.25,
    }
  },
  loc_vars = function(self, info_queue, card)
    local cae = card.ability.extra
    return { vars = { cae.asc, cae.asc_gain } }
  end,
  calculate = function(self, card, context)
    if context.main_scoring and context.cardarea == G.play and not card.debuffed then
        return {
          asc = card.ability.extra.asc,
          colour = G.C.GOLD,
          card = card
        }
    end

    if context.final_scoring_step and context.cardarea == G.play and not card.debuffed and not context.blueprint then
      SMODS.scale_card(card, {
        ref_table = card.ability.extra,
        ref_value = "asc",
        scalar_value = "asc_gain",
        message = localize('k_upgrade_ex'),
        message_colour = G.C.GOLD
      })

      local current_rank = card.base and card.base.value
      local valid_ranks = {}
      for k, v in pairs(SMODS.Ranks) do
        if k ~= current_rank then
          table.insert(valid_ranks, k)
        end
      end

      if #valid_ranks > 0 then
        local new_rank = pseudorandom_element(valid_ranks, 'ample_rank_' .. G.GAME.round_resets.ante)
        
        G.E_MANAGER:add_event(Event({
          func = function()
            card:juice_up(0.3, 0.4)
            assert(SMODS.change_base(card, nil, new_rank))
            return true
          end
        }))
      end
    end
  end,
})

SMODS.Enhancement({
  key = "Deteriorated",
  loc_txt = {
    name = "Deteriorated",
    text = {
      {
        "Gives {C:abn_eternal}+#1#{} Amperage per other scoring card",
        "sharing a {C:attention}Rank{} with this card",
	  },
	  {
        "Gives {C:attention}+#2#{} Modulate per other scoring card",
        "sharing a {C:attention}Suit{} with this card",
      },
    }
  },
  pos = { x = 5, y = 0 },
  atlas = "Enhancements",
  replace_base_card = false,
  no_rank = false,
  no_suit = false,
  always_scores = false,
  config = {
    extra = {
      amp_per_rank = 2,
      modulate_per_suit = 2,
    }
  },
  loc_vars = function(self, info_queue, card)
    local cae = card.ability.extra
    return { vars = { cae.amp_per_rank, cae.modulate_per_suit } }
  end,
  calculate = function(self, card, context)
    if context.main_scoring and context.cardarea == G.play then
      local rank_matches = 0
      local suit_matches = 0

      if context.scoring_hand then
        for _, sc in ipairs(context.scoring_hand) do
          if sc ~= card then
            if not SMODS.has_no_rank(sc) and sc:get_id() == card:get_id() then
              rank_matches = rank_matches + 1
            end
            if not SMODS.has_no_suit(sc) and sc:is_suit(card.base.suit) then
              suit_matches = suit_matches + 1
            end
          end
        end
      end

      local total_amp = rank_matches * card.ability.extra.amp_per_rank
      local total_modulate = suit_matches * card.ability.extra.modulate_per_suit

        return {
          amp = total_amp,
          modulate = total_modulate,
          card = card
        }
    end
  end,
})

--new enhancements
