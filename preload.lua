local enable_penalty = true

function message(...)
	local s = string.format(...)
	game.add_msg(s)
end

function tri_delta(a, b)
	return tripoint(a.x - b.x, a.y - b.y, a.z - b.z)
end

function iuse_trs_loose_teleport(item, active)
	if item.charges < 24 then
		message("Insufficient charge. Blind Leaps require a full charge of 24.")
		return
	end
	
	if not game.query_yn("<color_red>This function does not guarantee a safe landing. \n Is that all right?</color>") then
		message("Teleport canceled.")
		return
	end
	
	local target = game.omap_choose_point( player:global_omt_location() )
	
    item.charges = item.charges - 24
    
	g:place_player_overmap(target)

	g:reload_npcs()

	message("The world turns around you, and a new location comes careening into focus.")

	if game.one_in(5) and enable_penalty then
		apply_penalty(item)
	end
end

function iuse_trs_link(item, active)
	local ter_int_id = map:ter(player:pos()):to_i()
	local ter_str_id = game.get_terrain_type(ter_int_id).id:str()
	
	if ter_str_id ~= "t_TRS_stabilized_portal" then
		message("Couldn't find valid warpgate. Please use this item only while standing on a fully activate warpgate.")
		return
	end
	
	local linked = item:get_var("gate_name", "null")
	
	if linked ~= "null" then
		if not game.query_yn("A gate link has already been established. \n Are you sure you want to override the current link?") then
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
	local save_count = tonumber( item:get_var("save_count", "0") )
	if save_count == 0 then
		message("This device does not have any registered destinations.")
		return 0
	end

	local menu = game.create_uimenu()
	
	local slot1 = item:get_var("slot1_name", "null")
	local slot2 = item:get_var("slot2_name", "null")
	local slot3 = item:get_var("slot3_name", "null")
	local slot4 = item:get_var("slot4_name", "null")
	
	if slot1 == "null" then
		slot1 = "Slot 1: Not registered"
	end

	if slot2 == "null" then
		slot2 = "Slot 2: Not Registered"
	end

	if slot3 == "null" then
		slot3 = "Slot 3: Not Registered"
	end

	if slot4 == "null" then
		slot4 = "Slot 4: Not Registered"
	end
	
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
	
	local slot_id = "slot".. tostring( math.floor( menu.selected + 1 ) )
	local select_name = item:get_var(slot_id.."_name", "null")

	if select_name == "null" then
		message("The selected transfer location is unregistered.")
		return
	end
	
	if not game.query_yn(string.format("Are you sure you want to unregister the link to %s?", select_name)) then
		message("No registered locations were deleted.")
		return
	end
	
	save_count = math.floor( save_count - 1 )
	item:set_var("save_count", tostring(save_count))
	item:set_var(slot_id.."_name", "null")
	
	message("The registration of %q was canceled.", select_name)
end

function iuse_trs_regist(item, active)
	local menu = game.create_uimenu()
	
	local slot1 = item:get_var("slot1_name", "null")
	local slot2 = item:get_var("slot2_name", "null")
	local slot3 = item:get_var("slot3_name", "null")
	local slot4 = item:get_var("slot4_name", "null")
	
	menu.title = "Register this location to which slot?"
	if slot1 == "null" then
		slot1 = "Slot 1: Not Registered"
	end

	if slot2 == "null" then
		slot2 = "Slot 2: Not Registered"
	end

	if slot3 == "null" then
		slot3 = "Slot 3: Not Registered"
	end

	if slot4 == "null" then
		slot4 = "Slot 4: Not Registered"
	end
	
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
	
	local saved = item:get_var(slot_id.."_name", "null")
	
	if saved ~= "null" then
		if not game.query_yn(string.format("There is already a registered location in this slot, with the name %s. Delete it?", saved)) then
			message("No location was registered.")
			return
		end
	end
	
	local slot_name = ""
	local flg = true
	
	while flg do
		slot_name = game.string_input_popup("Enter a name for this destination.", 16, "Names can be up to 16 standard characters.")
		
		if slot_name ~= "" and slot_name ~= "null" then
			flg = false
		end
	end
	
	local om = player:global_omt_location()
	local gpos = player:global_square_location()
	
	local save_count = tonumber( item:get_var("save_count", "0") )
	save_count = math.floor( save_count + 1 )
	item:set_var("save_count", tostring(save_count))
	
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

	local ter_int_id = map:ter(player:pos()):to_i()
	local ter_str_id = game.get_terrain_type(ter_int_id).id:str()

	if item.charges < 6 then
		message("Insufficient charge. Teleportation requires at least 6 power.")
		return
	end
    
	if ter_str_id == "t_TRS_stabilized_portal" then
		message("<color_light_green>You are standing in an active warpgate. Outgoing teleportation energy cost to registered locations will be halved, and chance of accident will be reduced.</color>")
	end
	
	local save_count = tonumber( item:get_var("save_count", "0") )
	local linked = item:get_var("gate_name", "null")
	if save_count == 0 and linked == "null" then
		message("There are no valid registered destinations.")
		return 0
	end

	local menu = game.create_uimenu()
	
	local gate_link = item:get_var("gate_name", "null")
	local slot1 = item:get_var("slot1_name", "null")
	local slot2 = item:get_var("slot2_name", "null")
	local slot3 = item:get_var("slot3_name", "null")
	local slot4 = item:get_var("slot4_name", "null")
	
	menu.title = "Where do you want to teleport?"
	
	if gate_link == "null" then
		gate_link = "No Warpgate Registered"
	else
		gate_link = "Linked Warpgate"
	end
	
	if slot1 == "null" then
		slot1 = "Slot 1: Not Registered"
	end

	if slot2 == "null" then
		slot2 = "Slot 2: Not Registered"
	end

	if slot3 == "null" then
		slot3 = "Slot 3: Not Registered"
	end

	if slot4 == "null" then
		slot4 = "Slot 4: Not Registered"
	end
	
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
	
	if choice ~= 0 and item.charges < 12 and ter_str_id ~= "t_TRS_stabilized_portal" then
		message("Insufficient charge. Teleportation to a memorized non-warpgate destination requires 12 power. ")
		return
	end

	local slot_id = "slot"
	
	if choice == 0 then
		slot_id = "gate"
	else
		slot_id = slot_id..tostring( math.floor( choice ) )
	end
	
	if item:get_var(slot_id.."_name", "null") == "null" then
		message("The selected warp destination is unregistered.")
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
	
	if choice == 0 or ter_str_id == "t_TRS_stabilized_portal" then
		item.charges = item.charges - 6
	else
        item.charges = item.charges - 12
	end
	
	if game.one_in(10) and enable_penalty then
		if choice == 0 then
			return
		end
        if ter_str_id == "t_TRS_stabilized_portal" and game.one_in(2) then
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
