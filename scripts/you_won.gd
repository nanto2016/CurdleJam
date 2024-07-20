extends ColorRect

var gems: int = 0:
	set(value):
		gems = value
		var COLOR: String
		match gems:
			0: COLOR = "red"
			1: COLOR = "orangered"
			2: COLOR = "orange"
			3: COLOR = "yellow"
			4: COLOR = "cyan"
			5: COLOR = "green"
			6: COLOR = "gold"; $Label.visible = true;
		$CenterContainer/RichTextLabel2.text = " 
 
 
[center]And collected [color=" + COLOR + "]" + var_to_str(gems) + "[/color] GEM" + ("S" if gems != 1 else "") + "[/center]"
