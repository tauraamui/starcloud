module widgets

import gg

fn test_overlaps_does_not_overlap() {
	rect_one := gg.Rect{ x: 10, y: 10, width: 20, height: 20 }
	rect_two := gg.Rect{ x: 30, y: 50, width: 20, height: 20 }
	assert !overlaps(rect_one, rect_two)
}

fn test_overlaps_does_not_overlap_behind() {
	rect_one := gg.Rect{ x: 10, y: 10, width: 20, height: 20 }
	rect_two := gg.Rect{ x: -20, y: 20, width: 20, height: 20 }
	assert !overlaps(rect_one, rect_two)
}

fn test_overlaps_does_overlap_positive() {
	rect_one := gg.Rect{ x: 10, y: 10, width: 20, height: 20 }
	rect_two := gg.Rect{ x: 15, y: 15, width: 25, height: 25 }
	assert overlaps(rect_one, rect_two)
}

fn test_overlaps_does_overlap_negative() {
	rect_one := gg.Rect{ x: 10, y: 10, width: 20, height: 20 }
	rect_two := gg.Rect{ x: 5, y: 5, width: 25, height: 25 }
	assert overlaps(rect_one, rect_two)
}
