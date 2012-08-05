aircraft.livery.init("Aircraft/ATR72/Models/Liveries/" ~ getprop("sim/aero"));

# Start at FMC Page IDENT
fmc.GoToPage("ident");

var get_percent = func(val, max) {

	return (val / max) * 100;

};

var get_degC = func(degF) {

	return (degF - 32) * (5/9);

};

setprop("/instrumentation/fmc/vspeeds/V1", 98);
setprop("/instrumentation/fmc/vspeeds/VR", 112);
setprop("/instrumentation/fmc/vspeeds/V2", 126);
setprop("/instrumentation/fmc/vspeeds/Vs", 145);
setprop("/instrumentation/fmc/vspeeds/Vne", 320);

var nose_wow_sav = 0;
var left_wow_sav = 0;
var right_wow_sav = 0;

var cpy_props = func() {

	if ((getprop("/sim/replay/time") == 0) or (getprop("/sim/replay/time") == nil)) {
	
		setprop("/aircraft/wingflex", getprop("/fdm/jsbsim/aero/force/Lift_alpha"));
		
	}

};

var general_loop_1 = {
       init : func {
            me.UPDATE_INTERVAL = 0.02;
            me.loopid = 0;
            
            setprop("/gear/tilt/left-tilt-deg", 0);
            setprop("/gear/tilt/right-tilt-deg", 0);
            
            me.strobe_count = 0;
            me.beacon_count = 0;
            
            me.reset();
    },
    	update : func {

    	cpy_props();
    	
    	# Strobe Lights
    	
    	if (getprop("/controls/lighting/strobe")) {
    		
    		if ((me.strobe_count == 30) or (me.strobe_count == 31) or (me.strobe_count == 37) or (me.strobe_count == 36)) {
    			setprop("/controls/lighting/strobe-state", 1);
    		} else {
    			setprop("/controls/lighting/strobe-state", 0);
    		}
    		
    		if (me.strobe_count == 40) {
    			me.strobe_count = 0;
    		} else {
    			me.strobe_count += 1;
    		}
    		
    	} else {
    		setprop("/controls/lighting/strobe-state", 0);
    	}
    	
    	# Beacon Lights
    	
    	if (getprop("/controls/lighting/beacon")) {
    		
    		if ((me.beacon_count == 15) or (me.beacon_count == 16) or (me.beacon_count == 17)) {
    			setprop("/controls/lighting/beacon-state", 1);
    		} else {
    			setprop("/controls/lighting/beacon-state", 0);
    		}
    		
    		if (me.beacon_count == 40) {
    			me.beacon_count = 0;
    		} else {
    			me.beacon_count += 1;
    		}
    		
    	} else {
    		setprop("/controls/lighting/beacon-state", 0);
    	}
    	
    	# Convert ITT degF to degC
    	
    	var itt0_degF = getprop("/engines/engine[0]/itt_degf");
    	var itt1_degF = getprop("/engines/engine[1]/itt_degf");
    	
    	setprop("/engines/engine[0]/itt_degc", get_degC(itt0_degF));
    	setprop("/engines/engine[1]/itt_degc", get_degC(itt1_degF));
    	
    	# Convert Oil Temperature degF to degC
    	
    	var oiltemp0 = getprop("/engines/engine[0]/oil-temperature-degf");
    	var oiltemp1 = getprop("/engines/engine[1]/oil-temperature-degf");
    	
    	setprop("/engines/engine[0]/oil-temperature-degc", get_degC(oiltemp0));
    	setprop("/engines/engine[1]/oil-temperature-degc", get_degC(oiltemp1));
    	
    	# Convert Torque and RPM to Percentage
    	
    	var torque0 = getprop("/engines/engine[0]/thruster/prop_torque");
    	var torque1 = getprop("/engines/engine[1]/thruster/prop_torque");
    	
    	var rpm0 = getprop("/engines/engine[0]/thruster/prop_rpm");
    	var rpm1 = getprop("/engines/engine[1]/thruster/prop_rpm");
    	
    	setprop("/engines/engine[0]/thruster/prop_torque-percent", get_percent(torque0, 3800));
    	setprop("/engines/engine[1]/thruster/prop_torque-percent", get_percent(torque1, 3800));
    	
    	setprop("/engines/engine[0]/thruster/prop_rpm-percent", get_percent(rpm0, 1400));
    	setprop("/engines/engine[1]/thruster/prop_rpm-percent", get_percent(rpm1, 1400));
    	
    	# Fuel X-Feed
    	
    	if ((getprop("/controls/engines/x-feed")) and (getprop("/systems/electric/outputs/x-feed"))) {
    	
			var ltank = getprop("/consumables/fuel/tank[0]/level-kg");
			var rtank = getprop("/consumables/fuel/tank[1]/level-kg");
			
			if (ltank > rtank) {
			
				setprop("/consumables/fuel/tank[0]/level-kg", ltank - 0.25);
				setprop("/consumables/fuel/tank[1]/level-kg", rtank + 0.25);
			
			} else {
			
				setprop("/consumables/fuel/tank[0]/level-kg", ltank + 0.25);
				setprop("/consumables/fuel/tank[1]/level-kg", rtank - 0.25);
			
			}
    	
    	}
    	
    	# Autopilot ALT Mode VS Setting
    	
    	if (getprop("/sim/aero") == "ATR72-500") {
    	
			if (getprop("/position/altitude-ft") > 16000) {
			
				setprop("/aircraft/afcs/alt-vs-up", 10);
				setprop("/aircraft/afcs/alt-vs-dn", -8.33);
			
			} elsif (getprop("/position/altitude-ft") > 10000) {
			
				setprop("/aircraft/afcs/alt-vs-up", 20);
				setprop("/aircraft/afcs/alt-vs-dn", -18);
			
			} else {
			
				setprop("/aircraft/afcs/alt-vs-up", 30);
				setprop("/aircraft/afcs/alt-vs-dn", -25);
			
			}
    	
    	} else {
    	
			if (getprop("/position/altitude-ft") > 16000) {
			
				setprop("/aircraft/afcs/alt-vs-up", 8);
				setprop("/aircraft/afcs/alt-vs-dn", -6);
			
			} elsif (getprop("/position/altitude-ft") > 10000) {
			
				setprop("/aircraft/afcs/alt-vs-up", 16);
				setprop("/aircraft/afcs/alt-vs-dn", -12);
			
			} else {
			
				setprop("/aircraft/afcs/alt-vs-up", 25);
				setprop("/aircraft/afcs/alt-vs-dn", -20);
			
			}
    	
    	}
    	
    	# Glide-slope filter (input: /instrumentation/nav[0]/gs-rate-of-climb)
    	
    	if (getprop("/aircraft/afcs/ap-master") and (getprop("/aircraft/afcs/lat-mode") == "app") and (getprop("/instrumentation/nav/gs-in-range"))) {
    	
			var input_vs = getprop("/instrumentation/nav[0]/gs-rate-of-climb");
			
			if (input_vs > 18) {
			
				setprop("/aircraft/afcs/app-gs-fps", 18);
			
			} elsif (input_vs < -22) {
			
				setprop("/aircraft/afcs/app-gs-fps", -22);
			
			} else {
			
				setprop("/aircraft/afcs/app-gs-fps", input_vs);
			
			}
    	
    	}
    	
    	# Position String
    	
    	setprop("/instrumentation/fmc/pos-string", getprop("/position/latitude-string") ~ " " ~ getprop("/position/longitude-string"));

    	# FMC Time Management System

    	var elapsed_min = int((getprop("/sim/time/elapsed-sec") - getprop("/aircraft/fmc/time/start-sec")) / 60);

		setprop("/aircraft/fmc/time/utc", getprop("/aircraft/fmc/time/utc-set") + elapsed_min);

		if (getprop("/instrumentation/fmc/page") == "posref") {

			fmc.values[1].setText(substr(getprop("/aircraft/fmc/time/utc"), 0, 4)~"z").setColor(1,1,1,0.8);

		}

		if (getprop("/instrumentation/fmc/page") == "progress") {

			fmc.fmcPages["progress"].updateDisplay();

		}

	},

        reset : func {
            me.loopid += 1;
            me._loop_(me.loopid);
    },
        _loop_ : func(id) {
            id == me.loopid or return;
            me.update();
            settimer(func { me._loop_(id); }, me.UPDATE_INTERVAL);
    }

};

