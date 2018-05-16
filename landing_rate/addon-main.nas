SHARE_RATE_MP = getprop("sim/addons/landing-rate/sharemp"); # send mp message when land

#--------------------------------------------------

landing_rank = [ ["Excellent", 0, [0, 1, 0]],["Very Good", 100, [0, 1, 0]], ["Good", 200, [1, 0.90, 0]], ["Acceptable", 400, [1, .64, 0]], ["Bad", 600, [1, 0, 0]] ]; # [description, minFPM, [r, g, b]]

var window = screen.window.new(10, 10, 3, 10); # create new window object. 750, 10 : Lower Right
window.bg = [0,0,0,.5]; # black alpha .5 background
var agl_ft = 20; # agl trigger temporary 20.
var agl_list = _setlistener("sim/signals/fdm-initialized", func { removelistener(agl_list); settimer(func () { checkCompatibility(); agl_ft = getprop("position/altitude-agl-ft") + 6; }, 3); } ); # setting up agl listener, checking compatibility,  set agl trigger by current agl.

var init_landing_rate_timer = func {
	gear_props = ["gear/gear[0]/wow", "gear/gear[1]/wow", "gear/gear[2]/wow"]; # gear props array
	landing_rate_props = ["sim/addons/landing-rate/rate-fpm", "sim/addons/landing-rate/rate-mts", "sim/addons/landing-rate/g-force", "sim/addons/landing-rate/landed", "sim/addons/landing-rate/altTrig"];  # addon props array
	forindex (var i; landing_rate_props) props.globals.initNode(landing_rate_props[i], 0, nil); # init addon props array
	forindex(var i; gear_props) _setlistener(gear_props[i], func { if(getprop(gear_props[i]) and !getprop("sim/addons/landing-rate/landed")) setprop("sim/addons/landing-rate/landed", 1); else setprop("sim/addons/landing-rate/landed", 0); }); # set gear props listeners
	altTrigger = maketimer(1, func () {if (getprop("position/altitude-agl-ft") > agl_ft) setprop("sim/addons/landing-rate/altTrig", 1); }); # setting up altTrigg timer
	altTrigger.start(); # starting alt trigg list
	message = _setlistener("sim/addons/landing-rate/landed", func { if(getprop("sim/addons/landing-rate/landed") and getprop("sim/addons/landing-rate/altTrig")) { setprop("sim/addons/landing-rate/altTrig", 0); send_landing_message(getprop("accelerations/pilot-gdamped"), getprop("instrumentation/vertical-speed-indicator/indicated-speed-fpm"), getprop("instrumentation/vertical-speed-indicator/indicated-speed-mps")); } }); # setting up message listener, send message when land
}

var send_landing_message = func (g, fpm, mps){
	f = fpm * -1; # get fpm with no (-)
	forindex(var i; landing_rank){
		index = (size(landing_rank) - 1) - i; # from last to first array index
		if(f >= landing_rank[index][1]) return print_screen_msg(landing_rank[index][0] ~ " Landing! Fpm: " ~ sprintf("%.3f", fpm) ~ " Mps: " ~ sprintf("%.3f", mps) ~ " G-Force: " ~ sprintf("%.1f", g), landing_rank[index][2]); # send message by landing rate, using landing_rank table
	}
}

var print_screen_msg = func (msg, indexColor) {
	window.write(msg, indexColor[0], indexColor[1], indexColor[2]); # print message with color arg.
	print("Last Land: " ~ msg); # print message in case user need it later
	if (SHARE_RATE_MP) send_mp_msg(msg); # send mp message if allowed
}

var send_mp_msg = func (msg) {
	setprop("sim/multiplay/chat", "My landing rate was: " ~ msg);
}

var print_persistent_screen_msg = func (msg, indexColor, time) {
	window.autoscroll = time; # setting message to be show for 30 seconds
	window.write(msg, indexColor[0], indexColor[1], indexColor[2]); # print message with color arg.
	settimer(func(){window.autoscroll = 60;}, time); # setting message to be show for 60 seconds (default)
}

var checkCompatibility = func {
	if(getprop("accelerations/pilot-gdamped") == nil or getprop("instrumentation/vertical-speed-indicator/indicated-speed-fpm") == nil or getprop("instrumentation/vertical-speed-indicator/indicated-speed-mps") == nil) { # checking nil props
		print_persistent_screen_msg("Aircraft not compatible with Landing Rate addon. Sorry about that.", [1, 1, 1], 30); # prints persistent message, white, 30 sec
		die("Landing Rate addon shutdown. Aircraft not compatible with Landing Rate addon. Sorry about that."); # die addon, quit script with custom message.
	}
	print_persistent_screen_msg("Landing Rate Addon Loaded", [1,1,1], 20); # success
	print("Landing Rate addon loaded."); # success
}

var main = func ( root ) {
	var fdm_init_listener = _setlistener("/sim/signals/fdm-initialized", func {
		removelistener(fdm_init_listener);
		init_landing_rate_timer(); # init addon
	});
};  # main ()