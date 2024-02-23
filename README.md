# FlightGear Landing Rate addon

Landing Rate addon can show your landing stats. Depending on your rate of descent upon touchdown it rates your landing accordingly.

![Example](https://i.imgur.com/PwOQYFI.jpg)

### Features

- Rates your landings.
- Can automatically send your landing rate in a message if you are in a multiplayer server.
- It works with most aircraft by default, without the user having to make modifications or configure it.

### Requirements

FlightGear 2018.2 version.

### How to install Landing Rate addon

Extract the zipped landing_rate folder to any place you want.

e.g `C:\Users\USERNAME\FlightGear\Addons\landing_rate`

`Note: Remember to replace USERNAME with your OS username.`

From now on you have two options. Either will install it successfully. Choose the one you find easier.

#### Option 1 - Installing from the launcher (recommended)

- In the launcher click at the "Add-ons" button.
- Then in the "Add-ons Module folders" section click in the Add button.
- Locate the folder where you have extracted the landing_rate folder and confirm.

Now Landing Rate should appear as an installed add-on.

#### Option 2 - Installing by the command line

Add this command line to your FlightGear shortcut:

`--addon="C:\Users\USERNAME\FlightGear\Addons\landing_rate"`

Do not know how to set command lines? Check here: http://wiki.flightgear.org/Command_line

### Dealing with errors

Since each plane is different, for now most aircrafts are compatible. If you're using an incompatible aircraft a message will be shown and the addon will be disabled.

![ErrorExample](https://i.imgur.com/20NlJdQ.jpg)

### User settings

The settings menu can be found by clicking the Landing Rate option of your menu bar.

#### Send landing stats at multiplayer chat

The addon can automatically send your landing rate in a message if you are in a multiplayer server. You can activate it in the addon settings menu.

`Note: This setting will be persistent across sessions. Some pilots may find these messages disturbing, especially if you are at a busy airport. Use with moderation.`

### For aircraft developers

#### Making sure your aircraft is compatible

To make the plane compatible, it should initialize and calculate the following properties:

- `/accelerations/pilot-gdamped`
- `/instrumentation/vertical-speed-indicator/indicated-speed-fpm`
- `/instrumentation/vertical-speed-indicator/indicated-speed-mps`

`Note: If any of these properties are missing or if they return nil, the addon will be shut down`

The addon also expects your aircraft to have at least one of the following gear properties:

- `/gear/gear[0]/wow`
- `/gear/gear[1]/wow`
- `/gear/gear[2]/wow`

`Note: It might not work as expected if your aircraft has more than 3 gears or if their property ids are greater than 2.`

#### Presets based on ICAO wake turbulence category

If your plane defines the `/aircraft/icao/wake-turbulence-category` property (either `L`, `M`, `H` or `J`), the addon initializes a preset for that category as it guesses the size of the plane.

#### Overriding landing category limits

Its possible that your aircraft needs to override the default rates settings, for example, you can break the gear of the C172p and still get "acceptable" using the default settings.

You can specify addon-hints in your aircraft.xml to override the landing category limits like this:

```xml
<sim>
    <addon-hints>
        <landing_rate>
            <ranks>
                <bad>
                    <min-fpm>150</min-fpm>
                </bad>
            </ranks>
        </landing_rate>
    </addon-hints>
</sim>
```

`Note: addon-hints rates have a higher priority over turbulence category rates`

Valid `<ranks>` tags are: `bad`, `acceptable`, `good`, `very-good`, `excellent`. Use `fgfs --log-level=debug --log-class=nasal` to see what is actually loaded.
