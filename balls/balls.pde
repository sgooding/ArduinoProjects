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
Paddle paddle,paddle2;

struct Screen
{
  Point top_left;
  Point bot_right;
  Point c;
};
Screen screen;

bool pause;
int fps;
int count,count2;
int score_delay_count;
void setup() {
  TV.begin(NTSC,120,96);
  TV.select_font(font4x6);
  TV.println("Welcome To BALLS");
  TV.delay(2500);
  TV.println("\nBy Sean Gooding");
  TV.delay(1000);
  TV.clear_screen();
  
  
  screen.top_left.x = 0;
  screen.top_left.y = 5;
  screen.bot_right.x = TV.hres();
  screen.bot_right.y = TV.vres();
  screen.c.x = TV.hres()/2;
  screen.c.y = TV.vres()/2;
  
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
  
  paddle2      = paddle;
  paddle2.t.x  = screen.bot_right.x - 3;
  
  score_delay_count = 100;
  
  Serial.begin(9600);
  pause = false;
}

int random_dir()
{
  int val = random(0,2);
  if( val == 0 )
    return -1;
  return val;
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
    if( ball_next.c.y >= (paddle.t.y+3) &&
        ball_next.c.y <= (paddle.t.y+paddle.l-3) )
    {
      ball.v.y = 1;
    }
    else
    {
      ball.v.y = 2;
    }
    
    return;
  }
  
  // hit the right paddle
  if( (ball_right_edge >= paddle2.t.x) &&
      ( ball_bot_edge <= (paddle2.t.y+paddle2.l) &&
        ball_top_edge >= paddle2.t.y ) )
  {
    ball.v.x = -ball.v.x;

    if( ball_next.c.y >= (paddle.t.y+3) &&
        ball_next.c.y <= (paddle.t.y+paddle.l-3) )
    {
      ball.v.y = 1;
    }
    else
    {
      ball.v.y = 2;
    }
    
    return;
  }
  
  // hit the left edge of screen
  if( ball_left_edge <= 0 )
  {
    count2 += 1;
    ball.c = screen.c;
    ball.v.x = random_dir();
    ball.v.y = random_dir();
    score_delay_count = 100;
    return;
  }
  
  // hit the right edge of screen
  if( ball_right_edge >= screen.bot_right.x )
  {
    count += 1;
    ball.c = screen.c;
    ball.v.x = random_dir();
    ball.v.y = random_dir();
    score_delay_count = 100;
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
  

}

void update_position()
{
  ball.c.x += ball.v.x*fps;
  ball.c.y += ball.v.y*fps;
}

void draw_screen()
{
  TV.draw_circle(ball.c.x,ball.c.y,ball.r,WHITE,WHITE);
  TV.draw_line(paddle.t.x,paddle.t.y,paddle.t.x,paddle.t.y+paddle.l,WHITE);
  TV.draw_line(paddle2.t.x,paddle2.t.y,paddle2.t.x,paddle2.t.y+paddle2.l,WHITE);
  
  if( score_delay_count < 100 && score_delay_count > 66 )
  {
    TV.printPGM(screen.c.x-8,0,PSTR("Ready..."));
  } else if( score_delay_count <= 66 && score_delay_count > 33 )
  {
    TV.printPGM(screen.c.x-8,0,PSTR("Set....."));    
  } else if( score_delay_count <= 33 && score_delay_count > 1 )
  {
    TV.printPGM(screen.c.x-6,0,PSTR("GO!!"));
  }
  
  
  TV.print(0,0,count,DEC);
  TV.print(screen.bot_right.x-10,0,count2,DEC);
}

void blank_screen()
{
  TV.draw_line(paddle.t.x,paddle.t.y,paddle.t.x,paddle.t.y+paddle.l,BLACK);
  TV.draw_line(paddle2.t.x,paddle2.t.y,paddle2.t.x,paddle2.t.y+paddle2.l,BLACK);
  TV.draw_circle(ball.c.x,ball.c.y,ball.r,BLACK,BLACK);
  TV.draw_rect(0,0,screen.bot_right.x,8,BLACK,BLACK);
}
 
void loop(){

  draw_screen();
  TV.delay(10); 
  blank_screen(); 
 
  bool step_pause = false;
  if(Serial.available())
  {
    char k = (char)Serial.read();
    if( k == 'q' )
    {
      paddle.v.y = -3;
    }
    else if( k == 'a' )
    {
      paddle.v.y = 3;
    }
    else if( k == 'o' )
    {
      paddle2.v.y = -3;
    }
    else if( k == 'l' )
    {
      paddle2.v.y = 3;
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
    paddle2.v.y = 0;
  }
  
  if( !pause || step_pause)
  {
    if( score_delay_count == 0 )
    {
      update_position();
    } else 
    {
      score_delay_count--;
    }
    step_pause = false;
  }

  paddle.t.y += paddle.v.y;  
  paddle2.t.y += paddle2.v.y;
  paddle.t.y = constrain(paddle.t.y,screen.top_left.y,screen.bot_right.y-paddle.l);
  paddle2.t.y = constrain(paddle2.t.y,screen.top_left.y,screen.bot_right.y-paddle2.l);
  check_collision();
}

