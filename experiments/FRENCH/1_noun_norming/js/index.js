//https://www.ncbi.nlm.nih.gov/pmc/articles/doi/10.3389/fpsyg.2014.00399/full// Returns a random integer between min (included) and max (excluded)
// Using Math.round() will give you a non-uniform distribution!
function getRandomInt(min, max) {
  return Math.floor(Math.random() * (max - min)) + min;
}

function make_slides(f) {
  var slides = {};

function startsWith(str, substrings) {
    for (var i = 0; i != substrings.length; i++) {
       var substring = substrings[i];
       if (str.indexOf(substring) == 0) {
         return 1;
       }
    }
    return -1;
}

function getArticleItem(item_id) {
  var article = "";
  if (startsWith(item_id, ["a","e","i","o","u"]) == 1) {
    article = "an ";
  } else {
    article = "a ";
  }
  return article;
}

  slides.i0 = slide({
     name : "i0",
     start: function() {
      exp.startT = Date.now();
     }
  });

  slides.objecttrial = slide({
    name : "objecttrial",
    present : exp.all_stims,
    start : function() {
	   $(".err").hide();
    },
      present_handle : function(stim) {
      console.log(stim);
    	this.trial_start = Date.now();
      $(".err").hide();
      $("#answer").val("");
      $(".err").hide();
      // exp.sliderPost = {};
	   //$("#objectlabel").val("");
	  this.stim = stim;
    // stim.item = _.shuffle(stim.item);
	  console.log(this.stim);
    var article = getArticleItem(stim.item);
   //  console.log(stim.item);
   //  console.log(stim.label);
	var contextsentence = "Qu'est-ce que c'est?";
	//var contextsentence = "How typical is this for "+stim.basiclevel+"?";
	//var objimagehtml = '<img src="images/'+stim.basiclevel+'/'+stim.item+'.jpg" style="height:190px;">';
	var objimagehtml = '<img src="images/'+stim.label+'.jpg" style="height:230px;">';

	$("#contextsentence").html(contextsentence);
	$("#objectimage").html(objimagehtml);

//ENTER TO CONTINUE/
    document.onkeypress = checkKey;
    function checkKey(e) {
      e = e || window.event;
      if (e.keyCode == 13) {
         _s.button();
      }
    }
	},

	button : function() {
	  if ($("#answer").val().length > 1) {
        $(".err").hide();
        this.log_responses();
        _stream.apply(this); //use exp.go() if and only if there is no "present" data.
      //}
      } else {
        $(".err").show();
        document.getElementById('answer').value = '';
      }
    },

    log_responses : function() {
        exp.data_trials.push({
          "slide_number_in_experiment" : exp.phase,
          "utterance": this.stim.item,
          "object": this.stim.label,
          "rt" : Date.now() - _s.trial_start,
          "response" : $("#answer").val()
        });
    }
  });

  slides.subj_info =  slide({
    name : "subj_info",
    start : function(e){
      $(".err2").hide();
    },
    submit : function(e){
      //if (e.preventDefault) e.preventDefault(); // I don't know what this means.
      exp.subj_data = {
        gender : $("#gender").val(),
        age : $("#age").val(),
        education : $("#education").val(),
        asses : $('input[name="assess"]:checked').val(),
        problems: $("#problems").val(),
        fairprice: $("#fairprice").val(),
        enjoyment : $("#enjoyment").val(),
        comments : $("#comments").val(),

        firstLanguage : $("#firstLanguage").val(),
        frenPrimaryLanguageSchool : $("#frenPrimaryLanguageSchool").val(),
        otherLanguage : $("#otherLanguage").val(),
        liveInFrenReg : $("#liveInFrenReg").val(),
        region : $("#region").val(),
        country : $("#regionSpecific").val(),
      };

      // The second part of the questionaire is not optional throw an
      // error if any of the questions in the second part are left unanswered
      if (exp.subj_data.firstLanguage != "" &
        exp.subj_data.otherLanguage != "" &
        exp.subj_data.frenPrimaryLanguageSchool != "" &
        exp.subj_data.liveInfrenReg != "" &
        exp.subj_data.region != "") {
        $(".err2").hide();
        exp.go(); //use exp.go() if and only if there is no "present" data.
      } else {
        $(".err2").show();
      };
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
          "time_in_minutes" : (Date.now() - exp.startT)/60000
      };
      proliferate.submit(exp.data);
    }
  });

  return slides;
}

/*
INIT
This function creates the stimuli list

allstimuli is an array from 'stimuli.js' that contains all the stimuli in the
study. Each entry in the array is in the following format:
{
"item": ["armchair"],
"colorScheme": 1
},
item: an array with a single string containing the name of the object.
colorScheme: {1,2} refers to the possible colors that that stimuli occurs in
    1: blue, red, yellow, white
    2: purple, orange, green, black
Stimuli image names are of the format color_object.jpg

The function takes in allStimuli variable and shuffles the order to randomize
the order in which participants see stimuli.

It then randomly assigns a color to each object (from the object's color scheme).

Return:
Dictionary with entries:
  item: name of object, single word string
  label: string of format "color_object"

the ".jpeg" is added to the label in another part of the code
*/
function init() {
  //get allStimuli
  var items_target = _.shuffle(allStimuli);
  //function that makes a dictionary of the desired output
  // format for a single stimulis
  function makeTargetStim(i) {
    //get item
    var item = items_target[i];
    var item_id = item.item[0];
    var cs1 = ["blue", "red", "yellow", "white"];
    var cs2 = ["purple", "orange", "green", "black"];
    var color = "";
    object_color_scheme = item.colorScheme;

    if (object_color_scheme == 1) {
      color = cs1[Math.floor(Math.random() * Math.floor(4))];
    } else {
      color = cs2[Math.floor(Math.random() * Math.floor(4))];
    }
    var object_label = item.label;

      return {
	  "item": item_id,
    "label": color + "_" + item_id
    }
  }

  // Create empty array to store all the stims
  exp.all_stims = [];
  //for loop that iterates through all stimuli and calls on the function that
  // creates a dictionary for each stimulus
  for (var i=0; i < items_target.length; i++) {
    //call on a function that creates the stims
    // and add them to the empty array
    exp.all_stims.push(makeTargetStim(i));
  }

  // shuffle the order of items in the array to get a randomized trial order
  exp.all_stims = _.shuffle(exp.all_stims);

  exp.trials = [];
  exp.catch_trials = [];
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
  exp.structure=["i0", "objecttrial", 'subj_info', 'thanks'];

  exp.data_trials = [];
  //make corresponding slides:
  exp.slides = make_slides(exp);

  exp.nQs = utils.get_exp_length(); //this does not work if there are stacks of stims (but does work for an experiment with this structure)
                    //relies on structure and slides being defined
  $(".nQs").html(exp.nQs);

  $('.slide').hide(); //hide everything

  //make sure turkers have accepted HIT (or you're not in mturk)
  $("#start_button").click(function() {
      exp.go();
  });

  exp.go(); //show first slide
}
