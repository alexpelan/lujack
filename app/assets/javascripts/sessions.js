$(document).ready(function(){
	if ($("#results").length > 0){
		setTimeout(loadFavoriteUsers,100); //if we don't set timeout, for some reason we don't show the page until the ajax request is complete
		setTimeout(checkLoadingStatus,1000)
	}
});
	
function loadFavoriteUsers(){
	var username = $("#results").attr("username");
	var request_url = "/results/" + username + ".js";
	$.ajax({
			type: "GET",
			url: request_url,
	});
}

function checkLoadingStatus(){
	var username = $("#results").attr("username");
	var request_url = "/progress/" + username + ".js";
	$.ajax({
		type: "GET",
		url: request_url
	});
	var progress_bar = document.getElementById("progress_bar")
	var w = parseFloat(progress_bar.style.width);
	document.getElementById("progress_bar").style.width = (w + 10) + "%";
	//console.log("called!");
	if (w < 100){	
		setTimeout(checkLoadingStatus,1000);	
	}
}