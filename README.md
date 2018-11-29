Translocators
===

This mod allows instantaneous long-range travel at a high price. It requires lots of setup and only works on the player character.

This mod uses LUA and may become unstable in future versions.
Always save and backup your worlds before adding any mods, LUA or otherwise, and prepare for the possibility of crashes.

To get started with creating translocators, you will need Electronics skill at 7 and 8 for certain recipes, as well as rare items to create the necessary structures.


How To Use:
===
The translocator is built with what is functionally an lifetime atomic energy supply, but converts power slowly, at a rate of roughly 1 charge per hour, with a maximum storage of 24 charges. With the right components, you can upgrade to the Translocator Mk.II, which can store 36 charges.

The translocator has several options:
1. Warp to registered destination
  This begins the teleportation sequence and will consume 12 power to transport the player. If you choose to teleport to a linked warpgate, OR while standing on any active warpgate, the cost will be reduced to 6.

2. Register warp destination
  Registers a location as a destination for future teleports. Up to 4 destinations can be registered at a time. Doesn't consume charge.
  
3. Delete warp destination
  Removes a destination that was already registered. Doesn't consume charge.
  
4. Link with warpgate
  This will register a constructed warpgate as a destination for future teleports. Normal destinations and warpgate destinations are kept in two separate lists. Doesn't consume charge.
  
5. Blind Leap
  At the cost of a full charge of 24 power, you can forego teleporting to a registered location and manually choose a map tile as your destination, warping there instantly. However, this process is imprecise and extremely dangerous. Teleporting inside a solid object or a living creature could be fatal, and additionally, the likelihood of accident and negative warping side effects are doubled.
  
  
Warpgate
===
Warpgates are expensive to build, but for repeat visits, may be worth constructing.
Stand here when using the translocator and you can link the warpgate. This will avoid occupying one of the four standard transfer slots, and jumps here will take only half power. Jumping to warpgates will also completely remove the chance of negative warping side effects and accidents (see below).
*Warpgates also provide benefits if you stand on them while teleporting elsewhere. See above.
A translocator can only be linked to one gate at a time, so it's best used for a home base style location you need to return to frequently.

Warpgates are built via the construction menu (*) and are built in two stages:
 Phase 1: Warpgate Base
   At this stage, the warpgate is still nonfunctional.
 Phase 2: Transfer Warpgate
   There are two methods for opening the gate, but the result is the same. 
  
  
Dangers of Warping
===
When you warp, there is always a possibility of danger. This is much higher than normal when performing a Blind Leap, and much lower than normal if warping to a constructed warpgate.
When things DO go wrong, there are several possible consequences to unsafe warping:

*In some cases, you may experience "Teleglow" sickness, ranging from mild to severe.
*In rare cases, you may take damage across your entire body as a result of inaccurate teleportation.
*Damage to translocator: In very rare cases, the translocator itself will be damaged and lose all registered destinations, making it potentially quite difficult to get home. However, even when this happens, warpgate destinations WILL NOT BE LOST, so you will always be able to return to a registered warpgate reliably, even when things go wrong. (Assuming you are alive.)
*When performing a Blind Leap, the possibility exists of teleporting directly into a wall, mass of stone, etc. A "telefrag" like this can be fatal. Use Blind Leaps only with extreme caution and under special circumstances.


Customizing
===
This mod allows for several options to be customized by the user. Open preload.lua in the mod folder and you can find the following options at the start of the file, set to their default values, which you can change at will:
* local enable_penalty = true : Whether or not accidents can happen when warping. Set to false to remove negative warping penalties.
* local requires_charges = true : Whether teleporting costs power. Set to false to make all teleporting free.
* local ter_warpgate_id = "t_TRS_stabilized_portal" : The ID of the tile used as a warpgate. By default, this is set to a new and expensive construction added by this mod. If you know the ID of another terrain tile, you could use that here instead. For example, you could make beds function as warpgates.
* local req_power_gate = 6 : Cost of teleporting to or from a warpgate.
* local req_power_location = 12 : Cost of teleporting to a non-warpgate location when not standing on a warpgate.
* local req_power_blind_leap = 24 : Cost of making a Blind Leap to an unregistered location.

When changing costs, keep in mind the default translocator holds a max of 24 charges, and the MkII a max of 36, with both regaining 1 charge per hour.


About this mod:
===
This mod was taken from the Japanese CDDA Wiki and redistributed with permission, as granted within the original readme.
The original author was not named in the modinfo file, and may have opted to post anonymously. If this is in error, please send correction.
Translation and conversion provided by TGWeaver.
Special thanks to Dutchs for streamlining, cleaning, and more!
