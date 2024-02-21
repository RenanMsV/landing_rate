var LOG_ALERT    = 5;
var COLOR_WHITE  = { r:   1, g:   1, b: 1 };
var COLOR_RED    = { r:   1, g:   0, b: 0 };
var COLOR_ORANGE = { r:   1, g: .65, b: 0 };
var COLOR_YELLOW = { r:   1, g: .95, b: 0 };
var COLOR_LIME   = { r: .64, g:   1, b: 0 };
var COLOR_GREEN  = { r:   0, g:   1, b: 0 };

var LANDING_RANK = [
    {
        name   : "Bad",
        minFpm : 600,
        color  : COLOR_RED,
    },
    {
        name   : "Acceptable",
        minFpm : 400,
        color  : COLOR_ORANGE,
    },
    {
        name   : "Good",
        minFpm : 200,
        color  : COLOR_YELLOW,
    },
    {
        name   : "Very Good",
        minFpm : 100,
        color  : COLOR_LIME,
    },
    {
        name   : "Excellent",
        minFpm : 0,
        color  : COLOR_GREEN,
    },
];

var window = screen.window.new(10, 10, 3, 10); # create new window object, x = 10, y = 10, maxlines = 3, autoscroll = 10
window.bg = [0, 0, 0, .5]; # black alpha .5 background
var aglFt = 20; # agl trigger temporary 20.

var initLandingRateTimer = func (addon) {
    var addonNodePath = addon.node.getPath();

    var landingRateProps = [ # addon props array
        addonNodePath ~ "/addon-devel/rate-fpm",
        addonNodePath ~ "/addon-devel/rate-mts",
        addonNodePath ~ "/addon-devel/g-force",
        addonNodePath ~ "/addon-devel/landed",
        addonNodePath ~ "/addon-devel/altTrig",
    ];

    # init addon props array
    foreach (var prop; landingRateProps) {
        props.globals.initNode(prop, 0, nil);
    }

    var gearProps = [ # gear props array
        "/gear/gear[0]/wow",
        "/gear/gear[1]/wow",
        "/gear/gear[2]/wow",
    ];

    # set gear props listeners
    foreach (var prop; gearProps) {
        setlistener(prop, func (node) {
            var isLanded = node.getBoolValue() and !getprop(addonNodePath ~ "/addon-devel/landed");
            setprop(addonNodePath ~ "/addon-devel/landed", isLanded);
        }, 0, 0); # startup = 0 (default), runtime = 0 (only when value change)
    }

    # setting up altTrigg timer
    var altTrigger = maketimer(1, func {
        if (getprop("/position/altitude-agl-ft") > aglFt) {
            setprop(addonNodePath ~ "/addon-devel/altTrig", 1);
        }
    });
    altTrigger.start(); # starting alt trigg list

    # setting up message listener, send message when land
    setlistener(addonNodePath ~ "/addon-devel/landed", func (node) {
        if (node.getValue() and getprop(addonNodePath ~ "/addon-devel/altTrig")) {
            setprop(addonNodePath ~ "/addon-devel/altTrig", 0);

            sendLandingMessage(
                addon,
                getprop("/accelerations/pilot-gdamped"),
                getprop("/instrumentation/vertical-speed-indicator/indicated-speed-fpm"),
                getprop("/instrumentation/vertical-speed-indicator/indicated-speed-mps")
            );
        }
    });
};

var sendLandingMessage = func (addon, g, fpm, mps) {
    var fpmAbsolute = math.abs(fpm); # get fpm with no minus sign

    # send message by landing rate, using LANDING_RANK table
    foreach (var rank; LANDING_RANK) {
        if (fpmAbsolute >= rank.minFpm) {
            printScreenMsg(
                addon,
                sprintf("%s Landing! Fpm: %.3f Mps: %.3f G-Force: %.1f", rank.name, fpm, mps, g),
                rank.color
            );

            break;
        }
    }
};

var printScreenMsg = func (addon, msg, color) {
    window.write(msg, color.r, color.g, color.b); # print message with color arg.
    logprint(LOG_ALERT, "Last Land: ", msg); # print message in case user need it later

    # send mp message if allowed
    if (getprop(addon.node.getPath() ~ "/addon-devel/sharemp")) {
        setprop("/sim/multiplay/chat", "My landing rate was: " ~ msg);
    }
};

var printPersistentScreenMsg = func (msg, color, time) {
    window.autoscroll = time; # setting message to be show for "time"" seconds
    window.write(msg, color.r, color.g, color.b); # print message with color arg.
};

var checkCompatibility = func {
     # checking nil props
    if (getprop("/accelerations/pilot-gdamped") == nil or
        getprop("/instrumentation/vertical-speed-indicator/indicated-speed-fpm") == nil or
        getprop("/instrumentation/vertical-speed-indicator/indicated-speed-mps") == nil
    ) {
        return 0;
    }

    return 1; # success
};

var evaluateLandingRateAddonhints = func {
    # evaluate addon-hints
    # for hints properties, we treat the rank name as lowercase and convert spaces to dashes
    foreach (var rank; LANDING_RANK) {
        var rank_prop_name = "/sim/addon-hints/landing_rate/ranks/"
            ~ string.replace(string.lc(rank.name), " ", "-");

        var rank_prop_val_minfpm = getprop(rank_prop_name ~ "/min-fpm");
        if (rank_prop_val_minfpm != nil) {
            if (string.scanf(rank_prop_val_minfpm, "%f", var r=[])) {
                rank.minFpm = rank_prop_val_minfpm;
                logprint(LOG_DEBUG, "Landing Rate Addon: addon-hint '" ~ rank.name ~ "' minFpm set to " ~ rank_prop_val_minfpm);
            } else {
                logprint(LOG_ALERT, "Landing Rate Addon: addon-hint invalid format (not a number) in " ~ rank_prop_name );
            }
        } else {
            logprint(LOG_DEBUG, "Landing Rate Addon: addon-hint '" ~ rank.name ~ "' ignored nil value");
        }
    }
};

var main = func (addon) {
    # Must be _setlistener because removelistener doesn't work well with setlistener
    var fdmInitListener = _setlistener("/sim/signals/fdm-initialized", func {
        if (getprop("/sim/signals/fdm-initialized")) {
            # checking compatibility, set agl trigger by current agl.
            if (checkCompatibility()) {
                evaluateLandingRateAddonhints();

                aglFt = getprop("/position/altitude-agl-ft") + 6;

                initLandingRateTimer(addon); # init addon
                removelistener(fdmInitListener);

                printPersistentScreenMsg("Landing Rate Addon Loaded", COLOR_WHITE, 20); # success
                print("Landing Rate addon loaded."); # success

            } else {
                # prints persistent message, white, 30 sec
                printPersistentScreenMsg("Aircraft not compatible with Landing Rate addon. Sorry about that.", COLOR_WHITE, 30);

                # die addon, quit script with custom message.
                logprint(LOG_ALERT, "Landing Rate addon shutdown. Aircraft not compatible with Landing Rate addon. Sorry about that.");
            }
        }
    });
};
