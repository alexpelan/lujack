$(document).ready(function(){
	if ($("#results").length > 0){
		initializeFavoriteUserLoad();
	}
});

function initializeFavoriteUserLoad(){
	var username = $("#results").data("username");
	var request_url = "/find_or_create_user/" + username + ".js";
	$.ajax({
			type: "GET",
			url: request_url,
	}).done(incrementalLoadTweets(200));	
	$("#progress_bar").text("Initializing");
}

function incrementalLoadTweets(number_of_tweets){
	var request_url = "/incremental_load_tweets/" + number_of_tweets + ".js"
	$.ajax({
		type: "GET",
		url: request_url,
	});
}

function updateLoadingBarProgress(tweets_loaded, number_of_tweets){
	var progress_bar_text =  tweets_loaded + " of " + total_tweets;
	$("#progress_bar").text(progress_bar_text);
	var new_progress_bar_width = (tweets_loaded / number_of_tweets) * 100;
	if (new_progress_bar_width < 10){
		new_progress_bar_width = 10;	
	}
	$("#progress_bar").css({'width': new_progress_bar_width + "%"});
}

function finalize(){
	$("#progress_bar").text("Processing tweets")
	var request_url = "/finalize/"
	$.ajax({
		type: "GET",
		url: request_url,
	});
}