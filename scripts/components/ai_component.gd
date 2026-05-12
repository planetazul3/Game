extends RefCounted
class_name AIComponent

var state_machine: Node # Or RefCounted, but usually Node for hierarchy in states? 
# Actually, let's keep it RefCounted for 1000+ entities scalability if possible.

var current_state_name: String = "Idle"
