var Valetplate = "blabla"

$(document).on('click', '.garage-vehicle', function(e){
    e.preventDefault();

    $(".garage-homescreen").animate({
        left: 30+"vh"
    }, 200);
    $(".garage-detailscreen").animate({
        left: 0+"vh"
    }, 200);

    var Id = $(this).attr('id');
    var VehData = $("#"+Id).data('VehicleData');
    SetupDetails(VehData);  
	Valetplate = (VehData.plate)
});

$(document).on('click', '#garageback', function(e){
    e.preventDefault();

    $(".garage-homescreen").animate({
        left: 00+"vh"
    }, 200);
    $(".garage-detailscreen").animate({
        left: -30+"vh"
    }, 200);
});

$(document).on('click', '#garagevalet', function(e){
    e.preventDefault();
	SetupValetCars(Valetplate);
});

SetupValetCars = function(data) {
	console.log(data)
	if ((Valetplate !== "")) {
		$.post('https://qb-phone/GetCar', JSON.stringify({
			profilepicture: Valetplate,
		}));
	}
}
