#include <TVout.h>
#include <fontALL.h>

TVout TV;

struct Point
{
  int x,y;
};

struct Ball
{
 int r;
 Point c;
 Point v;
};
Ball ball;

struct Paddle
{
  int   l; // length
  Point t; // top
  Point v; // velocity
};
Paddle paddle;

struct Screen
{
  Point top_left;
  Point bot_right;
  Point c;
};
Screen screen;

bool pause;
int fps;
int count;
void setup() {
  TV.begin(NTSC,120,96);
  TV.select_font(font4x6);
  TV.println("Welcome To BALLS");
  TV.delay(2500);
  TV.println("\nBy Sean Gooding");
  TV.delay(1000);
  TV.clear_screen();
  
  fps          = 1; 
  ball.c.x     = TV.hres()/2; // 60
  ball.c.y     = TV.vres()/2; // 48
  ball.v.x     = 1;
  ball.v.y     = 1; 
  ball.r       = 2;
 
  paddle.t.x   = 3; 
  paddle.t.y   = 6;
  paddle.v.y   = 0;
  paddle.l     = 10;
  
  screen.top_left.x = 0;
  screen.top_left.y = 5;
  screen.bot_right.x = TV.hres();
  screen.bot_right.y = TV.vres();
  screen.c.x = TV.hres()/2;
  screen.c.y = TV.vres()/2;
  
  Serial.begin(9600);
  pause = false;
}

char buff[10];

void print_ball()
{
 // sprintf(buff, "x(%d) y(%d) r(%d) px(%d) py(%d) s(%d) \n",ball.x,(int)ball.y,(int)ball.r,paddle.x, paddle.y, count);
  //sprintf(buff,"%d%d",count%10,count - count%10);
  //TV.print(0,1,count%10,DEC);
  //TV.print(count - 10*(count%10),DEC);
 TV.println("Hello World");
 // Serial.println(buff);
}

void check_collision()
{
  Ball ball_next;
  ball_next.c.x = ball.c.x + fps*ball.v.x;
  ball_next.c.y = ball.c.y + fps*ball.v.y;
  
  int ball_left_edge  = ball_next.c.x - ball.r;
  int ball_right_edge = ball_next.c.x + ball.r;
  int ball_top_edge   = ball_next.c.y - ball.r;
  int ball_bot_edge   = ball_next.c.y + ball.r;

  // hit the left paddle
  if( (ball_left_edge <= paddle.t.x) &&
      ( ball_bot_edge <= (paddle.t.y+paddle.l) &&
        ball_top_edge >= paddle.t.y ) )
  {
    ball.v.x = -ball.v.x;
    ball.v.y = -ball.v.y;
    return;
  }
  
  // hit the left edge of screen
  if( ball_left_edge <= 0 )
  {
    count += 1;
    ball.c = screen.c;
    ball.v.x = 1;
    ball.v.y = 1;
    return;
  }

  // ball hit the top edge of screen
  if( ball_top_edge <= screen.top_left.y )
  {
    ball.v.y = -ball.v.y;
    return;
  }
  
  // ball hit the bot edge of screen
  if( ball_bot_edge >= screen.bot_right.y )
  {
    ball.v.y = -ball.v.y;
    return;
  }
  
  // ball hit the right edge of screen
  if( ball_right_edge >= screen.bot_right.x )
  {
    ball.v.x = -ball.v.x;
    return;
  }

}

void update_position()
{
  ball.c.x += ball.v.x*fps;
  ball.c.y += ball.v.y*fps;
}
 
void loop(){
  
  TV.draw_circle(ball.c.x,ball.c.y,ball.r,WHITE);
  TV.draw_line(paddle.t.x,paddle.t.y,paddle.t.x,paddle.t.y+paddle.l,WHITE);
  print_ball();
  TV.delay(10);  
  TV.clear_screen();
  
  bool step_pause = false;
  if(Serial.available())
  {
    char k = (char)Serial.read();
    if( k == 'k' )
    {
      paddle.v.y = -3;
    }
    else if( k == 'j' )
    {
      paddle.v.y = 3;
    }
    else if ( k == 's' )
    {
      step_pause = true;
    }
    else if ( k == 'p' )
    {
      pause = !pause;
    }
    
  }  
  else
  {
    paddle.v.y = 0;
  }
  
  if( !pause || step_pause)
  {
    update_position();
    step_pause = false;
  }

  paddle.t.y += paddle.v.y;  
  
  check_collision();
}

