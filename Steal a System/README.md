# Steal a [ system ];

Made by kts;

Completed on **10/7/2025**;

### Notes

For any bug dm me;

# Background

It took a week to make in total; ( not including breaks ); 

Its a very easy-to-customize system made with Knit framework, it is a bit complex at some parts but I kept it clean;

# Modifying

## Changing the steal arrow;

In this image you'll see the 'arrow' object; If you want to change it, delete the old one and replace it with the new one; NOTE: rename it to 'arrow'!!

<img width="148" height="75" alt="image" src="https://github.com/user-attachments/assets/96bb967f-c60e-42a9-96c2-8b6690076a28" />

### <ins>Editing the config;</ins>

Here's the actual module, in there you'll find simple settings adjusted to my preference, you can edit them w ease. DM me if you dont know how;

<img width="195" height="180" alt="image" src="https://github.com/user-attachments/assets/1a0f7ae6-a70d-4522-ac5d-530aecbee4d9" />

## Adding new NPCs or removing existing ones;

If you want to add new NPCs you have to follow 2 simple steps: 
> Edit the config module

> Importing the NPC model in npc assets

### Editing the config module

You'll want to enter the script shown in the image and then remove the existing NPCs or adding new ones following this format:

``` LuaU

    [1]={ -- [1] is an indexer, i recommend using them in an order like 1,2,3,4,5, etc...
      Name='name'; -- this will act as an identifier
      Chance=70; -- you can modify this to your will
      Color=Color3.fromRGB(89, 255, 0);
      Price=5;
      Earnings=1; -- 1$/s; this will be the player's cash per second.
    };

```

NOTE! The name must be **exactly** as the NPC model, and when you modify the chances for either the npc, ensure they all sum up to 100 for a better system, same for the categories;

Also try not to overlap the names.

<img width="212" height="167" alt="image" src="https://github.com/user-attachments/assets/bed47dd8-3a2a-480d-839e-3cb7001781fa" />

### Importing a new NPC or deleting one.

You'll want to open this folder and add a new NPC; this can be used as a NPC storage too as long as the NPC isnt mentioned in the config file.

<img width="225" height="126" alt="image" src="https://github.com/user-attachments/assets/53d02102-7ed5-49b5-b4f5-3bdeff7068a2" />

# Video

https://github.com/user-attachments/assets/01c8c6ec-7fe2-425b-b864-1a0d912ef0b6
