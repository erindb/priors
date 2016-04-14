/*
TO DO
If numbers (min, likely, max) are too close together, don't show same number twice
block key bord especially enter key
l75 continues without text input, error message 4 does display previous input
h25 does not continue because it is dependent on l75
textfields do not clear
If maximum-likely is very small, l75 = h25
Do we want to ask for perc chance of 14 if 14 is maximum?
*/

/*
Problematic
When defining the button command (what to do onclick), the present slide is always dependent on the last one. For example, the rating for l75 cannot be higher than the rating for h25.
While doing this, it does not seem to work to refer to the text input with the same command. In the beginning, Erin's command
$(".response").val()
worked, but at some point it seemed blocked. I then tried it with
$('#percl50').serialize().substr(11)
*/


/*
Structure of this .js File
several helper functions
arrays containing names and items. Each items in an object with several properties, like tag, gender, backstory etc
the functions get_items creates an array containing all items and assigns each item's character a name and its corresponding measure; this function will be called only later, when the actual slides are built
the function make_slides builds the slides (it is not defined as a variable, so it runs right away)
within make slides, the function slide from stream-V2.js builds the slides, shows the right one and guides through the items. The items are shown one after each other by using the function stream which is also defined in stream-V2.js
slide takes an object with the following structure (at least needs name)
name    (of slide in html, to show right one)
start (only introduction slide)
present (calls function get_items)
present_handle (tells what to do with items, for example where to show what, prepares df to save input in)
measure1
measure2 (carries name of measure, if this measure is active, this is how to build sentences)
...
button (what to do onclick)
log_responses (which data to save and where)
init_sliders (if sliders are present, what are sliders like)
*/


var clone = function(obj) {
    return JSON.parse(JSON.stringify(obj));
} //turn data into json string, replace elements if replcacer has been specified

var lowercase = function(str) {
	if (str[0] == "T") {
		return "t" + str.slice(1,str.length);
	} else  if (str[0] == "H") {
		return "h" + str.slice(1,str.length);
	} else  if (str[0] == "S") {
		return "s" + str.slice(1,str.length);
	} else {
		return str;
	}
}

//check whether input is numeric
function IsNumeric(n) {
    return !isNaN(n);
} 

var names = {
	"male" : _.shuffle([
		"James", "John", "Robert", "Michael", "William", "David",
		"Richard", "Joseph", "Charles", "Thomas", "Christopher",
		"Daniel", "Matthew", "Donald", "Anthony", "Paul", "Mark",
		"George", "Steven", "Kenneth", "Andrew", "Edward", "Joshua",
		"Brian", "Kevin", "Ronald", "Timothy", "Jason", "Jeffrey",
		"Gary", "Ryan", "Nicholas", "Eric", "Jacob", "Jonathan", "Larry",
		"Frank", "Scott", "Justin", "Brandon", "Raymond", "Gregory",
		"Samuel", "Benjamin", "Patrick", "Jack", "Dennis", "Jerry",
		"Alexander", "Tyler"
	]),
	"female" : _.shuffle([
		"Mary", "Jennifer", "Elizabeth", "Linda", "Emily", "Susan",
		"Margaret", "Jessica", "Dorothy", "Sarah", "Karen", "Nancy",
		"Betty", "Lisa", "Sandra", "Helen", "Ashley", "Donna", "Kimberly",
		"Carol", "Michelle", "Emily", "Amanda", "Melissa", "Deborah",
		"Laura", "Stephanie", "Rebecca", "Sharon", "Cynthia", "Kathleen",
		"Ruth", "Anna", "Shirley", "Amy", "Angela", "Virginia", "Brenda",
		"Catherine", "Nicole", "Christina", "Janet", "Samantha", "Carolyn",
		"Rachel", "Heather", "Diane", "Joyce", "Julie", "Emma"
	])
}

