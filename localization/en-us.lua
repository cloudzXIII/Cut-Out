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
    },
  },
  misc = {
    labels = {
      cutout_abstract = "Abstract",
      cutout_distortion = "Distortion",
      cutout_energy = "Energy",
    }
  }
}
