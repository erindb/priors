var clone = function(obj) {
    return JSON.parse(JSON.stringify(obj));
}

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
		gender: "female",
		min: 0,
		max: 7500,
		bins: [
			"$0-$500", "$500-$1000", "$1000-$1500",
			"$1500-$2000", "$2000-$2500", "$2500-$3000",
			"$3000-$3500", "$3500-$4000", "$4000-$4500",
			"$4500-$5000", "$5000-$5500", "$5500-$6000",
			"$6000-$6500", "$6500-$7000", "more than $7500"
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

		var lightning_item = clone(items[i]);
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

function make_slides(f) {
  var   slides = {};

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
    	console.log(nrows);

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
  exp.structure=["i0", "instructions", 
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