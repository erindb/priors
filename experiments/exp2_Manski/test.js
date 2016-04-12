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
        Manski_start: "was the number of the kids who laughed",
        perc_chance: "number of kids who laughed",
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
        Manski_start: "was the number of the marbles which sank",
        perc_chance: "number of marbles which sank",
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
        Manski_start: "was the prize of the watch",
        perc_chance: "prize of the watch in $",
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
/*	{
		type: "price",
		similar_to_whose_experiment: "justine",
		tag: "laptop",
		backstory: "X bought a laptop",
		give_number_question: "How much do you think it cost?",
		binned_histogram_prompt: "Please rate how likely it is that the laptop cost the following amounts of money.",
		story: "The laptop cost K",
        Manski_start: "was the prize of the laptop",
        perc_chance: "prize of the laptop in $",
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
        Manski_start: "minutes was the duration of her commute",
        perc_chance: "length of her commute in minutes",
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
        Manski_start: "hours was the time he spent watching TV last week",
        perc_chance: "time he spent watching TV last in hours",
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
        Manski_start: "minutes was the length of the movie",
        perc_chance: "length of the movie in minutes",
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
        Manski_start: "was the temperature of his coffee",
        perc_chance: "temperature of his coffee in °F",
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
	}*/
];
console.log(items);

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
        
        var Manski_l25 = clone(items[i]); //turn into json file, replace XKN
		Manski_l25["measure"] = "Manski_l25";
		Manski_l25["name"] = name;
		Manski_prior.push(Manski_l25);
        
        var Manski_l50 = clone(items[i]); //turn into json file, replace XKN
		Manski_l50["measure"] = "Manski_l50";
		Manski_l50["name"] = name;
		Manski_prior.push(Manski_l50);
        
        var Manski_l75 = clone(items[i]); //turn into json file, replace XKN
		Manski_l75["measure"] = "Manski_l75";
		Manski_l75["name"] = name;
		Manski_prior.push(Manski_l75);
        
        var Manski_h25 = clone(items[i]); //turn into json file, replace XKN
		Manski_h25["measure"] = "Manski_h25";
		Manski_h25["name"] = name;
		Manski_prior.push(Manski_h25);
        
        var Manski_h50 = clone(items[i]); //turn into json file, replace XKN
		Manski_h50["measure"] = "Manski_h50";
		Manski_h50["name"] = name;
		Manski_prior.push(Manski_h50);
        
        var Manski_h75 = clone(items[i]); //turn into json file, replace XKN
		Manski_h75["measure"] = "Manski_h75";
		Manski_h75["name"] = name;
		Manski_prior.push(Manski_h75);
        
    }
 /*   var byName = arrayOfObjects.slice(0);
byName.sort(function(a,b) {
    var x = a.name.toLowerCase();
    var y = b.name.toLowerCase();
    return x < y ? -1 : x > y ? 1 : 0;
    });
    */
    //return _.shuffle(Manski_prior);
	return Manski_prior;
}

document.getElementById("para1");
//window.document.writeln(items.toString());
//window.document.writeln(get_Manski_items().toString());

