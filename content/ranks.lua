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
    next = { 'Jack', 'abn_11', 'cutout_Sire' },
  }, true
)

SMODS.Rank:take_ownership('Jack',
  {
    next = { 'Queen', 'cutout_Grace' },
  }, true
)

SMODS.Rank:take_ownership('Queen',
  {
    next = { 'King', 'cutout_Cavalier' },
  }, true
)

SMODS.Rank:take_ownership('Ace',
  {
    next = { '2', 'abn_11', 'cutout_AA' },
  }, true
)
