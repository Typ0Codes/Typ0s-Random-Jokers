--[[
------------------------------Basic Table of Contents------------------------------
Line 17, Atlas ---------------- Explains the parts of the atlas.
Line 29, Joker 2 -------------- Explains the basic structure of a joker
Line 88, Runner 2 ------------- Uses a bit more complex contexts, and shows how to scale a value.
Line 127, Golden Joker 2 ------ Shows off a specific function that's used to add money at the end of a round.
Line 163, Merry Andy 2 -------- Shows how to use add_to_deck and remove_from_deck.
Line 207, Sock and Buskin 2 --- Shows how you can retrigger cards and check for faces
Line 240, Perkeo 2 ------------ Shows how to use the event manager, eval_status_text, randomness, and soul_pos.
Line 310, Walkie Talkie 2 ----- Shows how to look for multiple specific ranks, and explains returning multiple values
Line 344, Gros Michel 2 ------- Shows the no_pool_flag, sets a pool flag, another way to use randomness, and end of round stuff.
Line 418, Cavendish 2 --------- Shows yes_pool_flag, has X Mult, mainly to go with Gros Michel 2.
Line 482, Castle 2 ------------ Shows the use of reset_game_globals and colour variables in loc_vars, as well as what a hook is and how to use it.
--]]

--Creates an atlas for cards to use
SMODS.Atlas {
	-- Key for code to find it with
	key = "ModdedVanilla",
	-- The name of the file, for the code to pull the atlas from
	path = "ModdedVanilla.png",
	-- Width of each sprite in 1x size
	px = 71,
	-- Height of each sprite in 1x size
	py = 95
}

SMODS.Atlas {
	-- Key for code to find it with
	key = "KissedStamp",
	-- The name of the file, for the code to pull the atlas from
	path = "KissedStamp.png",
	-- Width of each sprite in 1x size
	px = 71,
	-- Height of each sprite in 1x size
	py = 95
}


SMODS.Joker{
    key = "black_spot",
    rarity = 3,
    cost = 8,
    atlas = "ModdedVanilla",
    pos = { x = 0, y = 0 },
	loc_txt = {
        name = "Black Spot",
        text = {
            "After scoring,",
            "{C:green}#1# out of #2#{} chance to",
            "destroy all played cards"
        }
    },

    loc_vars = function(self, info_queue, card)
        local numerator, denominator = SMODS.get_probability_vars(card, 4, 10, 'black_spot')

        return {
            vars = { numerator, denominator }
        }
    end,

    calculate = function(self, card, context)

		--thanks N' and SDM_0 on discord for helping with this
        if context.after and SMODS.pseudorandom_probability(card, "black_spot", 4, 10) then
            SMODS.destroy_cards(context.scoring_hand)
            return {
                message = "Marked!",
                colour = {0, 0, 0, 1}
            }
        end
    end
}



SMODS.Joker {
    key = "eviloops",
	loc_txt = {
        name = "{C:red}Evil{} Oops All Sixes",
        text = {
            "Halves all listed probabilities",
			"{C:green}(ex: 1 in 3 -> 1 in 6){}"
        }
    },
    blueprint_compat = false,
    discovered = true,
    rarity = 2,
    cost = 5,
	atlas = "ModdedVanilla",
    pos = { x = 1, y = 0 },
    calculate = function(self, card, context)
        if context.mod_probability and not context.blueprint then
            return {
                numerator = context.numerator / 2
            }
        end
    end,
    locked_loc_vars = function(self, info_queue, card)
        return { vars = { number_format(10000) } }
    end,
    
}

-- Red Seal
SMODS.Seal {
	name = "Kiss",
    key = 'Kiss',
	atlas = "KissedStamp",
    pos = { x = 0, y = 0 },
    config = { extra = { retriggers = 1 } },
    badge_colour = G.C.RED,
	loc_txt = {
		label = 'Kiss',
        name = "Kiss",

        text = {
            "Retrigger this card 1 time",
			"(Litterally just red seal)"
        }
    },
    calculate = function(self, card, context)
        if context.repetition then
            return {
                repetitions = card.ability.seal.extra.retriggers,
            }
        end
    end,
    loc_vars = function(self, info_queue, card)
        return { vars = { self.config.extra.retriggers } }
    end
}

-- Red Seal Joker
SMODS.Joker{
    key = "Boykisser",
    rarity = 4,
    cost = 20,
    atlas = "ModdedVanilla",
    pos = { x = 0, y = 1 },
	soul_pos = { x = 4, y = 1 },
    loc_txt = {
        name = "Boykisser",
        text = {
            "After scoring,",
            "Kiss a random {C:attention}King{}",
            "or {C:attention}Jack{}"
        }
    },

    calculate = function(self, card, context)
       
        if context.after then
            local played_cards = context.scoring_hand or {}
            if #played_cards > 0 then
                
                local target_card = pseudorandom_element(played_cards, "seed")
				 if target_card:get_id() == 11 or target_card:get_id() == 13 then
                	target_card:set_seal("Typ0_Kiss",false,true)
				
					return {
						message = "Kissed!",
						colour = {1, 0, 0, 1}
					}
				end	
            end
        end
    end
}