var items = [
{
		type: "event",
		similar_to_whose_experiment: "judith",
		tag: "joke",
		backstory: "X told a joke to N kids",
		give_number_question: "How many of the kids do you think laughed?",
		binned_histogram_prompt: "Please rate how likely it is that the following numbers of kids laughed.",
		story: "K of the kids laughed",
        manski: "number of kids who laughed",
		gender: "male",
		min: 0,
		max: 14,
		bins: [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14]
	},
	{
		type: "event",
		similar_to_whose_experiment: "judith",
		tag: "marbles",
		backstory: "X threw N marbles into a pool",
		give_number_question: "How many of the marbles do you think sank?",
		binned_histogram_prompt: "Please rate how likely it is that the following numbers of marbles sank.",
		story: "K of the marbles sank",
        manski: "number of marbles which sank",
		gender: "female",
		min: 0,
		max: 14,
		bins: [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14]
	},
	{
		type: "price",
		similar_to_whose_experiment: "justine",
		tag: "watch",
		backstory: "X bought a watch",
		give_number_question: "How much do you think it cost?",
		binned_histogram_prompt: "Please rate how likely it is that the watch cost the following amounts of money.",
		story: "The watch cost K",
        manski: "price of the watch",
		gender: "male",
		min: 0,
		max: 700,
		bins: [
			"$0-$50", "$50-$100", "$100-$150",
			"$150-$200", "$200-$250", "$250-$300",
			"$300-$350", "$350-$400", "$400-$450",
			"$450-$500", "$500-$550", "$550-$600",
			"$600-$650", "$650-$700", "more than $750"
		]
	},
	{
		type: "price",
		similar_to_whose_experiment: "justine",
		tag: "laptop",
		backstory: "X bought a laptop",
		give_number_question: "How much do you think it cost?",
		binned_histogram_prompt: "Please rate how likely it is that the laptop cost the following amounts of money.",
		story: "The laptop cost K",
        manski: "price of the laptop",
		gender: "female",
		min: 0,
		max: 4200,
		bins: [
			"$0-$300", "$300-$600", "$600-$900",
			"$900-$1200", "$1200-$1500", "$1500-$1800",
			"$1800-$2100", "$2100-$2400", "$2400-$2700",
			"$2700-$3000", "$3000-$3300", "$3300-$3600",
            "$3600-$3900", "$3900-$4200", "more than $4200"
		]
	},
	{
		type: "duration",
		similar_to_whose_experiment: "anthea",
		tag: "commute",
		backstory: "X commuted to work yesterday",
		give_number_question: "How many minutes do you think she spent commuting yesterday?",
		binned_histogram_prompt: "Please rate how likely it is that she commuted for the following numbers of minutes yesterday.",
		story: "She commuted for K minutes",
        manski: "length of her commute in minutes",
		gender: "female",
		min: 0,
		max: 98,
		bins: [
			"0-6", "7-13", "14-20",
			"21-27", "28-34", "35-41",
			"42-48", "49-55", "56-62",
			"63-69", "70-76", "77-83",
			"84-90", "91-97", "98 or more"
		]
	},
	{
		type: "duration",
		similar_to_whose_experiment: "anthea",
		tag: "tv",
		backstory: "X watched TV last week",
		give_number_question: "How many hours do you think he spent watching TV last week?",
		binned_histogram_prompt: "Please rate how likely it is that he watched TV for the following numbers of hours last week.",
		story: "He watched TV for K hours",
        manski: "time in hours he spent watching TV last week",
		gender: "male",
		min: 0,
		max: 43,
		bins: [
			"0-3", "4-6", "7-9",
			"10-12", "13-15", "16-18",
			"19-21", "22-24", "25-27",
			"28-30", "31-33", "34-36",
			"37-39", "40-42", "43 or more"
		]
	},
	{
		type: "duration",
		similar_to_whose_experiment: "ciyang",
		tag: "movies",
		backstory: "X just went to the movies to see a blockbuster",
		give_number_question: "How many minutes long do you think the movie was?",
		binned_histogram_prompt: "Please rate how likely it is that the movie was the following numbers of minutes long.",
		story: "The movie was K minutes long",
        manski: "length of the movie in minutes",
		gender: "female",
		min: 0,
		max: 210,
		bins: [
			"0-15", "15-30", "30-45",
			"45-60", "60-75", "75-90",
			"90-105", "105-120", "120-135",
			"135-150", "150-165", "165-180",
			"180-195", "195-210", "210 or more"
		]
	},
	{
		type: "temperature",
		similar_to_whose_experiment: "ciyang",
		tag: "coffee",
		backstory: "X has just fetched himself a cup of coffee from the office vending machine",
		give_number_question: "What do you think the temperature of his coffee is?",
		binned_histogram_prompt: "Please rate how likely it is that his coffee was the following temperatures.",
		story: "His coffee was K",
        manski: "temperature of his coffee",
		gender: "male",
		min: 0,
		max: 200,
		bins: [
			"44°F or less",  "44°F - 56°F",  "56°F - 68°F", 
			"68°F - 80°F",   "80°F - 92°F",  "92°F - 104°F",
			"104°F - 116°F",  "116°F - 128°F",   "128°F - 140°F",
			"140°F - 152°F",  "152°F - 164°F",    "164°F - 176°F",
			"176°F - 188°F",    "188°F - 200°F",   "200°F or more"
		]
	}
];

var measures = [
	"give_number",
	"binned histogram", //15 bins
	"lightning round"
];

var nbins = 15;
var repXN = function(str, name, k) {
	var newstr = str.replace(" N ", " " + (nbins-1) + " ");
	newstr = newstr.replace("K", k);
	return newstr.replace("X", name);
}
//to be filled by numbers given in Manski-slider-task
var likely = 0;
var minimum = 0;
var maximum = 0;
// need participants' input for error messages
var rating_M1 = 0 ;
var rating_M2 = 0 ;
var rating_M3 = 0;
var rating_M4 = 0;
var rating_M5 = 0;


//numbers to be rated
var numM = [0,0,0,0,0,0];

