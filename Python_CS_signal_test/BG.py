
from py4godot.methods import private
from py4godot.signals import signal, SignalArg
from py4godot.classes import gdclass
from py4godot.classes.core import Vector3
from py4godot.classes.Sprite2D.Sprite2D import Sprite2D
from py4godot.classes import Input

@gdclass
class BG(Sprite2D):
	test_signal = signal([SignalArg("test_arg", int)])
	
	def _ready(self):
		self.clickCount = 0
	def _process(self, delta):
		pass
		
	def _input(self, event):
		if event.is_pressed():
			print(event.as_text())
			self.clickCount+=1;
			self.test_signal.emit(event.as_text())
			

	def on_button_pressed(self, clickCount):
		pass
		
		
		
