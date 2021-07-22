# ComputerCraft <> LaunchDarkly integration

AKA the "Minecraft SDK"

## Background

In Minecraft there are lever items which you can use to control the on/off state of many things. You can use another item called "Redstone Dust" which allows you to basically run wires to control things from a distace. You can open/close doors, turn lights on/off, or even detonate TNT.

Minecraft has a large modding community. One mod called ComputerCraft adds lua-programable computers which you can use instead of lever. You can also make web requests using ComputerCraft, meaning it's possible to communicate with the endpoints that the LaunchDarkly SDK uses.

This repository is a is a collection of scripts/libraries for ComputerCraft which allow various interactions between LaunchDarkly and your Minecraft world, and allows you to use LaunchDarkly in your own ComputerCraft Lua scripts.

## What this is not

This may change at some point in the future as I continue to develop this integration, but this should not be considered an example of a proper LaunchDarkly SDK for use in a real production environment, or even anywhere. I won't go into all of the reasons why here, but if you're interested in developing a propper SDK, consult the LaunchDarkly contributors guide here as a first step: https://docs.launchdarkly.com/sdk/concepts/contributors-guide

## Requirements

### Minecraft

If you don't have Minecraft, you can purchase it here: 

### ComputerCraft

### Lua Requirements

I reccomend using CCC to easily install the scripts in this repository and all of their dependencies. CCC is a dependency manager I built. There is no community standard dependency manager, so might as well use mine! To get started with CCC, go here:

There are two requirements that are not included in this repository:
### JSON

The LD Client needs to encode the user object as JSON, and needs to decode JSON responses from LaunchDarkly.

- The LD Client expects there the be a `json.lua` file saved to the computer.
- The LD Client expects the loaded `json` table to have a `encode` method that returns the first argument encoded as JSON.
- The LD Client expects the loaded `json` table to have a `decode` method that returns the first argument decoded as a table.

Tested using: https://github.com/rxi/json.lua/blob/master/json.lua


### Base64

The LD Client needs to encode the user object as base64 when interacting with the LaunchDarkly SDK endpoints.

- The LD Client expects there the be a `base64.lua` file saved to the computer.
- The LD Client expects the loaded `base64` table to have a `encode` method that returns the first argument as base64.

Tested using: https://stackoverflow.com/questions/34618946/lua-base64-encode

## Getting Started

### LD Client SDK

### LD Configuration UI

### LD Redstone Provider

### CCC configuration files