var tyresmoke = {
       init : func {
            me.UPDATE_INTERVAL = 0.1;
            me.loopid = 0;
            
            me.reset();
    },
    	update : func {
    	
    	# Tyre-smoke
    	
			var nose_wow_cur = getprop("/gear/gear/wow");
			var left_wow_cur = getprop("/gear/gear[1]/wow");
			var right_wow_cur = getprop("/gear/gear[1]/wow");
		
			if (!nose_wow_cur or nose_wow_sav) {
				setprop("/gear/gear[0]/tyresmoke", 0);
			} else {
				setprop("/gear/gear[0]/tyresmoke", 1);
			}
			
			if (!left_wow_cur or left_wow_sav) {
				setprop("/gear/gear[1]/tyresmoke", 0);
			} else {
				setprop("/gear/gear[1]/tyresmoke", 1);
			}
			
			if (!right_wow_cur or right_wow_sav) {
				setprop("/gear/gear[2]/tyresmoke", 0);
			} else {
				setprop("/gear/gear[2]/tyresmoke", 1);
			}
		
			nose_wow_sav = nose_wow_cur;
			left_wow_sav = left_wow_cur;
			right_wow_sav = right_wow_cur;
				
			if (left_wow_cur and (getprop("/velocities/airspeed-kt") > 70) and (getprop("controls/gear/brake-left") > 0.5)) {
				setprop("/gear/gear[1]/tyresmoke", 1);
			}
				
			if (right_wow_cur and (getprop("/velocities/airspeed-kt") > 70) and (getprop("controls/gear/brake-right") > 0.5)) {
				setprop("/gear/gear[2]/tyresmoke", 1);
			}

	},

        reset : func {
            me.loopid += 1;
            me._loop_(me.loopid);
    },
        _loop_ : func(id) {
            id == me.loopid or return;
            me.update();
            settimer(func { me._loop_(id); }, me.UPDATE_INTERVAL);
    }

};

setlistener("sim/signals/fdm-initialized", func
 {
 general_loop_1.init();
 print("ATR72 General System ....... Initialized");
 tyresmoke.init();
 });
