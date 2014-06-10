$(document).ready(function(){
	if ($("#results").length > 0){
		initializeFavoriteUserLoad();
	}
});

function initializeFavoriteUserLoad(){
	var username = $("#results").data("username");
	var request_url = "/find_or_create_user/" + username + ".js";
	if(username.length > 0){
		$.ajax({
			type: "GET",
			url: request_url,
		});
	}
}

function incrementalLoadTweets(number_of_tweets){
	var request_url = "/incremental_load_tweets/" + number_of_tweets + ".js"
	$.ajax({
		type: "GET",
		url: request_url,
	});
}

function updateLoadingBarProgress(tweets_loaded, number_of_tweets){
	var progress_bar_text =  tweets_loaded + " of " + total_tweets + " loaded";
	$("#progress_bar").text(progress_bar_text);
	var new_progress_bar_width = (tweets_loaded / number_of_tweets) * 100;
	if (new_progress_bar_width < 10){
		new_progress_bar_width = 10;	
	}
	$("#progress_bar").css({'width': new_progress_bar_width + "%"});
}

function finalize(){
	$("#progress_bar").text("Processing tweets")
	var request_url = "/finalize/placeholder.js"
	$.ajax({
		type: "GET",
		url: request_url,
	});
}

function wireUpResultsEvents(){
	$("#tweet").keyup( function(){
		var length = this.value.length;
		$("#tweet_length").text(length);
		if (length > 140 || length === 0){
			$("#tweet_form").addClass("control-group error");
			$("#tweet_button").attr("disabled", "disabled");
		}
		else{
			$("#tweet_form").removeClass("control-group error");
			$("#tweet_button").removeAttr("disabled");
		}
	});

}
