#
# Addon Nasal file for additional configs.
# We have it outsourced, in order to separate the main code from
# internal config logic (the main code remains cleaner).
#
var LANDING_RANK_CFG = props.Node.new({

    # Table for guessing landing rates from optionally set ICAO data in aircraft.xml
    # in "/aircraft/icao/wake-turbulence-category" (J, H, M, L)
    # see https://skybrary.aero/articles/icao-wake-turbulence-category
    "icao-wake-turbulence-category": {
        L: {
            ranks: {
                "bad":        {"min-fpm":300},
                "acceptable": {"min-fpm":200},
                "good":       {"min-fpm":100},
                "very-good":  {"min-fpm":50}
            }
        },
        # TODO: need better data for these!
        M: {
            ranks: {
                "bad":        {"min-fpm":400},
                "acceptable": {"min-fpm":300},
                "good":       {"min-fpm":200},
                "very-good":  {"min-fpm":100}
            }
        },
        H: {
            ranks: {
                "bad":        {"min-fpm":600},
                "acceptable": {"min-fpm":400},
                "good":       {"min-fpm":200},
                "very-good":  {"min-fpm":100}
            }
        },
        J: {
            ranks: {
                "bad":        {"min-fpm":600},
                "acceptable": {"min-fpm":400},
                "good":       {"min-fpm":200},
                "very-good":  {"min-fpm":100}
            }
        }
    },

    # Table for specific Aircraft types in "/sim/aircraft"
    # (this is an addon-side alternative for addon-hints from the aircraft)
    "aircraft-types": {
        "ask21-jsb": {
            ranks: {
                "bad":        {"min-fpm":120},
                "acceptable": {"min-fpm":80},
                "good":       {"min-fpm":50},
                "very-good":  {"min-fpm":35}
            }
        }
    },

});
