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
	key = "Typ0Atlas",
	-- The name of the file, for the code to pull the atlas from
	path = "Typ0Atlas.png",
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

SMODS.Sound({key = "feces", path = "feces.wav",})

SMODS.Sound({key = "Typ0Talk", path = "Typ0Talk.wav",})


SMODS.Joker{
    key = "black_spot",
    rarity = 3,
    cost = 8,
    atlas = "Typ0Atlas",
    blueprint_compat = false,
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
    rarity = 2,
    cost = 5,
	atlas = "Typ0Atlas",
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

SMODS.Seal {
    name = "Kiss",
    key = 'Kiss',
    atlas = "KissedStamp",
    pos = { x = 0, y = 0 },
    config = { extra = { retriggers = 1, mult = 2 } },
    badge_colour = G.C.RED,

    loc_txt = {
        label = 'Kiss',
        name = "Kiss",
        text = {
            "Retrigger this card 1 time",
            "{C:mult}+2{} Mult"
        }
    },

    calculate = function(self, card, context)
        -- Retrigger effect (like Red Seal)
        if context.repetition then
            return {
                repetitions = card.ability.seal.extra.retriggers
            }
        end

        -- Mult bonus when the card scores
        if context.card_main then
            return {
                mult_mod = card.ability.seal.extra.mult,
                message = localize {
                    type = 'variable',
                    key = 'a_mult',
                    vars = { card.ability.seal.extra.mult }
                }
            }
        end
    end,

    loc_vars = function(self, info_queue, card)
        return { vars = { self.config.extra.retriggers, self.config.extra.mult } }
    end
}

-- Red Seal Joker
SMODS.Joker{
    key = "Boykisser",
    rarity = 4,
    cost = 20,
    atlas = "Typ0Atlas",
    pos = { x = 0, y = 1 },
	soul_pos = { x = 4, y = 1 },
    blueprint_compat = false,
    loc_txt = {
        name = "Boykisser",
        text = {
            "After scoring,",
            "Attempt to kiss a",
            "random played card,",
            "if it's a {C:attention}King{}",
            "or {C:attention}Jack{},",
            "give it a {C:red}Kiss{}"
        }
    },

    calculate = function(self, card, context)
       
        if context.after then
            local played_cards = context.scoring_hand or {}
            if #played_cards > 0 then
                
                local target_card = pseudorandom_element(played_cards, "seed")
				 if (target_card:get_id() == 11 or target_card:get_id() == 13) and not (target_card.ability and target_card.ability.seal) then
                	target_card:set_seal("Typ0_Kiss",false,true)
				
					return {
						message = "Kissed!",
						colour = {1, 0, 0, 1}
					}
                else
                    return {
						message = "Nah Im Gay",
						colour = {1, 0, 0, 1}
					}
				end	
            end
        end
    end
}

SMODS.Joker {

	key = 'cooljimbo',

	loc_txt = {
		name = 'Cool Jimbo',
		text = {
			"{C:mult}+#1# {} Mult"
		}
	},

	config = { extra = { mult = 8 } },

	loc_vars = function(self, info_queue, card)
		return { vars = { card.ability.extra.mult } }
	end,

	rarity = 1,

	atlas = 'Typ0Atlas',

	pos = { x = 2, y = 0 },

	cost = 2,
    blueprint_compat = false,

	calculate = function(self, card, context)
        if context.joker_main then

			return {
				mult_mod = card.ability.extra.mult,

				message = localize { type = 'variable', key = 'a_mult', vars = { card.ability.extra.mult } }

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
    atlas = 'Typ0Atlas',
    pos = { x = 3, y = 0 },
    cost = 2,
    blueprint_compat = false,

    calculate = function(self, card, context)
        if not context.joker_main then return end
        if card.area ~= G.jokers then return end

        local index
        for i, c in ipairs(G.jokers.cards) do
            if c == card then
                index = i
                break
            end
        end
        if not index or index == 1 then

            return {
                mult_mod = card.ability.extra.mult,
                message = localize {
                    type = 'variable',
                    key = 'a_mult',
                    vars = { card.ability.extra.mult }
                }
            }
        end


        local left_key = G.jokers.cards[index - 1].config.center.key

        print("Left joker key:", left_key)

        if left_key == 'j_Typ0_cooljimbo' then
            return {
                Xmult_mod = 4,
                message = localize {
                    type = 'variable',
                    key = 'a_xmult',
                    vars = { 4 }
                }
            }
        else
            return {
                mult_mod = card.ability.extra.mult,
                message = localize {
                    type = 'variable',
                    key = 'a_mult',
                    vars = { card.ability.extra.mult }
                }
            }
        end
    end
}






SMODS.Joker {
    key = "triple_sevens",
    blueprint_compat = true,
    rarity = 3,
    cost = 4,
    atlas = "Typ0Atlas",
    pos = { x = 5, y = 0 },

    config = { extra = { min = 1.5, max = 7 } },

    loc_txt = {
        name = "Triple Sevens",
        text = { "" }
    },

    loc_vars = function(self, info_queue, card)

        local r_mults = {}
        for i = math.floor(card.ability.extra.min), math.floor(card.ability.extra.max) do
            r_mults[#r_mults + 1] = tostring(i)
        end

        local main_start = {

            {
                n = G.UIT.T,
                config = {
                    text = "When three 7s played, X",
                    colour = G.C.UI.TEXT_DARK,
                    scale = 0.32
                }
            },

            {
                n = G.UIT.O,
                config = {
                    object = DynaText({
                        string = r_mults,
                        colours = { G.C.RED },
                        random_element = true,
                        silent = true,
                        pop_in_rate = 9999999,
                        pop_delay = 0.2011,
                        min_cycle_time = 0,
                        scale = 0.32
                    })
                }
            },


            {
                n = G.UIT.T,
                config = {
                    text = " Mult",
                    colour = G.C.UI.TEXT_DARK,
                    scale = 0.32
                }
            }
        }

        return { main_start = main_start }
    end,

    calculate = function(self, card, context)
        if context.joker_main and context.scoring_hand then
            local sevens = 0

            for _, c in ipairs(context.scoring_hand) do
                if c:get_id() == 7 then
                    sevens = sevens + 1
                end
            end

            -- ✅ at least three 7s
            if sevens >= 3 then
                return {
                    Xmult_mod = pseudorandom(
                        '7rands',
                        card.ability.extra.min,
                        card.ability.extra.max
                    ),
                    message = "777!",
                    colour = G.C.MULT
                }
            end
        end
    end
}

SMODS.Joker {
    key = 'royalstrategy',

    loc_txt = {
        name = 'Royal Strategy',
        text = {
            "Each scored {C:attention}King{}",
            "gives {C:red}X#1#{} Mult"
        }
    },

    config = { extra = { mult = 1.5 } },

    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.mult } }
    end,

    rarity = 3,
    atlas = 'Typ0Atlas',
    pos = { x = 4, y = 0 },
    cost = 5,
    blueprint_compat = false,

    calculate = function(self, card, context)
        -- EXACT same trigger as Walkie Talkie
        if context.individual and context.cardarea == G.play then
            if context.other_card:get_id() == 13 then -- King
                return {
                    Xmult_mod = card.ability.extra.mult,
                    card = context.other_card,
                    message = localize {
                        type = 'variable',
                        key = 'a_xmult',
                        vars = { card.ability.extra.mult }
                    }
                }
            end
        end
    end
}


SMODS.Joker {
    key = 'nuhuhjoker',

    loc_txt = {
        name = '',
        text = {}
    },

    rarity = 1,
    atlas = 'Typ0Atlas',
    pos = { x = 1, y = 1 },
    cost = 0,
    blueprint_compat = false,

    calculate = function(self, card, context)
        if context.joker_main then
            
            if not card.config or not card.config.center then return end

            local stake = get_joker_win_sticker(card.config.center, true)
            local stakemult = (stake * 0.5)
            
            if stake > 0 then
                return {
                    Xmult_mod = stakemult,
                    message = " ",
                    colour = {0, 0, 0, 0}
                }
            else
                return {
                    message = " ",
                    colour = {0, 0, 0, 0}
                }
            end
        end
    end
}

SMODS.Joker {
    key = "SISShip",
    loc_txt = {
        name = "SIS Ship",
                text = {
                    "{C:mult}+#1#{} Mult",
                    "{C:mult}+#2#{} Mult per",
                    "round played,",
                },
    },
    blueprint_compat = true,
    eternal_compat = false,
    rarity = 3,
    cost = 5,
    atlas = 'Typ0Atlas',
    pos = { x = 2, y = 1 },
    config = { extra = { mult_loss = 1, mult = 1 } },
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.mult, card.ability.extra.mult_loss } }
    end,
    calculate = function(self, card, context)
        if context.end_of_round and context.game_over == false and context.main_eval and not context.blueprint then
           
                
                card.ability.extra.mult = card.ability.extra.mult + card.ability.extra.mult_loss
                return {
                    message = localize { type = 'variable', key = 'a_mult_minus', vars = { card.ability.extra.mult_loss } },
                    colour = G.C.MULT
                }
           
        end
        if context.joker_main then
            return {
                mult = card.ability.extra.mult
            }
        end
    end
}

