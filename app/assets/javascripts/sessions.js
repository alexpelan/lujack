$(document).ready(function(){
	if ($("#results").length > 0){
		loadFavoriteUsers();
	}
});
	
function loadFavoriteUsers(){
	var username = $("#results").attr("username");
	var request_url = "/results/" + username + ".js"
	$.ajax({
			type: "GET",
			url: request_url
	});
}