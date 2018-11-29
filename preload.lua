local enable_penalty = true
local requires_charges = true
local ter_warpgate_id = "t_TRS_stabilized_portal"
local req_power_gate = 6
local req_power_location = 12
local req_power_blind_leap = 24

function message(...)
	local s = string.format(...)
	game.add_msg(s)
end

function tri_delta(a, b)
	return tripoint(a.x - b.x, a.y - b.y, a.z - b.z)
end

function standing_on_warpgate()
	local ter_int_id = map:ter(player:pos()):to_i()
	local ter_str_id = game.get_terrain_type(ter_int_id).id:str()
	return (ter_str_id == ter_warpgate_id)
end

function iuse_trs_loose_teleport(item, active)
	if requires_charges and item.charges < req_power_blind_leap then
		message("Insufficient charge. Blind Leaps require a charge of %d.", req_power_blind_leap)
		return
	end
	
	if not game.query_yn("<color_red>This function does not guarantee a safe landing.\nIs that all right?</color>") then
		message("Teleport canceled.")
		return
	end
	
	local target = game.omap_choose_point( player:global_omt_location() )
	
	if requires_charges then
		item.charges = item.charges - req_power_blind_leap
    end
    
	g:place_player_overmap(target)

	g:reload_npcs()

	message("The world turns around you, and a new location comes careening into focus.")

	if enable_penalty and game.one_in(3) then
		apply_penalty(item)
	end
end

function iuse_trs_link(item, active)
	local on_warpgate = standing_on_warpgate();
	
	if not on_warpgate then
		message("Couldn't find valid warpgate. Please use this item only while standing on a fully activate warpgate.")
		return
	end
	
	local is_linked = item:has_var("gate_name")
	
	if is_linked then
		if not game.query_yn("A gate link has already been established.\nAre you sure you want to override the current link?") then
			message("A gate link was not established.")
			return
		end
	end
	
	local om = player:global_omt_location()
	local gpos = player:global_square_location()
	
	item:set_var("gate_name", "linked")
	item:set_var("gate_omx", tostring(om.x))
	item:set_var("gate_omy", tostring(om.y))
	item:set_var("gate_omz", tostring(om.z))
	item:set_var("gate_gx", tostring(gpos.x))
	item:set_var("gate_gy", tostring(gpos.y))
	item:set_var("gate_gz", tostring(gpos.z))
	
	message("The translocator has successfully established a link to the gate.")
end

function iuse_trs_delete(item, active)
	local save_count = item:get_var("save_count", 0)
	if save_count == 0 then
		message("This device does not have any registered destinations.")
		return 0
	end
	
	local slot1 = item:get_var("slot1_name", "Slot 1: Not registered")
	local slot2 = item:get_var("slot2_name", "Slot 2: Not Registered")
	local slot3 = item:get_var("slot3_name", "Slot 3: Not Registered")
	local slot4 = item:get_var("slot4_name", "Slot 4: Not Registered")
	
	local menu = game.create_uimenu()
	menu.title = "Delete which registered location?"
	menu:addentry(slot1)
	menu:addentry(slot2)
	menu:addentry(slot3)
	menu:addentry(slot4)
	menu:addentry("Cancel")
	
	menu:query(true)
	local choice = menu.selected
	
	if choice == 4 then
		message("No registered locations were deleted.")
		return
	end
	
	local slot_id = "slot".. tostring( math.floor( menu.selected + 1 ) ).."_name"
	local is_registered = item:has_var(slot_id)

	if not is_registered then
		message("The selected transfer location does not exist")
		return
	end
	
	local slot_name = item:get_var(slot_id)
	if not game.query_yn(string.format("Are you sure you want to unregister the link to %s?", slot_name)) then
		message("No registered locations were deleted.")
		return
	end
	
	item:set_var("save_count", math.floor( save_count - 1 ) )
	item:erase_var(slot_id)
	
	message("The registration of %q was removed.", slot_name)
end