//gets all items at once, chooses a name, makes bin pairs, prepares "data frame" for item matching individual tasks
var get_items = function() {
	// var types = [
	// 	"temperature",
	// 	"duration",
	// 	"price",
	// 	"sinking marbles"
	// ]

	var trials = [];

	for (var i=0; i<items.length; i++) {

		var make_pairs = function(bins) {
			return _.shuffle([
				[ bins[0], bins[1] ],
				[ bins[1], bins[5] ],
				[ bins[5], bins[10] ],
				[ bins[10], bins[13] ],
				[ bins[13], bins[14] ]
			].map(_.shuffle));
		}

		var name = names[items[i].gender].shift();

		var lightning_item = clone(items[i]); //turn into json file, replace XKN
		lightning_item["measure"] = "lightning";
		lightning_item["name"] = name;
		lightning_item["pairs"] = make_pairs(lightning_item.bins);
		trials.push(lightning_item);
        
		var given_item = clone(items[i]);
		given_item["measure"] = "give_number";
		given_item["name"] = name;
		trials.push(given_item);
        
		var bins_item = clone(items[i]);
		bins_item["measure"] = "binned_histogram";
		bins_item["name"] = name;
		trials.push(bins_item);
        //lightning round //temperature, duration, price, sinking marbles
	}

	return _.shuffle(trials);
}

var get_final_items = function() {
	var pairs = [];
	for (var i=0; i<10; i++) {
		var choice1 = clone(_.sample(items));
		var choice2 = clone(_.sample(items));
		choice1.name = names[choice1.gender].shift();
		choice2.name = names[choice2.gender].shift();
		choice1.bin = _.sample(choice1.bins);
		choice2.bin = _.sample(choice2.bins.filter(function(x) {return x != choice1.bin;}));
		pairs.push([choice1, choice2]);
	}
	return pairs;
}


var get_Manski_items = function() {
    
//Do it this way to always have for one item correct order of measures: sliders, l25, l50... (don't shuffle after creating items)
    items = _.shuffle(items)
    var Manski_prior = [];
	for (var i=0; i<items.length; i++) {
		var name = names[items[i].gender].shift();

		var Manski_sliders = clone(items[i]); //turn into json file, replace XKN
		Manski_sliders["measure"] = "Manski_sliders";
		Manski_sliders["name"] = name;
		Manski_prior.push(Manski_sliders);
        
        var Manski_1 = clone(items[i]); //turn into json file, replace XKN
		Manski_1["measure"] = "Manski_1";
		Manski_1["name"] = name;
		Manski_prior.push(Manski_1);
        
        var Manski_2 = clone(items[i]); //turn into json file, replace XKN
		Manski_2["measure"] = "Manski_2";
		Manski_2["name"] = name;
		Manski_prior.push(Manski_2);
        
        var Manski_3 = clone(items[i]); //turn into json file, replace XKN
		Manski_3["measure"] = "Manski_3";
		Manski_3["name"] = name;
		Manski_prior.push(Manski_3);
        
        var Manski_4 = clone(items[i]); //turn into json file, replace XKN
		Manski_4["measure"] = "Manski_4";
		Manski_4["name"] = name;
		Manski_prior.push(Manski_4);
        
        var Manski_5 = clone(items[i]); //turn into json file, replace XKN
		Manski_5["measure"] = "Manski_5";
		Manski_5["name"] = name;
		Manski_prior.push(Manski_5);
        
        var Manski_6 = clone(items[i]); //turn into json file, replace XKN
		Manski_6["measure"] = "Manski_6";
		Manski_6["name"] = name;
		Manski_prior.push(Manski_6);
        
    }
    return Manski_prior;
}