SMODS.Joker {
    key = "gelatinous_cube",
    loc_txt = {
        name = "Gelatinous Cube",
                text = {
                    "{C:chips}X#1#{} Chips for each card",
                    "below {C:attention}#3#{} in your full deck",
                    "{C:inactive}(Currently {C:chips}X#2#{C:inactive} Chips)",
                },
    },
    blueprint_compat = true,
    rarity = 3,
    cost = 6,
    atlas = "Typ0Atlas",
    pos = { x = 3, y = 1 },
	soul_pos = { x = 5, y = 1 },
    config = { extra = { mult = 1.5 } },
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.mult, math.max(0, card.ability.extra.mult * (G.playing_cards and (G.GAME.starting_deck_size - #G.playing_cards) or 0)), G.GAME.starting_deck_size } }
    end,
    calculate = function(self, card, context)
        if context.joker_main then
            
            --play_sound('Typ0_feces', 1, 100) --id like to get this to play only when chips are actually given but xchips makes a message that sound doesnt support so id have to have a second message which i dont want
            return {
                
                xchips = math.max(0, card.ability.extra.mult * (G.GAME.starting_deck_size - #G.playing_cards)),
                message = "Oozed!",
                colour = G.C.GREEN,
                sound = 'Typ0_feces',
            }
            
        end
    end
}

SMODS.Joker({
    key = "PolychromeToTheRight",
    loc_txt = {
        name = "Polychrome to the Right",
        text = {
            "Hey grayson is the polychrome to the right",
        }
    },

    atlas = "Typ0Atlas",
    pos = { x = 0, y = 2 },

    rarity = 2,
    cost = 6,

    config = {
        extra = {
            x_mult = 1.5
        }
    },


    calculate = function(self, card, context)
        if context.joker_main then
            local jokers = G.jokers and G.jokers.cards
            if jokers and jokers[#jokers] == card then
               
                return {
                    Xmult = 1.5
                }
            end
        end
    end,

    add_to_deck = function(self, card, from_debuff)
        if not card.edition or card.edition.type ~= 'polychrome' then
            card:set_edition({ type = 'polychrome' }, true)
        end
    end,


    set_edition = function(self, card, edition)

        return { type = 'polychrome' }
    end
})

SMODS.Shader{
    key = "positive",
    path = "positive.fs"
}



SMODS.Edition {
    key = 'positive',


	order = 2,
    loc_txt = {
        name = "Positive",
        label = "Positive",
        text = {
            "tols rekoJ {C:dark_edition}+1{}",
        }
    },
    shader = 'positive',
    
    config = { card_limit = -1 },
    in_shop = true,
    weight = 3,
    extra_cost = 5,
    sound = { sound = "polychrome", per = 1.5, vol = 0.4 },
    loc_vars = function(self, info_queue, card)
        return { vars = { card.edition.card_limit } }
    end,
    get_weight = function(self)
        return self.weight
    end,
}

SMODS.Joker {

	key = 'Typ0Joker',

	loc_txt = {
		name = 'Typ0',
		text = {
			"Fails"
		}
	},

	config = { extra = { mult = 8 } },

	loc_vars = function(self, info_queue, card)
        local numerator, denominator = SMODS.get_probability_vars(card, 1, 10000, 'typ0fail')

        return {
            vars = { numerator, denominator }
        }
    end,

	rarity = 1,

	atlas = 'Typ0Atlas',

	pos = { x = 1, y = 2 },

	cost = 2,
    blueprint_compat = false,

	calculate = function(self, card, context)
        if context.joker_main then

            local Typ0_Messages = {
                "Oh sugars!",
                "Holy Hannah!",
                "What in the sausage and egg mcmuffin!",
                "Subscribe to my youtube channel",
                "BUY SHIPPED IN SPACE",
                "IM TYP0 FRICK YOU",
                "I love torturing myself",
                "I eat rocks for breakfast",
                "Nayndabcat",
                "Carter sucks",
                "Uhhhhh",
                "UwU",
                "Thats Sexist",
                "Cheesebuckets",
                "Im Typ0 and i like saying slurs",
                "the slurs one isnt true btw",
                "i dont say slurs",
                "we where playing among us",
                "and my friend was impersonating me",
                "and he said",
                "Im homophobic",
                "i m gay",
                "i love men",
                "im straight",
                "you could be my green man",
                "i always do women",
                "to be clear these are things from my quotes channel",
                "in me and my friends discord",
                "that i have said",
                "but are taken out of context",
                "for comedic effect",
                "i love impregnating my pottery",
                "vro",
                "gosh i love jacob geller i want to make out with him",
                "i remember your kisses caleb",
                "you want me to kiss you caleb because i will",
                "i will kiss you hard",
                "i am actually straight btw",
                "how tf do i code malware for silly",
                "Sesbian Lex",
                "sure buddy",
                "skill issue",
                "i suck",
                "hey hottie",
                "*makes you feel gender dysphoria*",
                "i did divorce him a day later",
                "well i read the whole quotes channel",
                "so",
                "i think thats probably enough for now",
                "oh yeah some of these are split up over multiple messages",
                "uh",
                "im tired",
                "i need to sleep",
                "i should go to bed",
                "sorry im late",
                "i got distracted",
                "i got on a side quest",
                "i got lost in the sauce",
                "i got lost in the thick sauce",
                "thicc sauce is better",
                "dawg VScode autocomplete is wild",
                "ju",
                "orange juice",
                "id smash a dude",
                "Today is December 29th, 2025. This is Typ0, your host for today, bringing you your daily Silksong - Sea of Sorrow news. There has been no news to report for Sea of Sorrow today. This has been your daily news for Sea of Sorrow for today, December 29th, 2025.",
                "i love playing plants vs baddies", --grayson
                "lemon", 
                "ok thats enough",
                "ling gang guli guli gu ling guta ling gang gu ling gang gu",
                "You should play rainworld", -- carter
                "you should shoot grayson", -- carter
                "gay son",
                "Dont worry, im here for your children", -- dulci 
                "im so stupid",
                "i better not get cancelled for this",
                "i only pretend to be gay", -- dulci 
                "tradition is just peer pressure from dead people", -- dulci 
                "i",
                "am now",
                "applesauce",
                "you plonker",
                "i thought you had a shirt",
                "and then theres just the reverse time button",
                "fear kills more dreams than failure ever will", -- dulci
                "i cant do a pushup", -- will
                "Sometimes when you're in a dark place you tend to think you have been buried; what if you've just been planted", -- dulci 
                "Stop doubting yourself. You've already survived things you once thought would break you.", -- dulci 
                "im endorsed by donald trump", --tristram put this one in
                "i love femboys", --tristram put this one in
                "Breed me", --matt put this one in
                "im just a widdle man", --isaac
                "goodnight sweet heart", 
                "You could be dead tomorrow so you might as well live while you have the chance",
                "I'm gay", -- ju
                "i love watching stranger things every night with my amazing sister gwen", --my sister
                "im an avid anime weeb",-- caleb
                "this next one is false 100%",
                "im 100% verifiably gay and anything a day henceforth will do nothing to negate or nulify this statement", --caleb
                "im straight i promise",
                "freinds", --juniper
                "i Typ0 am going to open the end", -- dallin
                "my amazing husband caleb"
            }

            local randomIndex = math.random(#Typ0_Messages) 
            local selectedMessage = Typ0_Messages[randomIndex]

            if SMODS.pseudorandom_probability(card, "typ0fail", 1, 10000) then
                return {
                    Xmult = 1000000000000000,
                    xchips = 100000000000000,
                    message = selectedMessage,
                    sound = "Typ0_Typ0Talk", --i wish i could make this smarter somehow
                    colour = {0, 0, 1, 1}
                }
            else
                return {
                    Xmult = -1000000000000,
                    xchips = 0.1,
                    message = selectedMessage,
                    sound = "Typ0_Typ0Talk",
                    colour = {0, 0, 1, 1}

                }
            end
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
