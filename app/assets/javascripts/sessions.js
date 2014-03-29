$(document).ready(function(){
	if ($("#results").length > 0){
		loadFavoriteUsers();
	}
});
	
function loadFavoriteUsers(){
	alert("this is happening");
	$.ajax({
			type: "GET",
			url: "/profile/alexpelan.js"
	});
}