function make_slides(f) {
  var   slides = {};
    
        //block enter key for every instance of class "slide" so that exp doesn't start from beginning when entering answer
    $('html').bind('keypress', function(e)
    {
       if(e.keyCode == 13)
       {
          return false;
       }
    });

  slides.i0 = slide({
     name : "i0",
     start: function() {
      exp.startT = Date.now();
     }
  });

  slides.instructions = slide({
    name : "instructions",
    button : function() {
      exp.go(); //use exp.go() if and only if there is no "present" data.
    }
  });
    
slides.example = slide({
    name : "example",
    button : function() {
      exp.go(); //use exp.go() if and only if there is no "present" data.
    }
  });
    
slides.Manski = slide({
  	name: "Manski",
  	present: get_Manski_items(),
    
    Manski_sliders: function(stim) {
		var prefix = stim.type == "price" ? "$" : "";
		var suffix = stim.type == "temperature" ? "°F" : "";
		$("#min").html(prefix + stim.min + suffix);
		$("#max").html(prefix + stim.max + suffix);
		$("#Manski_sentence").html(repXN(stim.backstory, stim.name) + ".");
        $("#Manski_question").html(repXN(stim.give_number_question));
        $("#Qlike1").html('The ');
        $("#Qlike2").html(stim.manski+" was probably about ");
        $("#Qmin1").html('The lowest possible ');
        $("#Qmin2").html(stim.manski + " is");
        $("#Qmax1").html('The highest possible '); //change to or less
		$("#Qmax2").html(stim.manski+ " is");
    
            //start slider
        _s.init_slider_likely(stim.min, stim.max, prefix, suffix);
        _s.init_slider_min(stim.min, stim.max, prefix, suffix);
        _s.init_slider_max(stim.min, stim.max, prefix, suffix);
        $("#number_guess_likely").html("?");
        $("#number_guess_min").html("?");
        $("#number_guess_max").html("?");
            //save data in
        _s.likely_response_data = null;
        _s.min_response_data = null;
        _s.max_response_data = null;
        $("#number_guess_likely").html("?");
        $("#number_guess_min").html("?");
        $("#number_guess_max").html("?");
    },
   
    Manski_1: function(stim) {
        console.log('minimum '+minimum);
        console.log('max '+maximum);
        console.log('likely '+likely);
        var prefix = stim.type == "price" ? "$" : "";
		var suffix = stim.type == "temperature" ? "°F" : "";
        //numbers to be displayed
		$("#minM1").html(0);
		$("#maxM1").html(100);
        $('#questionM1').html("How likely do you think it is that the " +stim.manski+" will be "+ prefix +numM[0] + suffix); 
        //numbers for slider values
        var minM = 0;
        //start slider
       // first time slider from 0 to 100
        _s.init_slider_M1(minM);
        $("#number_guess_M1").html("?");
        //save data in
        _s.M1_response_data = null;
        $("#number_guess_M1").html("?"); //reset display
    },
   Manski_2: function(stim) {
        var prefix = stim.type == "price" ? "$" : "";
		var suffix = stim.type == "temperature" ? "°F" : "";
        //numbers to be displayed
		$("#minM2").html(rating_M1);
		$("#maxM2").html(100);
        $('#questionM2').html("How likely do you think it is that the " +stim.manski+" will be "+ prefix +numM[1] + suffix); 
        //start slider
        //minimal value from number array generated in slide Manski_sliders
        _s.init_slider_M2(Number(rating_M1));
       $("#number_guess_M2").html("?"); //reset display
        //save data in
        _s.M2_response_data = null;
       $("#number_guess_M2").html("?"); //reset display
    },
    Manski_3: function(stim) {
        var prefix = stim.type == "price" ? "$" : "";
		var suffix = stim.type == "temperature" ? "°F" : "";
        //numbers to be displayed
		$("#minM3").html(rating_M2);
		$("#maxM3").html(100);
        $('#questionM3').html("How likely do you think it is that the " +stim.manski+" will be "+ prefix +numM[2] + suffix); 
        //start slider
        //minimal value from number array generated in slide Manski_sliders
        _s.init_slider_M3(Number(rating_M2));
        $("#number_guess_M3").html("?"); //reset display
        //save data in
        _s.M3_response_data = null;
        $("#number_guess_M3").html("?"); //reset display
    },
    Manski_4: function(stim) {
        var prefix = stim.type == "price" ? "$" : "";
		var suffix = stim.type == "temperature" ? "°F" : "";
        //numbers to be displayed
       
		$("#minM4").html(rating_M3);
		$("#maxM4").html(100);
        $('#questionM4').html("How likely do you think it is that the " +stim.manski+" will be "+ prefix +numM[3] + suffix); 
        //start slider
        //minimal value from number array generated in slide Manski_sliders
        _s.init_slider_M4(Number(rating_M3));
        $("#number_guess_M4").html("?"); //reset display
        //save data in
        _s.M4_response_data = null;
        $("#number_guess_M4").html("?"); //reset display
    }, 
    Manski_5: function(stim) {
            var prefix = stim.type == "price" ? "$" : "";
		var suffix = stim.type == "temperature" ? "°F" : "";
        //numbers to be displayed
		$("#minM5").html(rating_M4);
		$("#maxM5").html(100);
        $('#questionM5').html("How likely do you think it is that the " +stim.manski+" will be "+ prefix +numM[4] + suffix); 
        //start slider
        //minimal value from number array generated in slide Manski_sliders
        _s.init_slider_M5(Number(rating_M4));
         $("#number_guess_M5").html("?"); //reset display
        //save data in
        _s.M5_response_data = null;
        $("#number_guess_M5").html("?"); //reset display
    },  
    Manski_6: function(stim) {
            var prefix = stim.type == "price" ? "$" : "";
		var suffix = stim.type == "temperature" ? "°F" : "";
        //numbers to be displayed
		$("#minM6").html(rating_M5);
		$("#maxM6").html(100);
        $('#questionM6').html("How likely do you think it is that the " +stim.manski+" will be "+ prefix +numM[5] + suffix); 
        //start slider
        //minimal value from number array generated in slide Manski_sliders
        _s.init_slider_M6(Number(rating_M5));
        $("#number_guess_M6").html("?"); //reset display
        //save data in
        _s.M6_response_data = null;
        $("#number_guess_M6").html("?"); //reset display
    },   
    
	present_handle: function(stim) {
        //reset sliders
        $("#number_guess_likely").html("?");
        $("#number_guess_min").html("?");
        $("#number_guess_max").html("?");
        $("#number_guess_M1").html("?");
        $("#number_guess_M2").html("?");
        $("#number_guess_M3").html("?");
        $("#number_guess_M4").html("?");
        $("#number_guess_M5").html("?");
        $("#number_guess_M6").html("?");
        $(".M_slide").hide();//hide parts of slide Manski, only show after each other
        
        //for sliders
    	_s.this_trial_data = clone(stim);
        //stage of Manski task?
    	_s.measure = stim.measure;
        console.log('stim measure '+stim.measure);
    	_s.trial_start = Date.now();
    	_s.measure = stim.measure;
        _s.trial_start = Date.now();

        $(".err").hide();
        $("#" + _s.measure).show();
        _s[_s.measure](stim); //_s[_s.measure] calls the function inside the current measure, it basically creates the items as defined in the measure
    },

    
    //one slider each
    init_slider_likely : function(min, max, prefix, suffix) {
        utils.make_slider("#likely_single_slider", function(event, ui) {
        _s.likely_response_data = Math.round(ui.value * (max - min) + min);
        $("#number_guess_likely").html(prefix + _s.likely_response_data + suffix);
      });
    },
    init_slider_min : function(min, max, prefix, suffix) {
        utils.make_slider("#min_single_slider", function(event, ui) {
        _s.min_response_data = Math.round(ui.value * (max - min) + min);
        $("#number_guess_min").html(prefix + _s.min_response_data + suffix);
      });
    },
    init_slider_max : function(min, max, prefix, suffix) {
        utils.make_slider("#max_single_slider", function(event, ui) {
        _s.max_response_data = Math.round(ui.value * (max - min) + min);
        $("#number_guess_max").html(prefix + _s.max_response_data + suffix);
      });
    },
    //changed definition of Manski slider function, values from minM (=last slider rating) to 100 percent)
    //only takes one input parameter
    init_slider_M1 : function(min) {
        utils.make_slider("#M1_single_slider", function(event, ui) {
        _s.M1_response_data = Math.round(ui.value * (100 - min) + min);
            console.log('ui value '+ui.value);
        $("#number_guess_M1").html(_s.M1_response_data +"% likely");
      });
    },
     init_slider_M2 : function(min) {
        utils.make_slider("#M2_single_slider", function(event, ui) {
        _s.M2_response_data = Math.round(ui.value * (100 - min) + min);
        $("#number_guess_M2").html(_s.M2_response_data +"% likely");
      });
    },
     init_slider_M3 : function(min) {
        utils.make_slider("#M3_single_slider", function(event, ui) {
        _s.M3_response_data = Math.round(ui.value * (100 - min) + min);
        $("#number_guess_M3").html(_s.M3_response_data +"% likely");
      });
    },
     init_slider_M4 : function(min) {
        utils.make_slider("#M4_single_slider", function(event, ui) {
        _s.M4_response_data = Math.round(ui.value * (100 - min) + min);
        $("#number_guess_M4").html(_s.M4_response_data +"% likely");
      });
    },
     init_slider_M5 : function(min) {
        utils.make_slider("#M5_single_slider", function(event, ui) {
        _s.M5_response_data = Math.round(ui.value * (100 - min) + min);
        $("#number_guess_M5").html(_s.M5_response_data +"% likely");
      });
    },
     init_slider_M6 : function(min) {
        utils.make_slider("#M6_single_slider", function(event, ui) {
        _s.M6_response_data = Math.round(ui.value * (100 - min) + min);
        $("#number_guess_M6").html(_s.M6_response_data +"% likely");
      });
    },
    
        
   button : function() {
    if (_s.measure == 'Manski_sliders'){
        //every slider checked and min < likely < max
		if (_s.likely_response_data == null || _s.min_response_data == null ||_s.max_response_data == null || _s.min_response_data >_s.likely_response_data  || _s.likely_response_data > _s.max_response_data ) {
			$("#Manski_err").show();
		} else { 
        //save data (also likely, minimum, maximum are extracted this way)    
        _s.log_responses();
        //calculate the numbers to display in perc chance task here already
        // we need to do this within the button function to be able to access the numbers before they are displayed. We want to exclude that numbers are displayed twice, if min and max are very close together
        numM[0] = Math.round( Number(minimum)+(0.25*(Number(likely)-Number(minimum) )) )
        numM[1] = Math.round( Number(minimum)+(0.50*(likely-minimum)) );
        numM[2] = Math.round( Number(minimum)+(0.75*(likely-minimum)) );
        numM[3] = Math.round( Number(likely)+(0.25*(maximum-likely)) );
        numM[4] = Math.round( Number(likely)+(0.50*(maximum-likely)) );
        numM[5] = Math.round( Number(likely)+(0.75*(maximum-likely)) );
        console.log('numbers to display all six ' +numM);    
        numM = _.uniq(numM, false); //kick out double numbers
        console.log('numbers to display unique ' +numM);    
        _stream.apply(this);
        } //use exp.go() if and only if there is no "present" data.
       } 
  else { 
//perc chance questions
        // go to next item if answer is 100
        if(_s.measure == 'Manski_1'){
            //if no rating
            if (_s.M1_response_data != null){
            //if rating is 100 or if only 1 number to rate
                if (_s.M1_response_data == 100 || numM.length == 1) {
                    //jump to next Manski slider task, see function Stream-V2.js
                    stim = this.present.shift();
                    stim = this.present.shift();
                    stim = this.present.shift();
                    stim = this.present.shift();
                    stim = this.present.shift();
                    _s.log_responses();
                    _stream.apply(this);} 
            else {
            _s.log_responses();
            _stream.apply(this);}}
            else {
                $("#itemError1").show();
            }
        } 
        else { //if answer is LOWER than RATING L25
           if (_s.measure == 'Manski_2'){
            //if no rating
            if (_s.M2_response_data != null){
            //if rating is 100 or if array shorter than 6
                if (_s.M2_response_data == 100 || numM.length == 2) {
                    //jump to next Manski slider task, see function Stream-V2.js
                    stim = this.present.shift();
                    stim = this.present.shift();
                    stim = this.present.shift();
                    stim = this.present.shift();
                    _s.log_responses();
                    _stream.apply(this);} 
                else {
                _s.log_responses();
                _stream.apply(this);}}
            else {
                $("#itemError2").show();}
                }
            else { 
                if (_s.measure == 'Manski_3'){
            //if no rating
            if (_s.M3_response_data != null){
            //if rating is 100 or if array shorter than 6
                if (_s.M3_response_data == 100 || numM.length == 3) {
                    //jump to next Manski slider task, see function Stream-V2.js
                    stim = this.present.shift();
                    stim = this.present.shift();
                    stim = this.present.shift();
                    _s.log_responses();
                    _stream.apply(this);} 
                else {
                _s.log_responses();
                _stream.apply(this);}}
            else {
                $("#itemError3").show();}
            } 
            else{
                if(_s.measure == 'Manski_4'){
                //if no rating
                if (_s.M4_response_data != null){
                //if rating is 100 or if array shorter than 6
                if (_s.M4_response_data == 100 || numM.length == 4) {
                    //jump to next Manski slider task, see function Stream-V2.js
                    stim = this.present.shift();
                    stim = this.present.shift();
                    _s.log_responses();
                    _stream.apply(this);} 
                else {
                _s.log_responses();
                _stream.apply(this);}
                }
            else {
                $("#itemError4").show();}
            } 
            else {
                if(_s.measure == 'Manski_5'){
                //if no rating
                if (_s.M5_response_data != null){
                //if rating is 100 or if array shorter than 6
                if (_s.M5_response_data == 100 || numM.length == 5) {
                    //jump to next Manski slider task, see function Stream-V2.js
                    stim = this.present.shift();
                    _s.log_responses();
                    _stream.apply(this);} 
                else {
                _s.log_responses();
                _stream.apply(this);}}
            else {
                $("#itemError5").show();}
                }
                else { //measure is Manski_6
                //if no rating
                if (_s.M6_response_data != null){
                _s.log_responses();
                _stream.apply(this);}
            else {
                $("#itemError5").show();}
                }         
            }
            }//h25
        } //l50
        }//l25
    }//Manski_sliders
   },//function
   
 log_responses: function() {
        //get data from all three sliders
        if (_s.measure == 'Manski_sliders'){
            likely = _s.likely_response_data;
            _s.this_trial_data["Manski_likely"] = _s.likely_response_data;
            
            minimum = _s.min_response_data;
            _s.this_trial_data["Manski_min"] = _s.min_response_data;
            maximum = _s.max_response_data;
            _s.this_trial_data["Manski_max"] = _s.max_response_data;
	    	_s.this_trial_data["rt"] = Date.now() - _s.trial_start;
	    	exp.data_trials.push(clone(_s.this_trial_data));
            //reset sliders
            _s.likely_response_data = null;
            _s.min_response_data = null;
            _s.max_response_data = null;
        } else {
            if (_s.measure == 'Manski_1'){
                rating_M1 = _s.M1_response_data; 
                _s.this_trial_data["rating_M1"] = _s.M1_response_data;
                _s.this_trial_data["number_M1"] = numM[0];  
                exp.data_trials.push(clone(_s.this_trial_data));
                _s.M1_response_data = null;
            } else { if (_s.measure == 'Manski_2'){
                rating_M2 = _s.M2_response_data; 
                _s.this_trial_data["rating_M2"] = _s.M2_response_data;
                _s.this_trial_data["number_M2"] = numM[1];  
                exp.data_trials.push(clone(_s.this_trial_data));
                _s.M2_response_data = null;
            } else { if (_s.measure == 'Manski_3'){
                rating_M3 = _s.M3_response_data; 
                _s.this_trial_data["rating_M3"] = _s.M3_response_data;
                _s.this_trial_data["number_M3"] = numM[2];  
                exp.data_trials.push(clone(_s.this_trial_data));
                _s.M3_response_data = null;
            } else { if (_s.measure == 'Manski_4'){
                rating_M4 = _s.M4_response_data; 
                _s.this_trial_data["rating_M4"] = _s.M4_response_data;
                _s.this_trial_data["number_M4"] = numM[3];  
                exp.data_trials.push(clone(_s.this_trial_data));
                _s.M4_response_data = null;
            } else { if (_s.measure == 'Manski_5'){
                rating_M5 = _s.M5_response_data; 
                _s.this_trial_data["rating_M5"] = _s.M5_response_data;
                _s.this_trial_data["number_M5"] = numM[4];  
                exp.data_trials.push(clone(_s.this_trial_data));
                _s.M5_response_data = null;
            } else{ if (_s.measure == 'Manski_6'){
                rating_M6 = _s.M6_response_data; 
                _s.this_trial_data["rating_M6"] = _s.M6_response_data;
                _s.this_trial_data["number_M6"] = numM[5];  
                exp.data_trials.push(clone(_s.this_trial_data));
                _s.M6_response_data = null;
                //numM = 0;
            } else {alert('I dont know this measure :( ')}
            }
            } }}}};
  }
});


  slides.final_lightning = slide({
  	name: "final_lightning",
  	present: get_final_items(),
	present_handle: function(pair) {
    	$(".err").hide();
    	$("#final_button_container").show();
    	_s.trial_start = Date.now();
		$("#final_lightning_sentence").html();
		$("#final_left_choice").html(
			repXN(pair[0].backstory, pair[0].name) + " and " +
			lowercase(repXN(pair[0].story, pair[0].name, pair[0].bin))
		);
		$("#final_right_choice").html(
			repXN(pair[1].backstory, pair[1].name) + " and " +
			lowercase(repXN(pair[1].story, pair[1].name, pair[1].bin))
		);
	},
	choose: function(direction) {
		_s.this_trial_data = {};
		_s.this_trial_data["response"] = $("#final_" + direction + "_choice").html();
		_s.this_trial_data["chosen_direction"] = direction;
		_s.this_trial_data["unchosen_contrast"] = $("#final_" + (direction == "right" ? "left" : "right") + "_choice").html();
		_s.this_trial_data["rt"] = Date.now() - _s.trial_start;
		exp.data_trials.push(clone(_s.this_trial_data));
    	$("#final_button_container").hide();
    	setTimeout(function() {
    		_stream.apply(_s);
    	}, 500);
	},
  });

  slides.trial = slide({
    name : "trial",
    present : get_items(),
    give_number: function(stim) {
		$("#number_guess").html("?");
		var prefix = stim.type == "price" ? "$" : "";
		var suffix = stim.type == "temperature" ? "°F" : "";
		$("#min").html(prefix + stim.min + suffix);
		$("#max").html(prefix + stim.max + suffix);
		$("#give_number_sentence").html(repXN(stim.backstory, stim.name) + ".");
		$("#give_number_question").html(stim.give_number_question);
		_s.init_slider(stim.min, stim.max, prefix, suffix);
		$("#number_guess").html("?");
    	_s.current_response_data = null;
		$("#number_guess").html("?");
	},
	binned_histogram: function(stim) {
		_s.init_sliders();
		$("#binned_histogram_prompt").html(stim.binned_histogram_prompt);
		$("#binned_histogram_sentence").html(repXN(stim.backstory, stim.name) + ".");
		for (var i=0; i<nbins; i++) {
			//$("#" + slider + i)
			$("#bin" + i).html(stim.bins[i]);
		}
		_s.current_response_data = {};
	},
	lightning: function() {
    	$("#button_container").show();
    	_s.trial_start = Date.now();
    	var pair = _s.pairs.shift();
		$("#lightning_sentence").html(repXN(_s.this_trial_data.backstory, _s.this_trial_data.name) + ".");
		$("#left_choice").html(repXN(_s.this_trial_data.story, _s.this_trial_data.name, pair[0]) + ".");
		$("#right_choice").html(repXN(_s.this_trial_data.story, _s.this_trial_data.name, pair[1]) + ".");
	},
	choose: function(direction) {
		_s.this_trial_data["response"] = $("#" + direction + "_choice").html();
		_s.this_trial_data["chosen_direction"] = direction;
		_s.this_trial_data["unchosen_contrast"] = $("#" + (direction == "right" ? "left" : "right") + "_choice").html();
		_s.this_trial_data["rt"] = Date.now() - _s.trial_start;
		exp.data_trials.push(clone(_s.this_trial_data));
		if (_s.pairs.length > 0) {
    		$("#button_container").hide();
    		setTimeout(function() {
    			_s.lightning()
    		}, 500);
		} else {
			_stream.apply(_s);
		}
	},
    present_handle : function(stim) {
		$("#number_guess").html("?");
    	_s.this_trial_data = clone(stim);
    	_s.measure = stim.measure;
    	_s.trial_start = Date.now();
    	$(".err").hide();
    	$(".subslide").hide();
    	$("#" + _s.measure).show();
		if (_s.measure == "lightning") {
			_s.pairs = clone(stim.pairs);
	    	_s[_s.measure]();
		} else {
			_s.trial_start = Date.now();
	    	_s[_s.measure](stim);
	    }
    },
    button : function() {
		if (_s.current_response_data == null) {
			$("#" + _s.measure + "_err").show();
		} else {
			if (_s.measure == "binned_histogram") {
				var complete = function() {
					for (var i=0; i<nbins; i++) {
						if (_s.current_response_data["bin" + i] == undefined) {
							return false;
						}
					}
					return true;
				}();
				if (complete) {
			        _s.log_responses();
			        _stream.apply(this); //use exp.go() if and only if there is no "present" data.
			    } else {
					$("#" + _s.measure + "_err").show();
				}
			} else {
		        _s.log_responses();
		        _stream.apply(this); //use exp.go() if and only if there is no "present" data.
		    }
		}
    },
      
    init_sliders : function() {
    	$("#slider_table").empty();

    	var table_content = ""

    	var nrows = _s.this_trial_data.type == "event" ? 1 : 3;

    	var slider_index = 0;
    	var bin_index = 0;
    	var col_per_row = 5;

    	for (var i=0; i<nrows; i++) {
    		var row_nbins;
    		if (i == 0 & nrows == 1) {
    			row_nbins = nbins;
    		} else if ( i == 0 & nrows == 3) {
    			row_nbins = col_per_row;
    		} else if (i == 1 & nrows == 3) {
    			row_nbins = col_per_row;
    			table_content = table_content + "<tr><td class='omglol' colspan='" + (col_per_row+2) + "'></td></tr>";
    		} else if (i == 2) {
    			row_nbins = nbins-(2*col_per_row);
    			table_content = table_content + "<tr><td class='omglol' colspan='" + (col_per_row+2) + "'></td></tr>";
    		}

	    	table_content = table_content + "<tr> <td align='right' height='72'> Extremely likely<br> </td>";

	    	for (var j=0; j<row_nbins; j++) {
	    		table_content = table_content + "<td rowspan='5' width='200' align='center'><div class='vslider' id='slider" + slider_index + "'>&nbsp;</div></td>"
	    		slider_index++
	    	}

	    	table_content = table_content + "/tr"

	    	table_content = table_content + "<tr> <td align='right' height='72'> Very likely<br> </td> </tr>"
	    	table_content = table_content + "<tr> <td align='right' height='72'> Neutral<br> </td> </tr>"
	    	table_content = table_content + "<tr> <td align='right' height='72'> Not very likely<br> </td> </tr>"
	    	table_content = table_content + "<tr> <td align='right' height='72'> Impossible<br> </td> </tr>"

	    	table_content = table_content + "<tr> <td></td>"

	    	for (var j=0; j<row_nbins; j++) {
		    	table_content = table_content + "<td align='center' id='bin" + bin_index + "'>{{}}</td>"
		    	bin_index++;
		    }

		    table_content = table_content + "</tr>"
		}
    	$("#slider_table").html(table_content);

    	for (var i=0; i<nbins; i++) {
    		utils.make_slider("#slider" + i, function(index) {
    			return function(event, ui) {
	    			_s.current_response_data["bin" + index] = ui.value;
	    		}
    		}(i), true);
    	}
    },
    init_slider : function(min, max, prefix, suffix) {
      utils.make_slider("#give_number_single_slider", function(event, ui) {
        _s.current_response_data = Math.round(ui.value * (max - min) + min);
        $("#number_guess").html(prefix + _s.current_response_data + suffix);
      });
    },
    log_responses: function() {
    	if (_s.measure == "give_number") {
	    	_s.this_trial_data["response"] = _s.current_response_data;
	    	_s.this_trial_data["rt"] = Date.now() - _s.trial_start;
	    	exp.data_trials.push(clone(_s.this_trial_data));
	    } else if (_s.measure == "binned_histogram") {
	    	for (var i=0; i<nbins; i++) {
		    	_s.this_trial_data["response"] = _s.current_response_data["bin" + i];
		    	_s.this_trial_data["bin"] = _s.this_trial_data.bins[i];
		    	_s.this_trial_data["rt"] = Date.now() - _s.trial_start;
		    	exp.data_trials.push(clone(_s.this_trial_data));
		    }
	    }
    	_s.current_response_data = null;
    }
  });

  slides.subj_info =  slide({
    name : "subj_info",
    submit : function(e){
      //if (e.preventDefault) e.preventDefault(); // I don't know what this means.
      exp.subj_data = {
        language : $("#language").val(),
        enjoyment : $("#enjoyment").val(),
        asses : $('input[name="assess"]:checked').val(),
        age : $("#age").val(),
        gender : $("#gender").val(),
        education : $("#education").val(),
        comments : $("#comments").val(),
      };
      exp.go(); //use exp.go() if and only if there is no "present" data.
    }
  });

  slides.thanks = slide({
    name : "thanks",
    start : function() {
      exp.data= {
          "trials" : exp.data_trials,
          "catch_trials" : exp.catch_trials,
          "system" : exp.system,
          "condition" : exp.condition,
          "subject_information" : exp.subj_data,
          "clicks" : exp.clicks,
          "time_in_minutes" : (Date.now() - exp.startT)/60000
      };
      setTimeout(function() {turk.submit(exp.data);}, 1000);
    }
  });

  return slides;
}

/// init ///
function init() {
  exp.clicks = [];

  exp.condition = {}; //can randomize between subject conditions here
  exp.system = {
      Browser : BrowserDetect.browser,
      OS : BrowserDetect.OS,
      screenH: screen.height,
      screenUH: exp.height,
      screenW: screen.width,
      screenUW: exp.width
    };
  //blocks of the experiment:
  exp.structure=["i0", "instructions", "example", "Manski", 
  "trial", "final_lightning", 
  'subj_info', 'thanks'];
  
  exp.data_trials = [];
  //make corresponding slides:
  exp.slides = make_slides(exp);

  exp.nQs = utils.get_exp_length(); //this does not work if there are stacks of stims (but does work for an experiment with this structure)
                    //relies on structure and slides being defined

  $('.slide').hide(); //hide everything

  //make sure turkers have accepted HIT (or you're not in mturk)
  $("#start_button").click(function() {
    if (turk.previewMode) {
      $("#mustaccept").show();
    } else {
      $("#start_button").click(function() {$("#mustaccept").show();});
      exp.go();
    }
  });

  exp.go(); //show first slide
}