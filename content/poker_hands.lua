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
