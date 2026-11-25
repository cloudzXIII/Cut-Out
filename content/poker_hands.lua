SMODS.PokerHandPart({
	key = "blaze",
	func = function(hand)
		if #hand < 5 then return {} end

		local face_rank_map = {}
		local face_rank_count = 0
		local face_cards = {}

		for _, card in ipairs(hand) do
			if card:is_face() and not SMODS.has_no_rank(card) then
				table.insert(face_cards, card)
				local rank = tostring(card:get_id())
				if not face_rank_map[rank] then
					face_rank_map[rank] = true
					face_rank_count = face_rank_count + 1
				end
			end
		end

		return face_rank_count >= 5 and {face_cards} or {}
	end,
})

SMODS.PokerHand({
	key = "Blaze",
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
		return parts.cutout_blaze
	end,
})

SMODS.PokerHand({
	key = "RoyalCourt",
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

		local rc_parts = {}
		for _, part in ipairs(parts._straight) do
			local all_faces = true
			for _, card in ipairs(part) do
				if not card:is_face() then
					all_faces = false
					break
				end
			end
			if all_faces then table.insert(rc_parts, part) end
		end

		return parts._straight
	end,
})

SMODS.PokerHand({
	key = "Spectrum Blaze",
	visible = false,
	chips = 200,
	mult = 18,
	l_chips = 40,
	l_mult = 10,
	example = {
		{ "C_J", true },
		{ "S_cutout_Cavalier", true },
		{ "D_cutout_Sire", true },
		{ "H_cutout_Duke", true, enhancement = "m_wild" },
		{ "H_Q", true },
	},

	evaluate = function(parts, hand)
		if not next(parts.abn_spectrum) or not next(parts.cutout_blaze) then return {} end
		return { SMODS.merge_lists(parts.abn_spectrum, parts.cutout_blaze) }
	end,
})

SMODS.PokerHand({
	key = "Voided Blaze",
	visible = false,
	chips = 240,
	mult = 20,
	l_chips = 60,
	l_mult = 16,
	example = {
		{ "H_cutout_Sire", true },
		{ "S_J", true },
		{ "C_cutout_Cavalier", true },
		{ "D_cutout_Grace", true },
		{ "S_cutout_Duke", true, enhancement = "m_wild" },
		{ "abn_SUI_Q", true },
	},

	evaluate = function(parts, hand)
		if not next(parts.abn_spectrum) or not next(parts.cutout_blaze) then return {} end
		local parts_vblaze, parts_regblaze = {}, {}
		for _, part in ipairs(parts.cutout_blaze) do
			local new_part = {}
			local has_suitless = false
			for _, card in ipairs(part) do
				table.insert(new_part, card)
				if SMODS.has_no_suit(card) then has_suitless = true end
			end
			table.insert(has_suitless and #part >= 6 and parts_vblaze or parts_regblaze, new_part)
		end
		local rankless_faces = {}
		for _, card in ipairs(hand) do
			if card:is_face() and SMODS.has_no_rank(card) and SMODS.has_no_suit(card) then
				table.insert(rankless_faces, card)
			end
		end
		if #rankless_faces > 0 then
			parts_vblaze = {SMODS.merge_lists(parts_vblaze, parts_regblaze, {rankless_faces})}
		end
		return next(parts_vblaze) and parts_vblaze or {}
	end,
})

SMODS.PokerHand({
	key = "Photonic Spectrum",
	visible = false,
	chips = 220,
	mult = 20,
	l_chips = 50,
	l_mult = 12,
	example = {
		{ "S_cutout_AA", true },
		{ "C_cutout_AA", true },
		{ "D_cutout_AA", true, enhancement = "m_wild" },
		{ "D_cutout_AA", true },
		{ "H_cutout_AA", true },
	},

	evaluate = function(parts, hand)
		if not next(parts.abn_spectrum) then return {} end
		local parts_photonic = {}
		for _, part in ipairs(parts.abn_spectrum) do
			local all_aa = true
			local new_part = {}
			for _, card in ipairs(part) do
				if SMODS.has_no_rank(card) or card.base.value ~= "cutout_AA" then
					all_aa = false
					break
				end
				table.insert(new_part, part)
			end
			if all_aa then table.insert(parts_photonic, new_part) end
		end
		return parts_photonic
	end,
})