SMODS.Joker {
	-- How the code refers to the joker.
	key = 'cooljimbo',
	-- loc_text is the actual name and description that show in-game for the card.
	loc_txt = {
		name = 'Cool Jimbo',
		text = {
			--[[
			The #1# is a variable that's stored in config, and is put into loc_vars.
			The {C:} is a color modifier, and uses the color "mult" for the "+#1# " part, and then the empty {} is to reset all formatting, so that Mult remains uncolored.
				There's {X:}, which sets the background, usually used for XMult.
				There's {s:}, which is scale, and multiplies the text size by the value, like 0.8
				There's one more, {V:1}, but is more advanced, and is used in Castle and Ancient Jokers. It allows for a variable to dynamically change the color. You can find an example in the Castle joker if needed.
				Multiple variables can be used in one space, as long as you separate them with a comma. {C:attention, X:chips, s:1.3} would be the yellow attention color, with a blue chips-colored background,, and 1.3 times the scale of other text.
				You can find the vanilla joker descriptions and names as well as several other things in the localization files.
				]]
			"{C:mult}+#1# {} Mult"
		}
	},
	--[[
		Config sets all the variables for your card, you want to put all numbers here.
		This is really useful for scaling numbers, but should be done with static numbers -
		If you want to change the static value, you'd only change this number, instead
		of going through all your code to change each instance individually.
		]]
	config = { extra = { mult = 8 } },
	-- loc_vars gives your loc_text variables to work with, in the format of #n#, n being the variable in order.
	-- #1# is the first variable in vars, #2# the second, #3# the third, and so on.
	-- It's also where you'd add to the info_queue, which is where things like the negative tooltip are.
	loc_vars = function(self, info_queue, card)
		return { vars = { card.ability.extra.mult } }
	end,
	-- Sets rarity. 1 common, 2 uncommon, 3 rare, 4 legendary.
	rarity = 1,
	-- Which atlas key to pull from.
	atlas = 'ModdedVanilla',
	-- This card's position on the atlas, starting at {x=0,y=0} for the very top left.
	pos = { x = 2, y = 0 },
	-- Cost of card in shop.
	cost = 2,
	-- The functioning part of the joker, looks at context to decide what step of scoring the game is on, and then gives a 'return' value if something activates.
	calculate = function(self, card, context)
		-- Tests if context.joker_main == true.
		-- joker_main is a SMODS specific thing, and is where the effects of jokers that just give +stuff in the joker area area triggered, like Joker giving +Mult, Cavendish giving XMult, and Bull giving +Chips.
		if context.joker_main then
			-- Tells the joker what to do. In this case, it pulls the value of mult from the config, and tells the joker to use that variable as the "mult_mod".
			return {
				mult_mod = card.ability.extra.mult,
				-- This is a localize function. Localize looks through the localization files, and translates it. It ensures your mod is able to be translated. I've left it out in most cases for clarity reasons, but this one is required, because it has a variable.
				-- This specifically looks in the localization table for the 'variable' category, specifically under 'v_dictionary' in 'localization/en-us.lua', and searches that table for 'a_mult', which is short for add mult.
				-- In the localization file, a_mult = "+#1#". Like with loc_vars, the vars in this message variable replace the #1#.
				message = localize { type = 'variable', key = 'a_mult', vars = { card.ability.extra.mult } }
				-- Without this, the mult will stil be added, but it'll just show as a blank red square that doesn't have any text.
			}
		end
	end
}



   SMODS.Joker {
    key = 'coolerjimbo',
    loc_txt = {
        name = 'Cooler Jimbo',
        text = {
            "{C:mult}+#1# {} Mult.",
            "If you have {C:attention}Cool Jimbo{}",
            "on the left of this joker,",
            "{C:mult}X4{} Mult instead"
        }
    },
    config = { extra = { mult = 8 } },
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.mult } }
    end,
    rarity = 3,
    atlas = 'ModdedVanilla',
    pos = { x = 3, y = 0 },
    cost = 2,
    calculate = function(self, card, context)
        if not context.joker_main then return end
        if card.area ~= G.jokers then return end

        local index
        for i = 1, #G.jokers.cards do
            if G.jokers.cards[i] == card then
                index = i
                break
            end
        end
        if not index then return end

        local left_joker = index > 1 and G.jokers.cards[index - 1] or nil
        local left_key = left_joker and left_joker.original_key

        if left_key == 'Typ0_cooljimbo' then
            return {
                Xmult_mod = 4,
                message = localize { type = 'variable', key = 'a_xmult', vars = { 4 } }
            }
        else
            return {
                mult_mod = card.ability.extra.mult,
                message = localize { type = 'variable', key = 'a_mult', vars = { card.ability.extra.mult } }
            }
        end
    end
}










--[[ This is called a hook. It's a less intrusive way of running your code when base game functions
	get called than lovely injections. It works by saving the base game function, local igo, then
	overwriting the current function with your own. You then run the saved function, igo, to make
	the function do everything it was previously already doing, and then you add your code in, so
	that it runs either before or after the rest of the function gets used.
							
	This function hooks into Game:init_game_object in order to create the custom
	G.GAME.current_round.castle2_card variable that the above joker uses whenever a run starts.]]
local igo = Game.init_game_object
function Game:init_game_object()
	local ret = igo(self)
	ret.current_round.castle2_card = { suit = 'Spades' }
	return ret
end

-- This is a part 2 of the above thing, to make the custom G.GAME variable change every round.
function SMODS.current_mod.reset_game_globals(run_start)
	-- The suit changes every round, so we use reset_game_globals to choose a suit.
	G.GAME.current_round.castle2_card = { suit = 'Spades' }
	local valid_castle_cards = {}
	for _, v in ipairs(G.playing_cards) do
		if not SMODS.has_no_suit(v) then -- Abstracted enhancement check for jokers being able to give cards additional enhancements
			valid_castle_cards[#valid_castle_cards + 1] = v
		end
	end
	if valid_castle_cards[1] then
		local castle_card = pseudorandom_element(valid_castle_cards, pseudoseed('2cas' .. G.GAME.round_resets.ante))
		G.GAME.current_round.castle2_card.suit = castle_card.base.suit
	end
end

-- TODO:
-- Have people proofread, make sure my overly long way of writing is actually legible or cut down to make sure it's legible.


----------------------------------------------
------------MOD CODE END----------------------