function iuse_trs_regist(item, active)
	local slot1 = item:get_var("slot1_name", "Slot 1: Not Registered")
	local slot2 = item:get_var("slot2_name", "Slot 2: Not Registered")
	local slot3 = item:get_var("slot3_name", "Slot 3: Not Registered")
	local slot4 = item:get_var("slot4_name", "Slot 4: Not Registered")
	
	local menu = game.create_uimenu()
	menu.title = "Register this location to which slot?"
	menu:addentry(slot1)
	menu:addentry(slot2)
	menu:addentry(slot3)
	menu:addentry(slot4)
	menu:addentry("Cancel")
	
	menu:query(true)
	local choice = menu.selected
	
	if choice == 4 then
		message("No location was registered.")
		return
	end
	
	local slot_num = math.floor( menu.selected + 1 )
	local slot_id = "slot"..tostring( slot_num )
	
	local is_saved = item:has_var(slot_id.."_name")
	if is_saved then
		local save_name = item:get_var(slot_id.."_name")
		if not game.query_yn(string.format("There is already a registered location in this slot, with the name %s. Delete it?", save_name)) then
			message("No location was registered.")
			return
		end
	end
	
	local slot_name
	local ask_for_name = true
	
	while ask_for_name do
		slot_name = game.string_input_popup("Enter a name for this destination.", 16, "Names can be up to 16 standard characters.")
		
		if slot_name ~= "" then
			ask_for_name = false
		end
	end
	
	local om = player:global_omt_location()
	local gpos = player:global_square_location()
	
	local save_count = item:get_var("save_count", 0)
	item:set_var("save_count", math.floor( save_count + 1 ))
	
	item:set_var(slot_id.."_name", slot_name)
	item:set_var(slot_id.."_omx", tostring(om.x))
	item:set_var(slot_id.."_omy", tostring(om.y))
	item:set_var(slot_id.."_omz", tostring(om.z))
	item:set_var(slot_id.."_gx", tostring(gpos.x))
	item:set_var(slot_id.."_gy", tostring(gpos.y))
	item:set_var(slot_id.."_gz", tostring(gpos.z))

	message("The current location has been registered in slot %d with the name: %s", slot_num, slot_name)
end

