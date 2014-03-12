package ;

import haxe.Log;
import haxe.Timer;
import js.Browser;
import js.html.CanvasElement;
import js.html.CanvasRenderingContext2D;
import js.Lib;

/**
 * ...
 * @author hmitubor
 */

class Main 
{
	var canvas: CanvasElement;
	var balls: Array<Ball>;
	var timer: Timer;
	var cnt: Int;
	var timer_flag: Bool;
	
	static public function main() 
	{
		new Main();
	}
	
	public function new()
	{
		Browser.window.onload = init;
		balls = new Array<Ball>();
		cnt = 0;
	}
	
	private function init(e):Void
	{
		var document = Browser.window.document;

		canvas  = document.createCanvasElement();
		document.body.appendChild(canvas);

		canvas.width = 800;
		canvas.height = 600;

		canvas.onclick = addBall;
		canvas.ondblclick = timer_stop;
		
		timer = new Timer(20);
		timer.run = loop;
		timer_flag = true;
	}

	private function addBall(e):Void 
	{
		var ball = new Ball(canvas.width, canvas.height, e.pageX, e.pageY, cnt++);
		balls.push(ball);
	}
	
	private function timer_stop(e):Void 
	{
		timer_flag = false;		
	}
	
	private function loop():Void 
	{
		var context: CanvasRenderingContext2D = canvas.getContext("2d");
		context.fillStyle = "#EEEEEE";
		context.fillRect(0, 0, canvas.width, canvas.height);
		
		context.strokeStyle = "#000000";
		context.strokeRect(1, 1, canvas.width - 2, canvas.height - 2);

		for (ball in balls)
		{
			context.beginPath();
			context.fillStyle = "#000000";
			context.arc(ball.pos_x, ball.pos_y, ball.radius, 0, Math.PI*2, true);
			context.fill();
			
			ball.update();
		}
		
		if (timer_flag == false) 
		{
			timer.stop();
		}
	}	
}

class Ball
{
	var max_speed = 15;
	var debug: Int;
	
	public var pos_x(default, null): Int;
	public var pos_y(default, null): Int;
	public var radius(default, null): Int;
	var angle: Int;
	var speed: Int;
	var unit_x: Int;
	var unit_y: Int;

	var width: Int;
	var height: Int;
	
	public function new(width, height, x, y, n):Void 
	{
		this.width = width;
		this.height = height;
		debug = n;
		
		// radius = 5...10
		radius = Math.floor(Math.random() * 5) + 5;
		
		pos_x = x - radius;
		pos_y = y - radius;
		
		angle = Math.floor(Math.random() * 360);

		// speed = 5...10
		speed = max_speed - radius;
		
		calc_step();
	}
	
	public function update():Void 
	{		
		if ( pos_x+unit_x < 0 || pos_x+unit_x > width )
		{
			angle = 180 - angle;
		}
		else if ( pos_y+unit_y < 0 || pos_y+unit_y > height )
		{
			angle = 360 - angle;
		}

		calc_step();
		
		pos_x += unit_x;
		pos_y += unit_y;

		Log.trace('[$debug]: x=$pos_x, y=$pos_y, angle=$angle, unit_x=$unit_x, unit_y=$unit_y');
	}

	private function calc_step():Void 
	{
		var radians = angle * Math.PI / 180;
		unit_x = Math.floor(Math.cos(radians) * speed);
		unit_y = Math.floor(Math.sin(radians) * speed);
	}
}