# Godot XR Handtracking toolkit

![Hand Recognization Demo](demos/hand_recognization.gif)
![Picking Object Demo](demos/picking.gif)


## GENERAL INFORMATION

- Latest tested Godot version: v4.1.beta2.official.a2575cba4
- Tested headset: Meta Quest 2

You can find the example scene in example/main_scene.tscn

## WHAT THIS TOOLKIT PROVIDES:

- **Modules to work with hand poses:**

	- PoseRecordingRoom: Create your own templates of hand poses as JSON, and use them for recognization.
	
	- HandPoseMatcher: Match tracked-hand pose to a pose from JSON templates in realtime.

- **Module for object picking:**
	
	- XRPickArea: Defines where object can be picked and what hand pose allows picking.
	
	- XRHandSnap: Helps snapping object's transform to hand's when object is picked 

	- XRPickupFunction: Attach to OpenXRHand's Skeleton. Supports 3 pickup modes:
		
		- *On pose change*: Change your hand pose to one of XRPickupArea pickup poses to pick up object. Useful for grabbing gesture.
		
		- *On touch*: Touches the XRPickArea and hand pose is one of touch-pick poses, the object gets picked up. 
			
		- *Ranged pickup*: Work like *On pose change*, but use Raycast.  

	- XRPickableRigidBody: Defines picked-up behaviors. You can customize its picked-up movement here to fit your needs.
	
- **A keyboard with floating buttons.** (This was actually the whole point for my graduation research).

## WHAT THIS TOOLKIT LACKS:

- Pickup doesn't work with controllers. 
- Closest-object highlighting.
- Good physics for hand.

## CREDITS

**3D assets licensed under Creative Commons Attribution:**

- "Grand Inquisitor Lightsaber" - RealKermitDaFrog 
- "sci-fi hologram table" - irzafy
- "Hologram" - "KangaroOz 3D"
- "Battle Droid B2" - Andrés Kuiper
- "DC-15" - KO71K
- "Star Wars: The Clone Wars: Venator Prefab" - ShineyFX
- "Gaming Table" - chayaruar
- "Ammo box" - Hurricane

**Sound effects:** Pixabay

Ideas and implementations inspired by these two awesome Godot XR toolkits:
- https://github.com/patrykkalinowski/godot-xr-kit
- https://github.com/GodotVR/godot-xr-tools

## Final Notes:
This toolkit was made by Trần Lâm - Revol Noom.
Further updates are unlikely as I'm moving to Unity. Godot is cool and all, but no one hires Godot developers out there. *sad

