local voucher_return_to_ante = "Return to Ante {C:attention}#1#"

return {
  descriptions = {
    Edition = {
      e_cutout_abstract = {
        name = "Abstract",
        text = {
          "Randomly gives one of:",
          "{C:abn_amperage}+#1#-#2#{} Amperage",
          "{C:abn_modulate}+#3#-#4#{} Modulate",
          "{C:purple}+#5#-#6#{} Score"
        }
      },
      e_cutout_amp = {
        name = "Amp",
        text = {
          "Based on the hand played previously",
          "this round, this gives its base",
          "{C:chips}Chips{} as {C:abn_amperage}Amperate{} and {C:mult}Mult{} as {C:abn_modulate}Modulate{}",
          "{C:inactive}(Currently: {C:abn_amperage}+#1#{C:inactive} Amperage, {C:abn_modulate}+#2#{C:inactive} Modulate)"
        }
      },
      e_cutout_distortion = {
        name = "Distortion",
        text = {
          "Round {C:chips}Chips{}, {C:mult}Mult{}, and {C:gold}Ascension Power",
          "up to the nearest power of {C:attention}#1#",
        }
      },
      e_cutout_energy = {
        name = "Energy",
        text = {
          "Gives {C:gold}Ascension Power",
          "equal to {C:money}sell value{},",
          "which increases by {C:money}$#1#",
          "with each blind beaten",
          "{C:inactive}(Currently: {C:gold}+#3# {C:inactive}Ascension Power)",
          "{C:inactive}(Playing cards start at {C:money}$#2#{C:inactive})",
        }
      },
      e_cutout_inverted = {
        name = "Inverted",
        text = {
          "Any from of {C:mult}Mult{} provided by this card",
          "is swapped for {C:chips}Chips{}, and vice versa"
        }
      },
    },
    Voucher = {
      v_cutout_executioner_switch = {
        name = "Executioner Switch",
        text = {
          voucher_return_to_ante,
          "Whenever a joker is destroyed,",
          "gain {C:money}${} equal to its sell value",
          "and lower Mayhem by {C:abn_mayhem_dark}#2#"
        }
      },
      v_cutout_clockspin = {
        name = "Clockspin",
        text = {
          voucher_return_to_ante,
          "{C:abn_mayhem_dark}-#2#{} Mayhem when showdown blind defeated",
          "Each {C:attention}Big Blind{} must be defeated twice"
        }
      },
      v_cutout_amperage_meter = {
        name = "Amperage Meter",
        text = {
          voucher_return_to_ante,
          "{C:abn_amperage}+#2#{} Amperage and {C:abn_mayhem_dark}+#3#{} Mayhem",
          "per {C:inactive}vanilla{} joker"
        }
      },
      v_cutout_illegal_glove = {
        name = "Illegal Glove",
        text = {
          voucher_return_to_ante,
        }
      },
      v_cutout_backdoor_draw = {
        name = "Backdoor Draw",
        text = {
          voucher_return_to_ante,
        }
      },
      v_cutout_pheromone_perfume = {
        name = "Pheromone Perfume",
        text = {
          voucher_return_to_ante,
        }
      },
    },
  },
  misc = {
    labels = {
      cutout_abstract = "Abstract",
      cutout_amp = "Amp",
      cutout_distortion = "Distortion",
      cutout_energy = "Energy",
      cutout_inverted = "Inverted",
    }
  }
}
