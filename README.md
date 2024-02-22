# FlightGear Landing Rate addon
Show your landing stats. Depending on your rate of descent on touching the ground it rates your landing as Excellent, Good, Acceptable, or Bad.
Slightly modified by PO to make it compatible with more recent version of FG.


![Example](https://i.imgur.com/PwOQYFI.jpg)

### Requirements

FlightGear 2018.2 version.

### Install Procedures

Unzip landing_rate folder to any place you want. e.g C:\Users\USERNAME\FlightGear\Addons\landing_rate

Then add this command line to your FlightGear Shortcut :

--addon="C:\Users\USERNAME\FlightGear\Addons\landing_rate"

Remember to replace USERNAME with your OS username.
Note that this command line must have the correct path to the landing_rate folder.
Do not know how to set command lines? Check here: http://wiki.flightgear.org/Command_line

### Dealing with errors

Since each plane are different, for now 90% of aircrafts are compatible.
If you're using an incompatible aircraft a message will be show. And the addon will be shutdown.

![ErrorExample](https://i.imgur.com/20NlJdQ.jpg)

### Share stats at mp chat

If you want, you can activate it. And a message will be sent by multiplayer chat showing your landing stats.

To enable it go to landing_rate folder and open addon-config.xml. Find sharemp line.

```<sharemp>0</sharemp>```

Change sharemp value (1 for yes and 0 for no). Restart your simulator. Done.


### Aircraft developer info

#### Compatibility
To make the plane compatible, it should initialize and calculate the following properties:

- `/accelerations/pilot-gdamped`
- `/instrumentation/vertical-speed-indicator/indicated-speed-fpm`
- `/instrumentation/vertical-speed-indicator/indicated-speed-mps`


#### Overriding landing category limits

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

Valid `<ranks>` tags are: `bad`, `acceptable`, `good`, `very-good`, `excellent`. Use `fgfs --log-level=debug --log-class=nasal` to see what is actually loaded.