# ComputerCraft <> LaunchDarkly integration

AKA the "Minecraft SDK"

## Background

In Minecraft there are lever items which you can use to control the on/off state of many things. You can use another item called "Redstone Dust" which allows you to basically run wires to control things from a distace. You can open/close doors, turn lights on/off, or even detonate TNT.

Minecraft has a large modding community. One mod called ComputerCraft adds lua-programable computers which you can use instead of lever. You can also make web requests using ComputerCraft, meaning it's possible to communicate with the endpoints that the LaunchDarkly SDK uses.

This repository is a is a collection of scripts/libraries for ComputerCraft which allow various interactions between LaunchDarkly and your Minecraft world, and allows you to use LaunchDarkly in your own ComputerCraft Lua scripts.

## What this is not

This may change at some point in the future as I continue to develop this integration, but this doesn't follow the specs defined by LaunchDarkly for an SDK. It isn't possible to achieve some core features of an SDK, and shouldn't be used as an example for a good custom SDK. If you're interested in developing a propper SDK, or are interested in the official specs, consult the LaunchDarkly contributors guide here as a first step: https://docs.launchdarkly.com/sdk/concepts/contributors-guide

