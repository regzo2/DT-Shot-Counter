return {
	run = function()
		fassert(rawget(_G, "shot_counter"), "`shot_counter` encountered an error loading the Darktide Mod Framework.")

		new_mod("shot_counter", {
			mod_script       = "shot_counter/scripts/shot_counter_main",
			mod_data         = "shot_counter/scripts/shot_counter_data",
			mod_localization = "shot_counter/scripts/shot_counter_localization",
		})
	end,
	packages = {},
}
