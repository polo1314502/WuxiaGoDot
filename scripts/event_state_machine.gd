# event_state_machine.gd
class_name EventStateMachine
extends Node

enum State {
	IDLE,
	SHOWING_EVENT,
	WAITING_CHOICE,
	PROCESSING_ACTION,
	SHOWING_RESULT,
	BATTLE_PENDING
}

var current_state: State = State.IDLE
var event_manager: EventManager
var main_scene

signal state_changed(new_state: State)
signal result_ready(result_text: String)

func _init(main, manager: EventManager):
	main_scene = main
	event_manager = manager

func change_state(new_state: State):
	current_state = new_state
	state_changed.emit(new_state)

func start_event(event: EventData):
	event_manager.trigger_event(event)
	change_state(State.SHOWING_EVENT)

func show_current_step():
	change_state(State.WAITING_CHOICE)

func handle_choice(choice_index: int):
	change_state(State.PROCESSING_ACTION)
	var action = event_manager.process_choice(choice_index)
	
	if action:
		if action.triggers_battle:
			change_state(State.BATTLE_PENDING)
			result_ready.emit(action.get_result())
		else:
			change_state(State.SHOWING_RESULT)
			result_ready.emit(action.get_result())

func complete_event():
	event_manager.complete_event()
	change_state(State.IDLE)
