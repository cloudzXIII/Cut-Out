SMODS.Shader{
	key = "abstract",
	path = "abstract.fs"
}

SMODS.Edition{
	key = "abstract",
	shader = "abstract",
	config = {extra = {
		{type = "amp", range = {0, 10}},
		{type = "modulate", range = {0, 23}},
		{type = "score", range = {0, 500}},
	}},
	loc_vars = function(self, info_queue, card)
		local cae = card.edition.extra
		return {vars = {cae[1].range[1], cae[1].range[2], cae[2].range[1], cae[2].range[2], cae[3].range[1], cae[3].range[2]}}
	end,
	calculate = function(self, card, context)
		if context.post_joker or (context.main_scoring and context.cardarea == G.play) then
			local scoring = pseudorandom_element(card.edition.extra, "e_cutout_abstract")
			return {[scoring.type] = pseudorandom("e_cutout_abstract", scoring.range[1], scoring.range[2])}
		end
	end
}

SMODS.Shader{
	key = "distortion",
	path = "distortion.fs"
}

SMODS.Edition{
	key = "distortion",
	shader = "distortion",
	config = {extra = {power = 2}},
	loc_vars = function(self, info_queue, card)
		return {vars = {card.edition.extra.power}}
	end,
	calculate = function(self, card, context)
		if context.post_joker or (context.main_scoring and context.cardarea == G.play) then
			local ret = {chips = hand_chips, mult = mult, asc = G.GAME.asc_power_hand}
			local power = card.edition.extra.power
			local any = false
			for k, v in pairs(ret) do
				if v > 0 then
					local cur = 0
					while math.pow(power, cur) < v do
						cur = cur + 1
					end
					ret[k] = math.pow(power, cur)
					any = true
				end
			end
			if any then
				ret = {
					chips = ret.chips - hand_chips,
					mult = ret.mult - mult,
					asc = ret.asc - G.GAME.asc_power_hand
				}
				for k in pairs(ret) do
					if ret[k] == 0 then
						ret[k] = nil
					end
				end
				return ret
			end
		end
	end
}

SMODS.Shader{
	key = "energy",
	path = "energy.fs"
}

SMODS.Edition{
	key = "energy",
	shader = "energy",
	config = {extra = {extra_value = 1, pc_start = 1}},
	loc_vars = function(self, info_queue, card)
		return {vars = {card.edition.extra.extra_value, card.edition.extra.pc_start, card.sell_cost}}
	end,
	calculate = function(self, card, context)
		if context.post_joker or (context.main_scoring and context.cardarea == G.play) then
			return {asc = card.sell_cost}
		elseif context.blind_defeated then
			SMODS.scale_card(card, {
				ref_table = card.ability,
				ref_value = "extra_value",
				scalar_table = card.edition.extra,
				scalar_value = "extra_value",
				message_colour = G.C.YELLOW,
				no_message = card.area == G.deck or card.area == G.discard,
				operation = function(ref_table, ref_value, initial, change)
					ref_table[ref_value] = initial + change
					card:set_cost()
				end
			})
		end
	end
}