function iuse_trs_translocator(item, active)
	if requires_charges and item.charges < req_power_gate then
		message("Insufficient charge. Teleportation requires at least %d power.", req_power_gate)
		return
	end
    
	local save_count = item:get_var("save_count", 0)
	local is_linked = item:has_var("gate_name")
	if save_count == 0 and not is_linked then
		message("There are no valid registered destinations.")
		return
	end
	
	local on_warpgate = standing_on_warpgate()
	if on_warpgate then
		message("<color_light_green>You are standing in an active warpgate. Outgoing teleportation energy cost to registered locations will be halved, and chance of accident will be reduced.</color>")
	end

	local gate_link	
	local slot1 = item:get_var("slot1_name", "Slot 1: Not Registered")
	local slot2 = item:get_var("slot2_name", "Slot 2: Not Registered")
	local slot3 = item:get_var("slot3_name", "Slot 3: Not Registered")
	local slot4 = item:get_var("slot4_name", "Slot 4: Not Registered")
	
	if is_linked then
		gate_link = "Linked Warpgate"
	else
		gate_link = "No Warpgate Registered"
	end
	
	local menu = game.create_uimenu()
	menu.title = "Where do you want to teleport?"
	menu:addentry(gate_link)
	menu:addentry(slot1)
	menu:addentry(slot2)
	menu:addentry(slot3)
	menu:addentry(slot4)
	menu:addentry("Cancel")
	
	menu:query(true)
	local choice = menu.selected
	
	if choice == 5 then
		message("Warp procedure aborted.")
		return
	end
	
	if requires_charges and choice ~= 0 and item.charges < req_power_location and not on_warpgate then
		message("Insufficient charge. Teleportation to a memorized non-warpgate destination requires %d power.", req_power_location)
		return
	end

	local slot_id
	if choice == 0 then
		slot_id = "gate"
	else
		slot_id = "slot"..tostring( math.floor( choice ) )
	end
	
	if not item:has_var(slot_id.."_name") then
		message("The selected warp destination is not registered.")
		return
	end

	local omx = tonumber(item:get_var(slot_id.."_omx", "0"))
	local omy = tonumber(item:get_var(slot_id.."_omy", "0"))
	local omz = tonumber(item:get_var(slot_id.."_omz", "0"))
	local gx = tonumber(item:get_var(slot_id.."_gx", "0"))
	local gy = tonumber(item:get_var(slot_id.."_gy", "0"))
	local gz = tonumber(item:get_var(slot_id.."_gz", "0"))
	local om = tripoint(omx, omy, omz)
	local gpos = tripoint(gx, gy, gz)

	g:place_player_overmap(om)
	local cur_gpos = player:global_square_location()
	local cur_pos = player:pos()

	-- player:pos()で取得できる座標はバッファ上の一時的な座標なので、 [Since the coordinates that can be acquired in the buffer are temporary coordinates on the buffer,]
	-- global_square_locationで絶対座標を取得して補正する  [Get absolute coordinates and correct them]
	local delta = tri_delta(cur_gpos, gpos)
	player:setx(cur_pos.x - delta.x)
	player:sety(cur_pos.y - delta.y)
	player:setz(cur_pos.z - delta.z)
	
	g:reload_npcs()

	message("The fabric of the world shifts like loose cloth, and when it gradually returns to focus, you're somewhere else.")
	
	if choice == 0 or on_warpgate then
		item.charges = item.charges - req_power_gate
	else
        item.charges = item.charges - req_power_location
	end
	
	if enable_penalty and game.one_in(10) then
		if choice == 0 then
			return
		end
        if on_warpgate and game.one_in(2) then
            return
        end
		
		apply_penalty(item)
	end
	
	return 0
end

function apply_penalty(item)
	if game.one_in(2) then
		message("<color_yellow>That last jump made you feel a little sick.</color>")
		player:add_effect(efftype_id("teleglow"), TURNS(600))
		return
	end
	
	if game.one_in(2) then
		message("<color_yellow>That last jump messed something up inside you.</color>")
		player:add_effect(efftype_id("teleglow"), TURNS(3600))
		return
	end
	
	if game.one_in(3) then
		message("<color_red>Your whole body hurts, down to your bones. It feels like you've left a piece of yourself behind.</color>")
		player:apply_damage(player, "bp_torso", game.rng(1,15))
		player:apply_damage(player, "bp_head", game.rng(1,15))
		player:apply_damage(player, "bp_arm_l", game.rng(1,15))
		player:apply_damage(player, "bp_arm_r", game.rng(1,15))
		player:apply_damage(player, "bp_leg_l", game.rng(1,15))
		player:apply_damage(player, "bp_leg_r", game.rng(1,15))
		return
	end
    
    if game.one_in(3) then
        message("<color_red>Something went very, very wrong in that last jump. When you came back from the warp, something came with you.</color>")
        player:mutate()
    end
	
	if game.one_in(10) then
		message("The translocator is billowing smoke!\n<color_red>All registered non-warpgate destinations got wiped out in the last jump!</color>")
		item:set_var("slot1_name", "null")
		item:set_var("slot2_name", "null")
		item:set_var("slot3_name", "null")
		item:set_var("slot4_name", "null")
		return
	end
end

game.register_iuse("IUSE_TRS_A_TRANSLOCATOR", iuse_trs_translocator)
game.register_iuse("IUSE_TRS_B_REGIST", iuse_trs_regist)
game.register_iuse("IUSE_TRS_C_DELETE", iuse_trs_delete)
game.register_iuse("IUSE_TRS_D_LINK", iuse_trs_link)
game.register_iuse("IUSE_TRS_E_LOOSE_TELEPORT", iuse_trs_loose_teleport)
