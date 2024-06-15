extends Node

var is_open : bool

func interact(hand):
	if is_open:
		%DoorCollider.disabled = true
